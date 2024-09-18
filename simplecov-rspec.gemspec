# frozen_string_literal: true

require_relative 'lib/simplecov-rspec/version'

Gem::Specification.new do |spec|
  spec.name = 'simplecov-rspec'
  spec.version = Simplecov::Rspec::VERSION
  spec.authors = ['James Couball']
  spec.email = ['jcouball@yahoo.com']

  spec.summary = 'Configure SimpleCov to fail RSpec if the test coverage falls below a given threshold'
  spec.description = <<~DESCRIPTION
    Configures RSpec to fail (and exit with with a non-zero exitcode) if the
    test coverage is below the configured threshold and (optionally) list the
    lines of code not covered by tests.
  DESCRIPTION
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  # Project links
  spec.homepage = "https://github.com/main-branch/#{spec.name}"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['documentation_uri'] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata['changelog_uri'] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}/file/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.requirements = [
    'Platform: Mac, Linux, or Windows',
    'Ruby: MRI 3.1 or later, TruffleRuby 24 or later, or JRuby 9.4 or later'
  ]

  spec.add_dependency 'simplecov', '~> 0.22'

  spec.add_development_dependency 'bundler-audit', '~> 0.9'
  spec.add_development_dependency 'create_github_release', '~> 1.5'
  spec.add_development_dependency 'fuubar', '~> 2.5'
  spec.add_development_dependency 'main_branch_shared_rubocop_config', '~> 0.1'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.66'
  spec.add_development_dependency 'simplecov-lcov', '~> 0.8'
  spec.add_development_dependency 'turnip', '~> 4.4'

  unless RUBY_PLATFORM == 'java'
    spec.add_development_dependency 'redcarpet', '~> 3.6'
    spec.add_development_dependency 'yard', '~> 0.9', '>= 0.9.28'
    spec.add_development_dependency 'yardstick', '~> 0.9'
  end

  spec.metadata['rubygems_mfa_required'] = 'true'
end
