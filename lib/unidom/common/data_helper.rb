require 'csv'

module Unidom
  module Common

    module DataHelper

      ##
      # 以 CSV 的格式加载 file_name 对应的文件，利用闭包遍历每一行。如：
      # Unidom::Common::DataHelper.each_csv_row '/var/file.csv' do |line|
      #   puts line.inspect
      # end
      def each_csv_row(file_name, &block)

        started_at = Time.now

        puts "Importing from CSV file: #{file_name}."
        if file_name.blank?
          puts "#{file_name} doesn't exist."
          abort 1
        end

        CSV.foreach file_name, { encoding: 'UTF-8', headers: :first_row }, &block

        puts "#{Time.now-started_at} seconds was spent to handle the given CSV."

      end

      def parse_time(date_text, default = Time.now)
        return default if date_text.blank?
        date = Date.parse date_text
        Time.utc date.year, date.month, date.day
      end

    end

  end
end
