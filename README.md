# Unidom Common 常用领域模型引擎

[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/unidom-common/frames)
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
The migrations enabled the PostgreSQL uuid-ossp extension and the pgcrypto extension.



## Include Concern in Models

```ruby
include Unidom::Common::Concerns::ModelExtension
```



## Constants

```ruby
Unidom::Common::NULL_UUID      # '00000000-0000-0000-0000-000000000000'
Unidom::Common::MAXIMUM_AMOUNT # 1_000_000_000
Unidom::Common::SELF           # '~'

Unidom::Common::OPENED_AT # Time.utc(1970)
Unidom::Common::CLOSED_AT # Time.utc(3000)

Unidom::Common::FROM_DATE # '1970-01-01'
Unidom::Common::THRU_DATE # '3000-01-01'

```

## Model Extension concern

```ruby
class Project < ActiveRecord::Base

  include Unidom::Common::Concerns::ModelExtension

  validates :name,           presence: true, length: { in: 2..200 }
  validates :audition_state, presence: true, length: { is: 1 }

  belongs_to :customer
  belongs_to :team
  belongs_to :place

  code :process, Process
  # Process is a enum type per ProgneTapera,
  # the typical values are: waterfall, agile, lean, scrum, extreme_programming, and etc.

  # other fields: code, description

  def kick_off(in: nil)
    assert_present! :in, in
    # An argument error is raised if in is blank.

    self.place = in
  end

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



## Exact Columns

```ruby
# db/migrate/YYYYMMDDHHMMSS_create_people.rb
class CreatePeople < ActiveRecord::Migration[5.0]

  def change

    create_table :people, id: :uuid do |t|

      t.string :name, null: false, default: '', limit: 200

      t.string :passport_number, null: false, default: nil, limit: 200

      t.binary :identification_number_exact_signature, null: false, default: nil, limit: 80
      t.binary :passport_number_exact_signature,       null: false, default: nil, limit: 80

      t.column   :state, 'char(1)', null: false, default: 'C'
      t.datetime :opened_at,        null: false, default: Time.utc(1970)
      t.datetime :closed_at,        null: false, default: Time.utc(3000)
      t.boolean  :defunct,          null: false, default: false
      t.jsonb    :notation,         null: false, default: {}

      t.timestamps null: false

    end

    add_index :people, :identification_number_exact_signature, unique: true
    add_index :people, :passport_number_exact_signature,       unique: true

  end

end

# app/models/person.rb
class Person < ApplicationRecord

  include Unidom::Common::Concerns::ModelExtension

  attr_accessor :identification_number
  # The identification number is not stored. Only the exact signature is stored like password.
  exact_column  :identification_number, :passport_number
  # The passport number is stored in the clear text format.

end

# in any controller or rails console:
person = Person.new name: 'Tim', identification_number: '11010119901231001X', passport_number: 'E00000000'
person.save!
Person.identification_number_is('11010119901231001X').first==person # true
Person.passport_number_is('E00000000').first==person                # true
```



## Secure Column

```ruby
# db/migrate/YYYYMMDDHHMMSS_create_orderings.rb
class CreateOrderings < ActiveRecord::Migration[5.0]

  def change

    create_table :orderings, id: :uuid do |t|

      t.string :placer_name,   null: false, default: nil, limit: 200
      t.string :taker_name,    null: false, default: nil, limit: 200
      t.string :receiver_name, null: false, default: nil, limit: 200

      t.jsonb :placer
      t.jsonb :taker
      t.jsonb :receiver

      t.binary :placer_identification_number_exact_signature,   null: false, default: nil, limit: 80
      t.binary :placer_mobile_phone_number_exact_signature,     null: false, default: nil, limit: 80
      t.binary :taker_identification_number_exact_signature,    null: false, default: nil, limit: 80
      t.binary :taker_mobile_phone_number_exact_signature,      null: false, default: nil, limit: 80
      t.binary :receiver_identification_number_exact_signature, null: false, default: nil, limit: 80
      t.binary :receiver_mobile_phone_number_exact_signature,   null: false, default: nil, limit: 80

      t.column   :state, 'char(1)', null: false, default: 'C'
      t.datetime :opened_at,        null: false, default: Time.utc(1970)
      t.datetime :closed_at,        null: false, default: Time.utc(3000)
      t.boolean  :defunct,          null: false, default: false
      t.jsonb    :notation,         null: false, default: {}

      t.timestamps

    end

    add_index :orderings, :placer_identification_number_exact_signature,   name: :index_orderings_on_placer_identification_number
    add_index :orderings, :placer_mobile_phone_number_exact_signature,     name: :index_orderings_on_placer_mobile_phone_number
    add_index :orderings, :taker_identification_number_exact_signature,    name: :index_orderings_on_taker_identification_number
    add_index :orderings, :taker_mobile_phone_number_exact_signature,      name: :index_orderings_on_taker_mobile_phone_number
    add_index :orderings, :receiver_identification_number_exact_signature, name: :index_orderings_on_receiver_identification_number
    add_index :orderings, :receiver_mobile_phone_number_exact_signature,   name: :index_orderings_on_receiver_mobile_phone_number

  end

