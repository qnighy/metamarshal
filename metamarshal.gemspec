# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metamarshal/version'

Gem::Specification.new do |spec|
  spec.name          = 'metamarshal'
  spec.version       = Metamarshal::VERSION
  spec.authors       = ['Masaki Hara']
  spec.email         = ['ackie.h.gmai@gmail.com']

  spec.summary       = 'Pure Ruby Marshal'
  spec.description   = 'Marshal-compatible loader/dumper implemented in pure' \
                       'Ruby. Allows you to manipulate syntax before loading.'
  spec.homepage      = 'https://github.com/qnighy/metamarshal'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0.12.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.75.1'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.3.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5'
  spec.add_development_dependency 'rubocop-rake', '~> 0.4.0'
end
