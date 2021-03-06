require 'csv'

module Spreet
  module Handlers

    class CSV < Spreet::Handlers::Base

      # Read a CSV file and create its Spreet document
      def self.read(file, options={})
        spreet = Spreet::Document.new
        sheet = spreet.sheets.add
        ::CSV.foreach(file) do |row|
          sheet.row *row
        end
        return spreet
      end


      # Write a Spreet to a CSV file
      def self.write(spreet, file, options={})
        sheet = spreet.sheets[options[:sheet]||0]
        ::CSV.open(file, "wb") do |csv|
          sheet.each_row do |row|
            csv << row.collect{|c| c.text}
          end
        end
      end

    end

  end
end


