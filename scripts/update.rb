#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/tap_update'

begin
  command = ARGV.shift
  case command
  when 'plan'
    repository = ENV['UPSTREAM_REPOSITORY'].to_s
    tag = ENV['UPSTREAM_TAG'].to_s
    repositories = repository.empty? ? TapUpdate.registry.keys : [repository]
    matrix = repositories.map do |name|
      config = TapUpdate.contract(name)
      formula = config.fetch('formula')
      TapUpdate.prepare(name, tag: tag.empty? ? nil : tag, output: File.join('candidates', formula))
      { repository: name, formula: formula }
    end
    puts JSON.generate(matrix)
  when 'publish'
    repository = ARGV.fetch(0)
    config = TapUpdate.contract(repository).merge('repository' => repository)
    formula = config.fetch('formula')
    directory = File.join('candidates', formula)
    metadata = JSON.parse(File.read(File.join(directory, "#{formula}.json")))
    raise TapUpdate::Error, 'Candidate repository mismatch' unless metadata.fetch('repository') == repository
    version = TapUpdate.version(metadata.fetch('tag'), config)
    raise TapUpdate::Error, 'Candidate version mismatch' unless metadata.fetch('version') == version
    candidate = File.read(File.join(directory, "#{formula}.rb"))
    target = File.join('Formula', "#{formula}.rb")

    abort 'Cannot fetch main' unless system('git', 'fetch', 'origin', 'main')
    abort 'Cannot update checkout' unless system('git', 'pull', '--ff-only', 'origin', 'main')
    status = TapUpdate.publication_status(candidate, target, config, version)
    if status == :older
      puts "Skipping #{formula} #{version}: current version is newer"
      exit 0
    end
    if status == :same
      puts "#{formula} #{version} is already current"
      exit 0
    end

    File.write(target, candidate)
    abort 'Invalid formula syntax' unless system('ruby', '-c', target)
    abort 'Cannot stage formula' unless system('git', 'add', '--', target)
    abort 'Cannot commit formula' unless system('git', 'commit', '-m', "feat: update #{formula} to #{version}")
    abort 'Cannot push formula; rerun after resolving main' unless system('git', 'push', 'origin', 'HEAD:main')
  else
    raise TapUpdate::Error, 'Usage: update.rb plan|publish [repository]'
  end
rescue TapUpdate::Error, KeyError, JSON::ParserError => e
  warn e.message
  exit 1
end
