lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
#$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require 'unidom/common/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'unidom-common'
  spec.version     = Unidom::Common::VERSION
  spec.authors     = [ 'Topbit Du' ]
  spec.email       = [ 'topbit.du@gmail.com' ]
  spec.homepage    = 'http://github.com/topbitdu/unidom-common'
  spec.summary     = 'The Common domain model engine includes the common models.'
  spec.description = 'Unidom (UNIfied Domain Object Model) is a series of domain model engines. The Common domain model engine includes the common models. Unidom (统一领域对象模型)是一系列的领域模型引擎。常用领域模型引擎包括一些常用的模型。'
  spec.license     = 'MIT'

  spec.files = Dir[ '{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md' ]

  spec.add_dependency 'rails', '~> 4.2'
  spec.add_dependency 'pg',    '~> 0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake',    '~> 10.0'

end
