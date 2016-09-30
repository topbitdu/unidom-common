module Unidom::Common::Concerns::ModelExtension

  extend ActiveSupport::Concern

  included do |includer|

    validates :state, presence: true, length: { is: columns_hash['state'].limit }

    scope :included_by, ->(inclusion) { where     id: inclusion }
    scope :excluded_by, ->(exclusion) { where.not id: exclusion }

    scope :transited_to, ->(states) { where state: states }

    scope :valid_at,       ->(now: Time.now) { where "? BETWEEN #{includer.table_name}.opened_at AND #{includer.table_name}.closed_at", now }
    scope :valid_duration, ->(range)          { where "(#{includer.table_name}.opened_at BETWEEN ? AND ?) OR (#{includer.table_name}.closed_at <= ? AND #{includer.table_name}.closed_at >= ?)", range.min, range.max, range.max, range.min }

    scope :alive, ->(living:  true) { where defunct: !living }
    scope :dead,  ->(defunct: true) { where defunct: defunct }

    scope :notation_column_where, ->(name, operator, value) do
      operation = :like==operator ? { operator: 'ILIKE', value: "%#{value}%" } : { operator: operator.to_s, value: value }
      where "#{table_name}.notation -> 'columns' ->> '#{name}' #{operation[:operator]} :value", value: operation[:value]
    end

    scope :notation_boolean_column_where, ->(name, value) do
      where "(#{table_name}.notation -> 'columns' ->> '#{name}')::boolean = :value", value: (value ? true : false)
    end

    if columns_hash['ordinal'].present?&&:integer==columns_hash['ordinal'].type
      validates :ordinal, presence: true, numericality: { integer_only: true, greater_than: 0 }
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
      validates :grade, presence: true, numericality: { integer_only: true, greater_than_or_equal_to: 0 }
      scope :grade_is,          ->(grade) { where grade: grade }
      scope :grade_higher_than, ->(grade) { where "grade > :grade", grade: grade }
      scope :grade_lower_than,  ->(grade) { where "grade < :grade", grade: grade }
    end

    if columns_hash['priority'].present?&&:integer==columns_hash['priority'].type
      validates :priority, presence: true, numericality: { integer_only: true, greater_than_or_equal_to: 0 }
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
          scope "#{name}d_as".to_sym,     ->(code) { where     name => code }
          scope "not_#{name}d_as".to_sym, ->(code) { where.not name => code }
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

    def soft_destroy
      self.closed_at = Time.now
      self.defunct = true
      self.save
    end

    def build_slug
      if respond_to? :name
        name
      elsif respond_to? :title
        title
      else
        ::SecureRandom.uuid
      end
    end

    def assert_present!(name, value)
      raise ArgumentError.new("The #{name} argument is required.") if value.blank?
    end

  end

  module ClassMethods

    def to_id(model)
      model.respond_to?(:id) ? model.id : model
    end

    def notation_column(*names)
      names.each do |name|
        name = name.to_s
        instance_eval do
          define_method(name) do
            notation.try(:[], 'columns').try(:[], name)
          end
          define_method("#{name}=") do |value|
            notation['columns'] ||= {}
            notation['columns'][name] = value
          end
        end
      end
    end

    def notation_boolean_column(*names)
      names.each do |name|
        name = name.to_s
        instance_eval do
          define_method("#{name}?") do
            notation.try(:[], 'columns').try(:[], name)
          end
          define_method("#{name}=") do |value|
            notation['columns'] ||= {}
            notation['columns'][name] = value
          end
        end
      end
    end

    def assert_present!(name, value)
      raise ArgumentError.new("The #{name} argument is required.") if value.blank?
    end

  end

end
