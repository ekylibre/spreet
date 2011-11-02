# encoding: utf-8
require 'fastercsv'
require 'csv'
require 'iconv'

module Spreet
  # Universal CSV support
  CSV = (::CSV.const_defined?(:Reader) ? ::FasterCSV : ::CSV).freeze

  module Handlers

    class CSV < Spreet::Handler

      # Read a CSV file and create its Spreet document
      def self.read(file, options={})
        spreet = Spreet::Document.new
        sheet = spreet.sheets.add
        Spreet::CSV.foreach(file) do |row|
          sheet.row *row
        end
        return spreet
      end


      # Write a Spreet to a CSV file
      def self.write(spreet, file, options={})
        sheet = spreet.sheets[options[:sheet]||0]
        Spreet::CSV.open(file, "wb") do |csv|
          sheet.each_row do |row|
            csv << row.collect{|c| c.text}
          end
        end
      end

    end

    class ExcelCSV < Spreet::Handler

      # Read a CSV file and create its Spreet document
      def self.read(file, options={})
        spreet = Spreet::Document.new
        sheet = spreet.sheets.add
        options = {:col_sep=>';'}.merge(options)
        ic = Iconv.new('utf-8', 'cp1252')
        Spreet::CSV.foreach(file, options) do |row|
          sheet.row *(row.collect{|v| ic.iconv(v.to_s)})
        end
        return spreet
      end


      # Write a Spreet to a CSV file
      def self.write(spreet, file, options={})
        sheet = spreet.sheets[options[:sheet]||0]
        options = {:col_sep=>';'}.merge(options)
        ic = Iconv.new('cp1252', 'utf-8')
        Spreet::CSV.open(file, "wb", options) do |csv|
          sheet.each_row do |row|
            csv << row.collect{|c| ic.iconv(c.text)}
          end
        end
      end

    end

  end
end


