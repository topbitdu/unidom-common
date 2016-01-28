# Unidom Common 常用领域模型引擎

[![License](https://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)
[![Gem Version](https://badge.fury.io/rb/unidom-common.svg)](https://badge.fury.io/rb/unidom-common)

Unidom (UNIfied Domain Object Model) is a series of domain model engines. The Common domain model engine includes the common models.
Unidom (统一领域对象模型)是一系列的领域模型引擎。常用领域模型引擎包括一些常用的模型。

## Usage in Gemfile
```ruby
gem 'unidom-common'
```

## Run the Database Migration
```shell
rake db:migrate
```
The migration enabled the PostgreSQL uuid-ossp extension.

## Include Concern in Models
```ruby
include Unidom::Common::Concerns::ModelExtension
```

## Auto Generated Methods
```ruby
class Project < ActiveRecord::Base

  include Unidom::Common::Concerns::ModelExtension

  validates :name, presence: true, length: { in: 2..200 }

  belongs_to :customer
  belongs_to :team

  # other fields: code, description

end

Project.coded_as('JIRA').valid_at(Time.now).alive(true)     # Same as Project.coded_as('JIRA').valid_at.alive
team.projects.valid_during('2015-01-01'..'2015-12-31').dead
Project.included_by([ id_1, id_2 ]).excluded_by id_3
```
