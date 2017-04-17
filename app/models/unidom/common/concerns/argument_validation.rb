##
# Argument Validation 是参数验证逻辑的关注点。

module Unidom::Common::Concerns::ArgumentValidation

  extend ActiveSupport::Concern

  included do |includer|

    ##
    # 断言给定的参数 value 非空。如果为空，则抛出 ArgumentError 异常。如：
    # assert_present! :person, person
    def assert_present!(name, value)
      raise ArgumentError.new("The #{name} argument is required.") if value.blank?
    end

  end

  module ClassMethods

    ##
    # 断言给定的参数 value 非空。如果为空，则抛出 ArgumentError 异常。如：
    # assert_present! :person, person
    def assert_present!(name, value)
      raise ArgumentError.new("The #{name} argument is required.") if value.blank?
    end

  end

end