end

# app/models/orderings.rb
class Ordering < ApplicationRecord

  include Unidom::Common::Concerns::ModelExtension

  validates :placer_name,   presence: true, length: { in: 2..columns_hash['placer_name'].limit   }
  validates :taker_name,    presence: true, length: { in: 2..columns_hash['taker_name'].limit    }
  validates :receiver_name, presence: true, length: { in: 2..columns_hash['receiver_name'].limit }

  validates :placer_address,   presence: true, length: { in: 2..200 }
  validates :taker_address,    presence: true, length: { in: 2..200 }
  validates :receiver_address, presence: true, length: { in: 2..200 }

  validates :placer_identification_number,   presence: true, length: { is: 18 }, format: Unidom::Certificate::China::IdentityCard::FORMAT_VALIDATION_REGEX
  validates :taker_identification_number,    presence: true, length: { is: 18 }, format: Unidom::Certificate::China::IdentityCard::FORMAT_VALIDATION_REGEX
  validates :receiver_identification_number, presence: true, length: { is: 18 }, format: Unidom::Certificate::China::IdentityCard::FORMAT_VALIDATION_REGEX

  validates :placer_mobile_phone_number,   presence: true, length: { is: 11 }, numericality: { integer_only: true }, format: Unidom::Contact::China::MobilePhoneNumber::FORMAT_VALIDATION_REGEX
  validates :taker_mobile_phone_number,    presence: true, length: { is: 11 }, numericality: { integer_only: true }, format: Unidom::Contact::China::MobilePhoneNumber::FORMAT_VALIDATION_REGEX
  validates :receiver_mobile_phone_number, presence: true, length: { is: 11 }, numericality: { integer_only: true }, format: Unidom::Contact::China::MobilePhoneNumber::FORMAT_VALIDATION_REGEX

  exact_column :placer_identification_number,   :placer_mobile_phone_number
  exact_column :taker_identification_number,    :taker_mobile_phone_number
  exact_column :receiver_identification_number, :receiver_mobile_phone_number

  secure_column :placer,   fields: [ :placer_name,   :placer_address,   :placer_identification_number,   :placer_mobile_phone_number   ]
  secure_column :taker,    fields: [ :taker_name,    :taker_address,    :taker_identification_number,    :taker_mobile_phone_number    ]
  secure_column :receiver, fields: [ :receiver_name, :receiver_address, :receiver_identification_number, :receiver_mobile_phone_number ]

end

# in any controller or rails console:
@placer_name   = 'Tim'
@taker_name    = 'Bob'
@receiver_name = 'Roy'

@placer_identification_number   = '11022119801231999X'
@taker_identification_number    = '350105199006184567'
@receiver_identification_number = '532307200001010003'

@placer_mobile_phone_number   = '13987654321'
@taker_mobile_phone_number    = '18812345678'
@receiver_mobile_phone_number = '17101020304'

@placer_address   = 'Beijing'
@taker_address    = 'Jiangsu'
@receiver_address = 'Guizhou'

@ordering = Ordering.new opened_at: Time.now,
  placer_name:      @placer_name,
  taker_name:       @taker_name,
  receiver_name:    @receiver_name,
  placer_address:   @placer_address,
  taker_address:    @taker_address,
  receiver_address: @receiver_address,
  placer_identification_number:   @placer_identification_number,
  taker_identification_number:    @taker_identification_number,
  receiver_identification_number: @receiver_identification_number,
  placer_mobile_phone_number:     @placer_mobile_phone_number,
  taker_mobile_phone_number:      @taker_mobile_phone_number,
  receiver_mobile_phone_number:   @receiver_mobile_phone_number
@ordering.save!

ordering_1 = Ordering.placer_identification_number_is(@placer_identification_number).valid_at.alive.first
ordering_2 = Ordering.taker_identification_number_is(@taker_identification_number).valid_at.alive.first
ordering_3 = Ordering.receiver_identification_number_is(@receiver_identification_number).valid_at.alive.first
ordering_4 = Ordering.placer_mobile_phone_number_is(@placer_mobile_phone_number).valid_at.alive.first
ordering_5 = Ordering.taker_mobile_phone_number_is(@taker_mobile_phone_number).valid_at.alive.first
ordering_6 = Ordering.receiver_mobile_phone_number_is(@receiver_mobile_phone_number).valid_at.alive.first
# @ordering should be identical to any of ordering_1, ordering_2, ordering_3, ordering_4, ordering_5, or ordering_6
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



