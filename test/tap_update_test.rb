# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/tap_update'

class TapUpdateTest < Minitest::Test
  REPOSITORY = 'danielsitek/asana-cli'

  class FakeGithub
    attr_reader :calls

    def initialize(release, manifest)
      @release = release
      @manifest = manifest
      @calls = 0
    end

    def release(_repository, _tag)
      @calls += 1
      @release
    end

    def get(_url)
      @manifest
    end
  end

  def setup
    @config = TapUpdate.contract(REPOSITORY).merge('repository' => REPOSITORY)
  end

  def fixture(version = '0.6.0')
    tag = "v#{version}"
    names = @config.fetch('archives').values.map { |template| format(template, version: version) }
    names << 'SHA256SUMS'
    release = {
      'tag_name' => tag, 'published_at' => '2026-09-15T00:00:00Z',
      'draft' => false, 'prerelease' => false,
      'assets' => names.map { |name| { 'name' => name, 'browser_download_url' => "https://github.com/#{REPOSITORY}/releases/download/#{tag}/#{name}" } }
    }
    manifest = names[0...-1].map { |name| "#{'a' * 64}  #{name}\n" }.join
    [release, manifest]
  end

  def test_unknown_repository_and_malformed_tags_fail_before_network
    release, manifest = fixture
    github = FakeGithub.new(release, manifest)
    Dir.mktmpdir do |dir|
      assert_raises(TapUpdate::Error) { TapUpdate.prepare('other/repo', output: dir, github: github) }
      %w[0.6.0 v0.6 v0.6.0-beta v01.6.0].each do |tag|
        assert_raises(TapUpdate::Error) { TapUpdate.prepare(REPOSITORY, tag: tag, output: dir, github: github) }
      end
      assert_equal 0, github.calls
    end
  end

  def test_invalid_manifests_and_release_metadata
    release, manifest = fixture
    lines = manifest.lines
    bad = [lines[0...-1].join, manifest + lines.first, manifest + "#{'b' * 64}  unexpected.tar.gz\n", "not a checksum\n"]
    bad.each { |body| assert_raises(TapUpdate::Error) { TapUpdate.parse_checksums(body, @config, '0.6.0') } }
    assert_raises(TapUpdate::Error) { TapUpdate.validate_release!(release.merge('draft' => true), @config) }
    assert_raises(TapUpdate::Error) { TapUpdate.validate_release!(release.merge('prerelease' => true), @config) }
    assert_raises(TapUpdate::Error) { TapUpdate.validate_release!(release.merge('published_at' => nil), @config) }
  end

  def test_generated_current_release_is_identical_and_repeatable
    release, manifest = fixture
    Dir.mktmpdir do |dir|
      first = TapUpdate.prepare(REPOSITORY, tag: 'v0.6.0', output: dir, github: FakeGithub.new(release, manifest))
      second = TapUpdate.prepare(REPOSITORY, tag: 'v0.6.0', output: dir, github: FakeGithub.new(release, manifest))
      assert_equal first, second
      assert_equal '0.6.0', TapUpdate.current_version(File.join(TapUpdate::ROOT, 'Formula/asana-cli.rb'), @config)
    end
  end

  def test_version_order_prevents_downgrade
    assert_operator TapUpdate.compare('0.5.0', '0.6.0'), :<, 0
    assert_equal 0, TapUpdate.compare('0.6.0', '0.6.0')
    assert_operator TapUpdate.compare('0.10.0', '0.9.0'), :>, 0
  end

  def test_duplicate_event_is_no_op_and_older_release_cannot_publish
    current = File.join(TapUpdate::ROOT, 'Formula/asana-cli.rb')
    source = File.read(current)
    assert_equal :same, TapUpdate.publication_status(source, current, @config, '0.6.0')
    assert_equal :older, TapUpdate.publication_status('older candidate', current, @config, '0.5.0')
    assert_raises(TapUpdate::Error) { TapUpdate.publication_status('changed same version', current, @config, '0.6.0') }
  end
end
