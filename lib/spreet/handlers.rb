module Spreet
  module Handlers
    autoload :Base,         'spreet/handlers/base'
    autoload :CSV,          'spreet/handlers/csv'
    autoload :ExcelCSV,     'spreet/handlers/excel_csv'
    autoload :OpenDocument, 'spreet/handlers/open_document'
  end
end

