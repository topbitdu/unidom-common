module Unidom::Common::Concerns::NotationColumn

  extend ActiveSupport::Concern

  included do |includer|

    scope :notation_column_where, ->(name, operator, value) do
      operation = :like==operator ? { operator: 'ILIKE', value: "%#{value}%" } : { operator: operator.to_s, value: value }
      where "#{table_name}.notation -> 'columns' ->> '#{name}' #{operation[:operator]} :value", value: operation[:value]
    end

    scope :notation_boolean_column_where, ->(name, value) do
      where "(#{table_name}.notation -> 'columns' ->> '#{name}')::boolean = :value", value: (value ? true : false)
    end

  end

  module ClassMethods

    ##
    # 定义 JSON 类型的列。如：
    # notation_column :given_name, :family_name
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

  end

end
