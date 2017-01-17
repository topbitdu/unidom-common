require 'unidom/common/engine'

require 'unidom/common/numeration'
require 'unidom/common/yaml_helper'
require 'unidom/common/engine_extension'

module Unidom
  module Common

    NULL_UUID = '00000000-0000-0000-0000-000000000000'.freeze
    SELF      = '~'.freeze

    #OPENED_AT = Time.utc(1970).freeze
    #CLOSED_AT = Time.utc(3000).freeze

    #FROM_DATE = '1970-01-01'.freeze
    #THRU_DATE = '3000-01-01'.freeze

    mattr_accessor :options

    def self.configure

      options = {}
      yield options

      default_options = {
        neglected_namespaces: []
      }
      self.options = default_options.merge options

      puts 'Unidom::Common:'
      if self.options[:neglected_namespaces].present?
        puts '-- neglected_namespaces'
        puts "   -> #{self.options[:neglected_namespaces].join ', '}"
      end

    end

  end
end
