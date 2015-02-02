require 'pathname'

module Spreet
  autoload :VERSION,     'spreet/version'
  autoload :Coordinates, 'spreet/coordinates'
  autoload :Cell,        'spreet/cell'
  autoload :Sheet,       'spreet/sheet'
  autoload :Sheets,      'spreet/sheets'
  autoload :Document,    'spreet/document'
  autoload :Handlers,    'spreet/handlers'
end

Spreet::Document.register_handler Spreet::Handlers::CSV, :csv
Spreet::Document.register_handler Spreet::Handlers::ExcelCSV, :xcsv
# Spreet::Document.register_handler Spreet::Handlers::HTML, :html
Spreet::Document.register_handler Spreet::Handlers::OpenDocument, :ods
# Spreet::Document.register_handler Spreet::Handlers::PDF, :pdf
