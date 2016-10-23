version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi-rails'
  spec.version       = version
  spec.author        = ['L. Preston Sego III', 'Lucas Hosseini']
  spec.email         = ['LPSego3+dev@gmail.com', 'lucas.hosseini@gmail.com']
  spec.summary       = 'Deserialization of JSONAPI params into the Rails ' \
                        'ActiveRecord format'
  spec.description   = 'DSL for converting JSON API payloads to ' \
                       'ActiveRecord compatible hashes'
  spec.homepage      = 'https://github.com/beauby/jsonapi-rails'
  spec.license       = 'MIT'

  spec.files         = Dir['README.md', 'lib/**/*']
  spec.require_path  = 'lib'

  spec.add_dependency 'jsonapi-deserializable', '0.1.1.beta2'
  # because this gem is intended for rails use, active_support will
  # already be included
  spec.add_dependency 'activesupport', '> 4.0'

  spec.add_development_dependency 'activerecord', '>=5'
  spec.add_development_dependency 'sqlite3', '>= 1.3.12'
  spec.add_development_dependency 'rake', '>=0.9'
  spec.add_development_dependency 'rspec', '~>3.4'
end
