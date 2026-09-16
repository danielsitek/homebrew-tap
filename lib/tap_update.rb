# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require 'fileutils'

module TapUpdate
  ROOT = File.expand_path('..', __dir__)
  VERSION = /\A(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\z/

  class Error < StandardError; end

  def self.registry
    JSON.parse(File.read(File.join(ROOT, 'config/releases.json')))
  end

  def self.contract(repository)
    registry.fetch(repository) { raise Error, "Unknown upstream repository: #{repository}" }
  end

  def self.version(tag, config)
    prefix = config.fetch('tag_prefix')
    value = tag.start_with?(prefix) ? tag.delete_prefix(prefix) : nil
    raise Error, "Malformed release tag: #{tag}" unless value && VERSION.match?(value)

    value
  end

  def self.compare(left, right)
    left.split('.').map(&:to_i) <=> right.split('.').map(&:to_i)
  end

  def self.current_version(formula, config)
    return nil unless File.exist?(formula)

    source = File.read(formula)
    repository = Regexp.escape(config.fetch('repository'))
    prefix = Regexp.escape(config.fetch('tag_prefix'))
    match = source.match(%r{https://github\.com/#{repository}/releases/download/#{prefix}([^/]+)/})
    raise Error, "Cannot identify current release in #{formula}" unless match

    version(match[1].prepend(config.fetch('tag_prefix')), config)
  end

  def self.publication_status(candidate, target, config, candidate_version)
    current = current_version(target, config)
    return :new unless current

    order = compare(candidate_version, current)
    return :older if order.negative?
    return :new if order.positive?

    raise Error, 'Same-version formula differs' unless File.read(target) == candidate

    :same
  end

  def self.parse_checksums(body, config, version)
    expected = config.fetch('archives').transform_values { |template| format(template, version: version) }
    found = {}
    body.lines.each do |line|
      match = /\A([0-9a-f]{64}) {2}(\S+)\n?\z/.match(line)
      raise Error, "Malformed checksum line: #{line.inspect}" unless match
      name = match[2]
      raise Error, "Unexpected checksum target: #{name}" unless expected.value?(name)
      raise Error, "Duplicate checksum target: #{name}" if found.key?(name)

      found[name] = match[1]
    end
    missing = expected.values - found.keys
    raise Error, "Missing checksum targets: #{missing.join(', ')}" unless missing.empty?

    expected.transform_values { |name| found.fetch(name) }
  end

  def self.validate_release!(release, config)
    raise Error, 'Release is draft or prerelease' if release['draft'] || release['prerelease'] || !release['published_at']

    version(release.fetch('tag_name'), config)
  end

  class Github
    def initialize(token: ENV['GITHUB_TOKEN'])
      @token = token
    end

    def get(url, accept: 'application/vnd.github+json', redirects: 4)
      uri = URI(url)
      raise Error, "Untrusted URL: #{url}" unless uri.scheme == 'https' && %w[api.github.com github.com release-assets.githubusercontent.com].include?(uri.host)

      request = Net::HTTP::Get.new(uri)
      request['Accept'] = accept
      request['User-Agent'] = 'homebrew-tap-updater'
      request['Authorization'] = "Bearer #{@token}" if @token && uri.host == 'api.github.com'
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) { |http| http.request(request) }
      if response.is_a?(Net::HTTPRedirection)
        raise Error, 'Too many redirects' if redirects.zero?
        return get(response.fetch('location'), accept: accept, redirects: redirects - 1)
      end
      raise Error, "GET #{uri} failed: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    def release(repository, tag = nil)
      path = tag ? "tags/#{URI.encode_www_form_component(tag)}" : 'latest'
      JSON.parse(get("https://api.github.com/repos/#{repository}/releases/#{path}"))
    end
  end

  def self.prepare(repository, tag: nil, output:, github: Github.new)
    config = contract(repository).merge('repository' => repository)
    version(tag, config) if tag

    release = github.release(repository, tag)
    version = validate_release!(release, config)
    raise Error, 'Release tag does not match request' if tag && release['tag_name'] != tag

    assets = {}
    release.fetch('assets').each do |asset|
      name = asset.fetch('name')
      raise Error, "Duplicate release asset: #{name}" if assets.key?(name)
      assets[name] = asset
    end
    names = config.fetch('archives').values.map { |template| format(template, version: version) }
    checksum_name = config.fetch('checksum_asset')
    (names + [checksum_name]).each { |name| raise Error, "Missing release asset: #{name}" unless assets.key?(name) }
    manifest_url = assets.fetch(checksum_name).fetch('browser_download_url')
    expected_url = "https://github.com/#{repository}/releases/download/#{release.fetch('tag_name')}/#{checksum_name}"
    raise Error, 'Unexpected checksum asset URL' unless manifest_url == expected_url

    checksums = parse_checksums(github.get(manifest_url), config, version)
    names.each do |name|
      expected = "https://github.com/#{repository}/releases/download/#{release.fetch('tag_name')}/#{name}"
      raise Error, "Unexpected archive URL: #{name}" unless assets.fetch(name).fetch('browser_download_url') == expected
    end

    require_relative "renderers/#{config.fetch('renderer')}"
    rendered = Renderers.const_get('AsanaCli').render(repository, version, checksums) if config.fetch('renderer') == 'asana_cli'
    raise Error, "Unknown renderer: #{config.fetch('renderer')}" unless rendered

    FileUtils.mkdir_p(output)
    File.write(File.join(output, "#{config.fetch('formula')}.rb"), rendered)
    File.write(File.join(output, "#{config.fetch('formula')}.json"), JSON.generate(repository: repository, tag: release.fetch('tag_name'), version: version))
    rendered
  end
end
