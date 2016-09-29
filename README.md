# Unidom Common 常用领域模型引擎

[![License](https://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)
[![Gem Version](https://badge.fury.io/rb/unidom-common.svg)](https://badge.fury.io/rb/unidom-common)
[![Dependency Status](https://gemnasium.com/badges/github.com/topbitdu/unidom-common.svg)](https://gemnasium.com/github.com/topbitdu/unidom-common)

Unidom (UNIfied Domain Object Model) is a series of domain model engines. The Common domain model engine includes the common models.
Unidom (统一领域对象模型)是一系列的领域模型引擎。常用领域模型引擎包括一些常用的模型。

## Recent Update
Check out the [Road Map](ROADMAP.md) to find out what's the next.
Check out the [Change Log](CHANGELOG.md) to find out what's new.

## Usage in Gemfile
```ruby
gem 'unidom-common'
```

## Run the Database Migration
```shell
rake db:migrate
```
The migration versions starts with 200001.
The migration enabled the PostgreSQL uuid-ossp extension.

## Include Concern in Models
```ruby
include Unidom::Common::Concerns::ModelExtension
```

## Model Extension concern
```ruby
class Project < ActiveRecord::Base

  include Unidom::Common::Concerns::ModelExtension

  validates :name,           presence: true, length: { in: 2..200 }
  validates :audition_state, presence: true, length: { is: 1 }

  belongs_to :customer
  belongs_to :team

  # other fields: code, description

end

Project.coded_as('JIRA').valid_at(Time.now).alive(true)     # Same as Project.coded_as('JIRA').valid_at.alive
team.projects.valid_during('2015-01-01'..'2015-12-31').dead
Project.included_by([ id_1, id_2 ]).excluded_by id_3
Project.created_after('2015-01-01 00:00:00')
Project.created_not_after('2015-01-01 00:00:00')
Project.created_before('2015-01-01 00:00:00')
Project.created_not_before('2015-01-01 00:00:00')
Project.audition_transited_to('A').transited_to('C')
```

## No-SQL Columns
```ruby
class Project < ActiveRecord::Base

  include Unidom::Common::Concerns::ModelExtension

  notation_column :creator_comment, :last_updater_comment
  notation_boolean_column :enabled

  validates :creator_comment,      allow_blank: true, length: { in: 2..200 }
  validates :last_updater_comment, allow_blank: true, length: { in: 2..200 }

end

project = Project.new
project.creator_comment = 'My first project.' # Stored in project.notation['columns']['creator_comment']
project.valid?                                # true

Project.notation_column_where(:creator_comment, :like, 'first') # Fuzzy search the creator_comment column
Project.notation_column_where(:creator_comment, '=', 'My first project.')

project.enabled = true
project.enabled? # true

Project.notation_boolean_column_where(:enabled, true) # All enabled projects
```

## Numeration
```ruby
binary = 'some string'
hex = Unidom::Common::Numeration.hex binary # "736f6d6520737472696e67"
# convert a binary (usually a string) to it's hex string

text = Unidom::Common::Numeration.rev_hex hex # "some string"
# convert a hex string to its text value
```

## AES 256 Cryptor
```ruby
class IdentityCard

  include Unidom::Common::Concerns::Aes256Cryptor
  attr_accessor :identification_number, :encrypted_identification_number

  def initialize(identification_number)
    self.identification_number = identification_number
    @aes_256_key = OpenSSL::Cipher::AES.new(256, 'CBC').random_key
  end

  def encrypt_identification_number
    encrypt identification_number, key: @aes_256_key
  end

  def decrypt_identification_number
    decrypt encrypted_identification_number, key: @aes_256_key
  end

  def cryption_padding
    8
  end
  # If the #cryption_padding method is missed, the default padding 9 is used instead

end

identification_number = '9527'
identity_card = IdentityCard.new '9527'
encrypted     = identity_card.encrypt_identification_number
decrypted     = identity_card.decrypt_identification_number
# The decrypted should equal to identification_number
# The AES 256 Cryptor also has the #hex_encrypt and the #hex_decrypt methods
```

## MD 5 Digester
```ruby
class IdentityCard

  include Unidom::Common::Concerns::Md5Digester
  attr_accessor :identification_number

  def initialize(identification_number)
    self.identification_number = identification_number
  end

  def digest_identification_number
    digest identification_number, pepper: self.class.name
  end

  def hex_digest_identification_number
    hex_digest identification_number, pepper: self.class.name
  end

end

identity_card = IdentityCard.new '9527'
digested      = identity_card.digest_identification_number
hex_digested  = identity_card.hex_digest_identification_number
hex_digested == Unidom::Common::Numeration.hex digested # true
```

## SHA 256 Digester
```ruby
class IdentityCard

  include Unidom::Common::Concerns::Sha256Digester
  attr_accessor :identification_number

  def initialize(identification_number)
    self.identification_number = identification_number
  end

  def digest_identification_number
    digest identification_number, pepper: self.class.name
  end

  def hex_digest_identification_number
    hex_digest identification_number, pepper: self.class.name
  end

end

identity_card = IdentityCard.new '9527'
digested      = identity_card.digest_identification_number
hex_digested  = identity_card.hex_digest_identification_number
hex_digested == Unidom::Common::Numeration.hex digested # true
```

## SHA 384 Digester
```ruby
class IdentityCard

  include Unidom::Common::Concerns::Sha384Digester
  attr_accessor :identification_number

  def initialize(identification_number)
    self.identification_number = identification_number
  end

  def digest_identification_number
    digest identification_number, pepper: self.class.name
  end

  def hex_digest_identification_number
    hex_digest identification_number, pepper: self.class.name
  end

end

identity_card = IdentityCard.new '9527'
digested      = identity_card.digest_identification_number
hex_digested  = identity_card.hex_digest_identification_number
hex_digested == Unidom::Common::Numeration.hex digested # true
```

## SHA 512 Digester
```ruby
class IdentityCard

  include Unidom::Common::Concerns::Sha512Digester
  attr_accessor :identification_number

  def initialize(identification_number)
    self.identification_number = identification_number
  end

  def digest_identification_number
    digest identification_number, pepper: self.class.name
  end

  def hex_digest_identification_number
    hex_digest identification_number, pepper: self.class.name
  end

end

identity_card = IdentityCard.new '9527'
digested      = identity_card.digest_identification_number
hex_digested  = identity_card.hex_digest_identification_number
hex_digested == Unidom::Common::Numeration.hex digested # true
```


## SHA 1 Digester
```ruby
class IdentityCard

  include Unidom::Common::Concerns::Sha1Digester
  attr_accessor :identification_number

  def initialize(identification_number)
    self.identification_number = identification_number
  end

  def digest_identification_number
    digest identification_number, pepper: self.class.name
  end

  def hex_digest_identification_number
    hex_digest identification_number, pepper: self.class.name
  end

end

identity_card = IdentityCard.new '9527'
digested      = identity_card.digest_identification_number
hex_digested  = identity_card.hex_digest_identification_number
hex_digested == Unidom::Common::Numeration.hex digested # true
```


## SHA 2 Digester
```ruby
class IdentityCard

  include Unidom::Common::Concerns::Sha1Digester
  attr_accessor :identification_number

  def initialize(identification_number)
    self.identification_number = identification_number
  end

  def digest_identification_number
    digest identification_number, pepper: self.class.name
  end

  def hex_digest_identification_number
    hex_digest identification_number, pepper: self.class.name
  end

end

identity_card = IdentityCard.new '9527'
digested      = identity_card.digest_identification_number
hex_digested  = identity_card.hex_digest_identification_number
hex_digested == Unidom::Common::Numeration.hex digested # true
```


## ActiveRecord Migration Naming Convention
### Domain Models (200YMMDDHHMMSS)

<table class='table table-striped table-hover'>
  <caption></caption>
  <thead>

    <tr>
      <th>Ruby Gem</th>
      <th>Migration</th>
      <th>Model</th>
      <th>Description</th>
    </tr>

  </thead>
  <tbody>

    <tr>
      <td>[![unidom-common](https://badge.fury.io/rb/unidom-common.svg)](https://github.com/topbitdu/unidom-common)</td>
      <td>200001DDHHMMSS</td>
      <td>-</td>
      <td>The Common domain model engine includes the common models. 常用领域模型引擎包括一些常用的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-visitor](https://badge.fury.io/rb/unidom-visitor.svg)](https://github.com/topbitdu/unidom-visitor)</td>
      <td>200002DDHHMMSS</td>
      <td>
        - Identificating
        - Authenticating
        - Recognization
        - User
        - Guest
        - Password
      </td>
      <td>The Visitor domain model engine includes Identificating, Authenticating, Recognization, Visitor (User &amp; Guest), and Password models. 访问者领域模型引擎包括身份标识、身份鉴别、身份识别、访问者（用户和游客）、密码的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-category](https://badge.fury.io/rb/unidom-category.svg)](https://github.com/topbitdu/unidom-category)</td>
      <td>200003DDHHMMSS</td>
      <td>
        - Category
        - Categorizing
        - Category Rollup
        - Category Associating
      </td>
      <td>The Category domain model engine includes Category and its relative models. 类别领域模型引擎包括类别及其相关的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-authorization](https://badge.fury.io/rb/unidom-authorization.svg)](https://github.com/topbitdu/unidom-authorization)</td>
      <td>200004DDHHMMSS</td>
      <td>
        - Permission
        - Authorizing
      </td>
      <td>The Authorization domain model engine includes the Permission and Authorizing models. 授权领域模型引擎包括权限、授权的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-action](https://badge.fury.io/rb/unidom-action.svg)](https://github.com/topbitdu/unidom-action)</td>
      <td>200005DDHHMMSS</td>
      <td>
        - Reason
        - State Transition
        - Obsolescence
        - Acting
      </td>
      <td>The Action domain model engine includes the Reason, State Transition, Obsolescene, and the Acting models. 审计领域模型引擎包括原因、状态迁移、废弃和行为日志的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-standard](https://badge.fury.io/rb/unidom-standard.svg)](https://github.com/topbitdu/unidom-standard)</td>
      <td>200006DDHHMMSS</td>
      <td>
        - Standard
        - Standard Associating
      </td>
      <td>The Standard domain model engine includes the Standard model and the Standard Associating model. 标准领域模型引擎包括行为标准和标准关联的模型。</td>
    </tr>


    <tr>
      <td>[![unidom-party](https://badge.fury.io/rb/unidom-party.svg)](https://github.com/topbitdu/unidom-party)</td>
      <td>200101DDHHMMSS</td>
      <td>
        - Person
        - Shop
        - Company
        - Government Agency
        - Party Relation
      </td>
      <td>The Party domain model engine includes the Person, Shop, Company, Government Agency, and the Party Relation models. 参与者领域模型引擎包括个人、店铺、公司、政府机构、参与者关系的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-certificate](https://badge.fury.io/rb/unidom-certificate.svg)](https://github.com/topbitdu/unidom-certificate)</td>
      <td>200102DDHHMMSS</td>
      <td>
        - Certificating
      </td>
      <td>The Certificate domain model engine includes the Certificating model.
证书领域模型引擎包括证书认证的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-contact](https://badge.fury.io/rb/unidom-contact.svg)](https://github.com/topbitdu/unidom-contact)</td>
      <td>200103DDHHMMSS</td>
      <td>
        - Contact Subscription
        - Email Address
      </td>
      <td>The Contact domain model engine includes the Contact Subscription and Email Address models. 联系方式领域模型引擎包括联系方式订阅和电子邮箱地址的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-geo](https://badge.fury.io/rb/unidom-geo.svg)](https://github.com/topbitdu/unidom-geo)</td>
      <td>200104DDHHMMSS</td>
      <td>
        - Location
        - Locating
      </td>
      <td>The Geo domain model engine includes the Location and Locating models. 地理领域模型引擎包括位置和定位的模型。</td>
    </tr>


    <tr>
      <td>[![unidom-article_number](https://badge.fury.io/rb/unidom-article_number.svg)](https://github.com/topbitdu/unidom-article_number)</td>
      <td>200201DDHHMMSS</td>
      <td>
        - Marking
        - EAN 13 Barcode
        - EAN 8 Barcode
      </td>
      <td>The Article Number domain model engine includes Marking, EAN-13, and EAN-8 models. 物品编码领域模型引擎包括打码、EAN-13和EAN-8的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-product](https://badge.fury.io/rb/unidom-product.svg)](https://github.com/topbitdu/unidom-product)</td>
      <td>200202DDHHMMSS</td>
      <td>
        - Product
        - Product Associating
      </td>
      <td>The Product domain model engine includes Product and Produt Associating models. 产品领域模型引擎包括产品和产品关联的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-price](https://badge.fury.io/rb/unidom-price.svg)](https://github.com/topbitdu/unidom-price)</td>
      <td>200203DDHHMMSS</td>
      <td>
        - Price
      </td>
      <td>The Price domain model engine includes Price and its relative models. 价格领域模型引擎包括定价及其相关的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-shopping](https://badge.fury.io/rb/unidom-shopping.svg)](https://github.com/topbitdu/unidom-shopping)</td>
      <td>200205DDHHMMSS</td>
      <td>
        - Shopping Cart
        - Shopping Item
      </td>
      <td>The Shopping domain model engine includes Shopping Cart and Shopping Item models. 购物领域模型引擎包括购物车和购物项的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-order](https://badge.fury.io/rb/unidom-order.svg)](https://github.com/topbitdu/unidom-order)</td>
      <td>200206DDHHMMSS</td>
      <td>
        - Order
        - Order Item
        - Order Adjustment
      </td>
      <td>The Order domain model engine includes Order, Order Item, and Order Adjustment models. 订单领域模型引擎包括订单、订单项和订单调整的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-inventory](https://badge.fury.io/rb/unidom-inventory.svg)](https://github.com/topbitdu/unidom-inventory)</td>
      <td>200209DDHHMMSS</td>
      <td>
        - Serialized Inventory Item
        - Grouped Inventory Item
        - Lot
        - Inventory Item Variance
      </td>
      <td>The Inventory domain model engine includes the Serialized Inventory Item, the Grouped Inventory Item, the Lot, and the Inventory Item Variance models. 库存领域模型引擎包括序列化库存项、分组库存项、批量和库存项变化的模型。</td>
    </tr>

    <tr>
      <td>[![unidom-shipment](https://badge.fury.io/rb/unidom-shipment.svg)](https://github.com/topbitdu/unidom-shipment)</td>
      <td>200210DDHHMMSS</td>
      <td>
        - Shipment
        - Shipment Item
        - Shipment Package
        - Shipment Package Item
        - Shipment Receipt
      </td>
      <td>The Shipment domain model engine includes the Shipment, Shipment Item, Shipment Package, Shipment Package Item, and Shipment Receipt model. 装运领域模型引擎包括装运、装运项、装运包裹、装运包裹项、装运收据的模型。</td>
    </tr>


    <tr>
      <td>[![unidom-position](https://badge.fury.io/rb/unidom-position.svg)](https://github.com/topbitdu/unidom-position)</td>
      <td>200402DDHHMMSS</td>
      <td>
        - Occupation
        - Position
        - Post
        - Position Reporting Structure
      </td>
      <td>The Position domain model engine includes the Occupation, Position, Post, and Position Reporting Structure models.
职位领域模型引擎包括职业、职位、岗位及岗位报告关系模型。</td>
    </tr>

    <tr>
      <td>[![unidom-accession](https://badge.fury.io/rb/unidom-accession.svg)](https://github.com/topbitdu/unidom-accession)</td>
      <td>200405DDHHMMSS</td>
      <td>
        - Post Fulfillment
      </td>
      <td>The Position domain model engine includes the Post Fulfillment and its relative models. 就职领域模型引擎包括岗位履行及其相关的模型。</td>
    </tr>


  </tbody>
</table>

### Country Extensions (200YMM9NNNMMSS)
The YMM part should be identical to the relative part of the Domain Models.
The NNN is the numeric code of [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1 "codes for the names of countries, dependent territories, and special areas of geographical interest").
The numeric code of China is 156.
* unidom-certificate-china: 2001029156MMSS
* unidom-contact-china:     2001039156MMSS
* unidom-geo-china:         2001049156MMSS
