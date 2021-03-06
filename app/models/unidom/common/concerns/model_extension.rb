##
# Model Extension 是通用的模型扩展关注点，提供参数验证、JSON 注解字段、加密字段等。

module Unidom::Common::Concerns::ModelExtension

  extend ActiveSupport::Concern

  include Unidom::Common::Concerns::ArgumentValidation
  include Unidom::Common::Concerns::NotationColumn
  include Unidom::Common::Concerns::SecureColumn

  included do |includer|

    validates :state, presence: true, length: { is: columns_hash['state'].limit }

    scope :included_by, ->(inclusion) { where     id: inclusion }
    scope :excluded_by, ->(exclusion) { where.not id: exclusion }

    scope :transited_to, ->(states) { where state: states }

    scope :valid_at,       ->(now: Time.now) { where "? BETWEEN #{includer.table_name}.opened_at AND #{includer.table_name}.closed_at", now }
    scope :valid_duration, ->(range)         { where "(#{includer.table_name}.opened_at BETWEEN ? AND ?) OR (#{includer.table_name}.closed_at <= ? AND #{includer.table_name}.closed_at >= ?)", range.min, range.max, range.max, range.min }

    scope :alive, ->(living:  true) { where defunct: !living }
    scope :dead,  ->(defunct: true) { where defunct: defunct }

    if columns_hash['ordinal'].present?&&:integer==columns_hash['ordinal'].type
      validates :ordinal, presence: true, numericality: { only_integer: true, greater_than: 0 }
      scope :ordinal_is, ->(ordinal) { where ordinal: ordinal }
    end

    if columns_hash['uuid'].present?&&:uuid==columns_hash['uuid'].type
      validates :uuid, presence: true, length: { is: 36 }
      scope :uuid_is, ->(uuid) { where uuid: uuid }
    end

    if columns_hash['elemental'].present?&&:boolean==columns_hash['elemental'].type
      scope :primary, ->(elemental = true) { where elemental: elemental }
    end

    if columns_hash['grade'].present?&&:integer==columns_hash['grade'].type
      validates :grade, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      scope :grade_is,          ->(grade) { where grade: grade }
      scope :grade_higher_than, ->(grade) { where "grade > :grade", grade: grade }
      scope :grade_lower_than,  ->(grade) { where "grade < :grade", grade: grade }
    end

    if columns_hash['priority'].present?&&:integer==columns_hash['priority'].type
      validates :priority, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      scope :priority_is,          ->(priority) { where priority: priority }
      scope :priority_higher_than, ->(priority) { where "priority > :priority", priority: priority }
      scope :priority_lower_than,  ->(priority) { where "priority < :priority", priority: priority }
    end

    if columns_hash['slug'].present?&&:string==columns_hash['slug'].type
      validates :slug, presence: true, length: { in: 1..columns_hash['slug'].limit }, uniqueness: true
      scope :slug_is, ->(slug) { where slug: slug }
      before_validation -> {
        prefix = build_slug.to_s[0..(self.class.columns_hash['slug'].limit-37)]
        unique = prefix
        while includer.slug_is(unique).count>0
          unique = "#{prefix}-#{::SecureRandom.uuid}"
        end
        self.slug = unique
      }, on: :create
      # on update: re-generate the slug if the slug was assigned to empty.
      # to_query:  escape characters
    end

    columns_hash.each do |column_name, hash|

      name = column_name.to_s

      if ('code'==name||name.ends_with?('_code'))&&:string==columns_hash[name].type
        class_eval do
          if columns_hash[name].null
            validates name.to_sym, allow_blank: true, length: { maximum: columns_hash[name].limit }
            scope "#{name}_length_is".to_sym, ->(length) { where "LENGTH(#{name}) = :length", length: length }
          elsif columns_hash[name].limit<=4
            validates name.to_sym, presence: true, length: { is: columns_hash[name].limit }
          else
            validates name.to_sym, presence: true, length: { maximum: columns_hash[name].limit }
          end
          scope "#{name}d_as".to_sym,     ->(code) { where     name => to_code(code) }
          scope "not_#{name}d_as".to_sym, ->(code) { where.not name => to_code(code) }
          scope "#{name}_starting_with".to_sym, ->(prefix) { where "#{name} LIKE :prefix", prefix: "#{prefix}%" }
          scope "#{name}_ending_with".to_sym,   ->(suffix) { where "#{name} LIKE :suffix", suffix: "%#{suffix}" }
        end
      end

      if name.ends_with?('_at')&&:datetime==columns_hash[name].type
        matched = /\A(.+)_at\z/.match name
        class_eval do
          scope :"#{matched[1]}_on",         ->(date)  { where name => date.beginning_of_day..date.end_of_day }
          scope :"#{matched[1]}_during",     ->(range) { where name => range }
          scope :"#{matched[1]}_before",     ->(time)  { where "#{table_name}.#{name} <  :time", time: time }
          scope :"#{matched[1]}_not_after",  ->(time)  { where "#{table_name}.#{name} <= :time", time: time }
          scope :"#{matched[1]}_after",      ->(time)  { where "#{table_name}.#{name} >  :time", time: time }
          scope :"#{matched[1]}_not_before", ->(time)  { where "#{table_name}.#{name} >= :time", time: time }
        end
      end

      if name.ends_with?('_state')&&:string==columns_hash[name].type
        matched = /\A(.+)_state\z/.match name
        class_eval do
          validates name.to_sym, presence: true, length: { is: columns_hash[name].limit }
          scope :"#{matched[1]}_transited_to", ->(states) { where name => states }
        end
      end

    end

    includer.define_singleton_method :default_scope do
      includer.all.order("#{includer.table_name}.ordinal ASC") if includer.columns_hash['ordinal'].present?
      includer.all.order("#{includer.table_name}.created_at ASC")
      #relation = base.all
      #scopes.each do |s| relation = relation.send s.to_sym end
      #relation
    end

    ##
    # 对当前对象进行软删除。软删除之后， #closed_at 会被置为当前时间， #defunct 会被置为 false 。并且对象会被自动保存。如：
    # model = YourModel.find your_id
    # model.soft_destroy
    def soft_destroy
      self.closed_at = Time.now
      self.defunct = true
      self.save
    end

    ##
    # 生成当前对象的 slug 。如果有 #name 属性，则用 #name 属性的值生成；否则用 #title 属性的值生成；最后采用随机 UUID 生成。
    def build_slug
      if respond_to? :name
        name
      elsif respond_to? :title
        title
      else
        ::SecureRandom.uuid
      end
    end

  end

  module ClassMethods

    ##
    # 将模型对象或者 ID 转换成 ID 。如：
    # to_id(person)    # person.id
    # to_id(person.id) # person.id
    def to_id(model)
      model.respond_to?(:id) ? model.id : model
    end

    ##
    # 将模型对象或者 code 转换成 code 。如：
    # to_id(category)      # category.id
    # to_id(category.code) # category.id
    def to_code(code)
      code.respond_to?(:code) ? code.code : code
    end

  end

end