## Engine Extension concern

```ruby
module EngineName
  class Engine < ::Rails::Engine
    include Unidom::Common::EngineExtension
    enable_initializer enum_enabled: true, migration_enabled: true
  end
end
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
      <td><a href="https://github.com/topbitdu/unidom-common">unidom-common</a></td>
      <td>200001DDHHMMSS</td>
      <td>-</td>
      <td>The Common domain model engine includes the common models. 常用领域模型引擎包括一些常用的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-visitor">unidom-visitor</a></td>
      <td>200002DDHHMMSS</td>
      <td>
        <ul>
          <li>Identificating</li>
          <li>Authenticating</li>
          <li>Recognization</li>
          <li>User</li>
          <li>Guest</li>
          <li>Password</li>
        <ul>
      </td>
      <td>The Visitor domain model engine includes Identificating, Authenticating, Recognization, Visitor (User &amp; Guest), and Password models. 访问者领域模型引擎包括身份标识、身份鉴别、身份识别、访问者（用户和游客）、密码的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-category">unidom-category</a></td>
      <td>200003DDHHMMSS</td>
      <td>
        <ul>
          <li>Category</li>
          <li>Categorizing</li>
          <li>Category Rollup</li>
          <li>Category Associating</li>
        <ul>
      </td>
      <td>The Category domain model engine includes Category and its relative models. 类别领域模型引擎包括类别及其相关的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-authorization">unidom-authorization</a></td>
      <td>200004DDHHMMSS</td>
      <td>
        <ul>
          <li>Permission</li>
          <li>Authorizing</li>
        <ul>
      </td>
      <td>The Authorization domain model engine includes the Permission and Authorizing models. 授权领域模型引擎包括权限、授权的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-action">unidom-action</a></td>
      <td>200005DDHHMMSS</td>
      <td>
        <ul>
          <li>Reason</li>
          <li>State Transition</li>
          <li>Obsolescing</li>
          <li>Acting</li>
        </ul>
      </td>
      <td>The Action domain model engine includes the Reason, State Transition, Obsolescing, and the Acting models. 审计领域模型引擎包括原因、状态迁移、废弃和行为日志的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-standard">unidom-standard</a></td>
      <td>200006DDHHMMSS</td>
      <td>
        <ul>
          <li>Standard</li>
          <li>Standard Associating</li>
        </ul>
      </td>
      <td>The Standard domain model engine includes the Standard model and the Standard Associating model. 标准领域模型引擎包括行为标准和标准关联的模型。</td>
    </tr>


    <tr>
      <td><a href="https://github.com/topbitdu/unidom-party">unidom-party</a></td>
      <td>200101DDHHMMSS</td>
      <td>
        <ul>
          <li>Person</li>
          <li>Shop</li>
          <li>Company</li>
          <li>Government Agency</li>
          <li>Party Relation</li>
        </ul>
      </td>
      <td>The Party domain model engine includes the Person, Shop, Company, Government Agency, and the Party Relation models. 参与者领域模型引擎包括个人、店铺、公司、政府机构、参与者关系的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-certificate">unidom-certificate</a></td>
      <td>200102DDHHMMSS</td>
      <td>
        <ul>
          <li>Certificating</li>
        </ul>
      </td>
      <td>The Certificate domain model engine includes the Certificating model.
证书领域模型引擎包括证书认证的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-contact">unidom-contact</a></td>
      <td>200103DDHHMMSS</td>
      <td>
        <ul>
          <li>Contact Subscription</li>
          <li>Email Address</li>
        </ul>
      </td>
      <td>The Contact domain model engine includes the Contact Subscription and Email Address models. 联系方式领域模型引擎包括联系方式订阅和电子邮箱地址的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-geo">unidom-geo</a></td>
      <td>200104DDHHMMSS</td>
      <td>
        <ul>
          <li>Location</li>
          <li>Locating</li>
        </ul>
      </td>
      <td>The Geo domain model engine includes the Location and Locating models. 地理领域模型引擎包括位置和定位的模型。</td>
    </tr>


    <tr>
      <td><a href="https://github.com/topbitdu/unidom-article_number">unidom-article_number</a></td>
      <td>200201DDHHMMSS</td>
      <td>
        <ul>
          <li>Marking</li>
          <li>EAN 13 Barcode</li>
          <li>EAN 8 Barcode</li>
        </ul>
      </td>
      <td>The Article Number domain model engine includes Marking, EAN-13, and EAN-8 models. 物品编码领域模型引擎包括打码、EAN-13和EAN-8的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-product">unidom-product</a></td>
      <td>200202DDHHMMSS</td>
      <td>
        <ul>
          <li>Product</li>
          <li>Product Associating</li>
        </ul>
      </td>
      <td>The Product domain model engine includes Product and Produt Associating models. 产品领域模型引擎包括产品和产品关联的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-price">unidom-price</a></td>
      <td>200203DDHHMMSS</td>
      <td>
        <ul>
          <li>Price</li>
        </ul>
      </td>
      <td>The Price domain model engine includes Price and its relative models. 价格领域模型引擎包括定价及其相关的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-shopping">unidom-shopping</a></td>
      <td>200205DDHHMMSS</td>
      <td>
        <ul>
          <li>Shopping Cart</li>
          <li>Shopping Item</li>
        </ul>
      </td>
      <td>The Shopping domain model engine includes Shopping Cart and Shopping Item models. 购物领域模型引擎包括购物车和购物项的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-order">unidom-order</a></td>
      <td>200206DDHHMMSS</td>
      <td>
        <ul>
          <li>Order</li>
          <li>Order Item</li>
          <li>Order Adjustment</li>
        </ul>
      </td>
      <td>The Order domain model engine includes Order, Order Item, and Order Adjustment models. 订单领域模型引擎包括订单、订单项和订单调整的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-inventory">unidom-inventory</a></td>
      <td>200209DDHHMMSS</td>
      <td>
        <ul>
          <li>Serialized Inventory Item</li>
          <li>Grouped Inventory Item</li>
          <li>Lot</li>
          <li>Inventory Item Variance</li>
        </ul>
      </td>
      <td>The Inventory domain model engine includes the Serialized Inventory Item, the Grouped Inventory Item, the Lot, and the Inventory Item Variance models. 库存领域模型引擎包括序列化库存项、分组库存项、批量和库存项变化的模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-shipment">unidom-shipment</a></td>
      <td>200210DDHHMMSS</td>
      <td>
        <ul>
          <li>Shipment</li>
          <li>Shipment Item</li>
          <li>Shipment Package</li>
          <li>Shipment Package Item</li>
          <li>Shipment Receipt</li>
        </ul>
      </td>
      <td>The Shipment domain model engine includes the Shipment, Shipment Item, Shipment Package, Shipment Package Item, and Shipment Receipt model. 装运领域模型引擎包括装运、装运项、装运包裹、装运包裹项、装运收据的模型。</td>
    </tr>


    <tr>
      <td><a href="https://github.com/topbitdu/unidom-position">unidom-position</a></td>
      <td>200402DDHHMMSS</td>
      <td>
        <ul>
          <li>Occupation</li>
          <li>Position</li>
          <li>Post</li>
          <li>Position Reporting Structure</li>
        </ul>
      </td>
      <td>The Position domain model engine includes the Occupation, Position, Post, and Position Reporting Structure models.
职位领域模型引擎包括职业、职位、岗位及岗位报告关系模型。</td>
    </tr>

    <tr>
      <td><a href="https://github.com/topbitdu/unidom-accession">unidom-accession</a></td>
      <td>200405DDHHMMSS</td>
      <td>
        <ul>
          <li>Post Fulfillment</li>
        </ul>
      </td>
      <td>The Accession domain model engine includes the Post Fulfillment and its relative models. 就职领域模型引擎包括岗位履行及其相关的模型。</td>
    </tr>


  </tbody>
</table>

### Country Extensions (200YMM9NNNMMSS)

The YMM part should be identical to the relative part of the Domain Models.
The NNN is the numeric code of [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1 "codes for the names of countries, dependent territories, and special areas of geographical interest").
The numeric code of China is 156.
* unidom-party-china:       2001019156MMSS
* unidom-certificate-china: 2001029156MMSS
* unidom-contact-china:     2001039156MMSS
* unidom-geo-china:         2001049156MMSS



## Configuration

unidom-common and its relative Ruby gems are configurable. Create your own ``config/initializers/unidom.rb`` file in your project as following:
```ruby
Unidom::Common.configure do |options|

  # The migrations inside the following namespaces will be ignored. The models inside the following namespaces won't be defined.
  options[:neglected_namespaces] = %w{
    Unidom::Party
    Unidom::Visitor
  }

end
```
The Unidom::Party::Person, the Unidom::Visitor::User, and other models under the listed namespaces won't be defined. Their migrations won't run.
But the models under the Unidom::Party::China namespace, if there is any, are defined, and their migrations will run as usual.
