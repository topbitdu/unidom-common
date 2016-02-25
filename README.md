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

## ActiveRecord Migration Naming Convention
### Domain Models (200YMMDDHHMMSS)
* unidom-common: 200001DDHHMMSS
* unidom-visitor: 200002DDHHMMSS
* unidom-category: 200003DDHHMMSS
* unidom-authorization: 200004DDHHMMSS
* unidom-accounting: 200005DDHHMMSS
* unidom-party: 200101DDHHMMSS
* unidom-certificate: 200102DDHHMMSS
* unidom-contact: 200103DDHHMMSS
* unidom-geo: 200104DDHHMMSS
* unidom-property: 200105DDHHMMSS
* unidom-article_number: 200201DDHHMMSS
* unidom-product: 200202DDHHMMSS
* unidom-price: 200203DDHHMMSS
* unidom-commodity: 200204DDHHMMSS
* unidom-shopping: 200205DDHHMMSS
* unidom-order: 200206DDHHMMSS
* unidom-promotion: 200207DDHHMMSS
* unidom-payment: 200208DDHHMMSS

### Country Extensions (200YMM9NNNMMSS)
The YMM part should be identical to the relative part of the Domain Models.
The NNN is the numeric code of [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1 "codes for the names of countries, dependent territories, and special areas of geographical interest").
The numeric code of China is 156.
* unidom-certificate-china: 2001029156MMSS
* unidom-contact-china: 2001039156MMSS
* unidom-geo-china: 2001049156MMSS
