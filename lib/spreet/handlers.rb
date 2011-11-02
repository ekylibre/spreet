module Spreet

  # Default handler
  class Handler

    def self.read(file, options={})
      raise NotImplementedError.new
    end

    def self.write(spreet, file, options={})
      raise NotImplementedError.new
    end
    
  end

end

require 'spreet/handlers/csv'
require 'spreet/handlers/open_document'

Spreet::Document.register_handler Spreet::Handlers::CSV, :csv
Spreet::Document.register_handler Spreet::Handlers::ExcelCSV, :xcsv
# Spreet::Document.register_handler Spreet::Handlers::HTML, :html
Spreet::Document.register_handler Spreet::Handlers::OpenDocument, :ods
# Spreet::Document.register_handler Spreet::Handlers::PDF, :pdf
