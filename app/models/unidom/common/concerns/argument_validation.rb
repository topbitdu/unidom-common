##
# Argument Validation 是参数验证逻辑的关注点。

module Unidom::Common::Concerns::ArgumentValidation

  extend ActiveSupport::Concern

  included do |includer|

    def assert_present!(name, value)
      raise ArgumentError.new("The #{name} argument is required.") if value.blank?
    end

  end

  module ClassMethods

    def assert_present!(name, value)
      raise ArgumentError.new("The #{name} argument is required.") if value.blank?
    end

  end

end
