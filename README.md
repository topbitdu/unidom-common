# Unidom Common

Unidom (UNIfied Domain Object Model) is a series of domain model engines. The Common domain model engine includes the common models.
Unidom (统一领域对象模型)是一系列的领域模型引擎。常用领域模型引擎包括一些常用的模型。

## Usage in Gemfile:
```ruby
gem 'unidom-common'
```
## Run the Database Migration:
```shell
rake db:migrate
```

## Include Concern in Models:
```ruby
include Unidom::Common::Concerns::ModelExtension
```
