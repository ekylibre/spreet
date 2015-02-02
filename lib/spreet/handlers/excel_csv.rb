require 'csv'

module Spreet
  module Handlers

    class ExcelCSV < Spreet::Handlers::Base

      # Read a CSV file and create its Spreet document
      def self.read(file, options={})
        spreet = Spreet::Document.new
        sheet = spreet.sheets.add
        options = {:col_sep=>';', :encoding => "CP1252"}.merge(options)
        ::CSV.foreach(file, options) do |row|
          sheet.row *(row.map{|v| v.to_s.encode('utf-8')}) # collect{|v| v.to_s.encode('cp1252')}
        end
        return spreet
      end


      # Write a Spreet to a CSV file
      def self.write(spreet, file, options={})
        sheet = spreet.sheets[options[:sheet]||0]
        options = {:col_sep=>';', :encoding => "CP1252"}.merge(options)
        ::CSV.open(file, "wb", options) do |csv|
          sheet.each_row do |row|
            csv << row.map(&:text)
          end
        end
      end

    end

  end
end


