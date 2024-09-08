# realuser.gemspec

Gem::Specification.new do |spec|
  spec.name = 'realuser'
  spec.version = '0.1.1'
  spec.authors = ['Julian Kahlert']
  spec.email = ['90937526+juliankahlert@users.noreply.github.com']

  spec.summary = 'Retrieve the real user ID (RUID) of a process and its parent processes.'
  spec.description = 'The realuser gem provides a simple API for obtaining the real user ID (RUID) of a process and its parent processes on Linux systems. It leverages the `/proc` filesystem to perform deep and shallow resolution of RUIDs, making it useful for process management and monitoring in Linux environments.'
  spec.homepage = 'https://github.com/juliankahlert/realuser'
  spec.license = 'MIT'

  spec.metadata['homepage_uri'] = 'https://juliankahlert.github.io/realuser/'
  spec.metadata['documentation_uri'] = 'https://www.rubydoc.info/gems/realuser/0.1.1'
  spec.metadata['source_code_uri'] = 'https://github.com/juliankahlert/realuser'

  spec.files = Dir['lib/**/*', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'simplecov-cobertura', '~> 2', '>= 2.1'
  spec.add_development_dependency 'simplecov-console', '~> 0.9', '>= 0.9.1'
  spec.add_development_dependency 'simplecov', '~> 0.22', '>= 0.22.0'
  spec.add_development_dependency 'yard', '~> 0.9', '>= 0.9.37'
  spec.add_development_dependency 'rspec', '~> 3', '>= 3.4'

  spec.required_ruby_version = '>= 3.0.0'
end
