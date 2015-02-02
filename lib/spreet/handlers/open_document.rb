# encoding: utf-8
require 'zip'
require 'libxml'
require 'money'
require 'time'
require 'duration'

module Spreet
  module Handlers
    class OpenDocument < Spreet::Handlers::Base
      DATE_REGEXP = /\%./
      DATE_ELEMENTS = {
        "m" => "<number:month number:style=\"long\"/>",
        "d" => "<number:day number:style=\"long\"/>",
        "Y" => "<number:year/>"
      }

      MIME = {
        :ods => "application/vnd.oasis.opendocument.spreadsheet",
        :xml => "text/xml"
      }.freeze.each{|n,ns| self.const_set("MIME_#{n}".upcase, ns.freeze)}


      XMLNS = {
        :manifest => 'urn:oasis:names:tc:opendocument:xmlns:manifest:1.0',
        :office   => 'urn:oasis:names:tc:opendocument:xmlns:office:1.0',
        :style    => 'urn:oasis:names:tc:opendocument:xmlns:style:1.0',
        :text     => 'urn:oasis:names:tc:opendocument:xmlns:text:1.0',
        :table    => 'urn:oasis:names:tc:opendocument:xmlns:table:1.0',
        :draw     => 'urn:oasis:names:tc:opendocument:xmlns:drawing:1.0',
        :fo       => 'urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0',
        :meta     => 'urn:oasis:names:tc:opendocument:xmlns:meta:1.0',
        :number   => 'urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0',
        :presentation => 'urn:oasis:names:tc:opendocument:xmlns:presentation:1.0',
        :svg      => 'urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0',
        :chart    => 'urn:oasis:names:tc:opendocument:xmlns:chart:1.0',
        :dr3d     => 'urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0',
        :form     => 'urn:oasis:names:tc:opendocument:xmlns:form:1.0',
        :script   => 'urn:oasis:names:tc:opendocument:xmlns:script:1.0',
        :dc       => 'http://purl.org/dc/elements/1.1/',
        :ooo      => 'http://openoffice.org/2004/office',
        :ooow     => 'http://openoffice.org/2004/writer',
        :oooc     => 'http://openoffice.org/2004/calc',
        :math     => 'http://www.w3.org/1998/Math/MathML',
        :xlink    => 'http://www.w3.org/1999/xlink',
        :dom      => 'http://www.w3.org/2001/xml-events',
        :xsd      => 'http://www.w3.org/2001/XMLSchema',
        :xsi      => 'http://www.w3.org/2001/XMLSchema-instance',
        :xforms   => 'http://www.w3.org/2002/xforms',
        :field    => 'urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:field:1.0'
      }.freeze.each{|n,ns| self.const_set("XMLNS_#{n}".upcase, ns.freeze)}


      def self.xmlec(string)
        zs = string.to_s.gsub('&', '&amp;').gsub('\'', '&apos;').gsub('<', '&lt;').gsub('>', '&gt;')
        zs.force_encoding('US-ASCII') if zs.respond_to?(:force_encoding)
        return zs
      end

      def self.add_attr(node, name, value, ns=nil)
        attr = LibXML::XML::Attr.new(node, name, value.to_s)
        attr.namespaces.namespace = ns if ns
        return attr
      end

      def self.read(file, options={})
        spreet = nil
        Zip::File.open(file) do |zile|
          # Check mime_type
          entry = zile.find_entry "mimetype"
          if entry.nil?
            raise StandardError.new("First element in archive must be a non-compressed 'mimetype'-named file.")
          else
            mime_type = zile.read(entry)
            unless mime_type == MIME_ODS
              raise StandardError.new("Mimetype mismatch")
            end
          end
          
          # Get manifest
          entry, files = zile.find_entry("META-INF/manifest.xml"), {}
          if entry.nil?
            raise StandardError.new("Second element in archive must be a 'META-INF/manifest.xml'-named file.")
          else
            doc = LibXML::XML::Parser.string(zile.read(entry)).parse
            for child in doc.root.children
              if child.name == 'file-entry'
                files[child["full-path"]] = child
              end
            end
          end
          if files["/"]["media-type"] != MIME_ODS
            raise StandardError.new("Mimetype difference")
          end

          # Get content
          if files["content.xml"] and entry = zile.find_entry("content.xml")
            doc = LibXML::XML::Parser.string(zile.read(entry)).parse
            unless doc.root.name == 'document-content'
              raise StandardError.new("<document-content> element expected at root of content.xml")
            end
            if spreadsheet = doc.root.find('./office:body/office:spreadsheet', XMLNS_OFFICE).first
              spreet = Spreet::Document.new()
              for table in spreadsheet.find('./table:table', XMLNS_TABLE)
                sheet = spreet.sheets.add(table["name"])
                # Ignore table-column for now

                rows = table.find("./table:table-rows").first || table
                # # Expand rows and cells
                # array = []
                # for row in table.find('./table:table-row', XMLNS_TABLE)
                #   line = []
                #   for cell in row.find('./table:table-cell', XMLNS_TABLE)
                #     (cell["number-columns-repeated"]||'1').to_i.times do
                #       line << cell
                #     end
                #   end
                #   (row["number-rows-repeated"]||'1').to_i.times do
                #     array << line
                #   end
                # end
                # Fill sheet
                row_offset = 0
                rows.find('./table:table-row', XMLNS_TABLE).each_with_index do |row, y|
                  row_content, cell_offset = false, 0
                  row.find('./table:table-cell|./table:covered-table-cell', XMLNS_TABLE).each_with_index do |cell, x|
                    x += cell_offset
                    cell_content = false
                    if cell.name == "covered-table-cell"
                      # puts "covered-table-cell"
                    else
                      if value_type = cell.attributes.get_attribute_ns(XMLNS_OFFICE, "value-type")
                        value_type = value_type.value.to_sym
                        p = cell.find('./text:p', XMLNS_TEXT).first
                        if [:float, :percentage].include?(value_type)
                          value = cell.attributes.get_attribute_ns(XMLNS_OFFICE, "value").value
                          sheet[x,y] = value.to_f
                        elsif value_type == :currency
                          value = cell.attributes.get_attribute_ns(XMLNS_OFFICE, "value").value
                          currency = cell.attributes.get_attribute_ns(XMLNS_OFFICE, "currency").value
                          sheet[x,y] = Money.new(value.to_f, currency)
                        elsif value_type == :date
                          value = cell.attributes.get_attribute_ns(XMLNS_OFFICE, "date-value").value
                          if value.match(/\d{1,8}-\d{1,2}-\d{1,2}/)
                            value = Date.civil(*value.split(/[\-]+/).collect{|v| v.to_f})
                          elsif value.match(/\d{1,8}-\d{1,2}-\d{1,2}T\d{1,2}\:\d{1,2}\:\d{1,2}(\.\d+)?/)
                            value = Time.new(*value.split(/[\-\:\.\T]+/).collect{|v| v.to_f})
                          else
                            raise Exception.new("Bad date format")
                          end
                          sheet[x,y] = value
                        elsif value_type == :time
                          value = cell.attributes.get_attribute_ns(XMLNS_OFFICE, "time-value").value
                          sheet[x,y] = Duration.new(value)
                        elsif value_type == :boolean
                          value = cell.attributes.get_attribute_ns(XMLNS_OFFICE, "boolean-value").value
                          sheet[x,y] = (value == "true" ? true : false)
                        elsif value_type == :string
                          sheet[x,y] = p.content.to_s if p
                        end
                        sheet[x,y].text = p.content.to_s if p
                        cell_content = true
                      end
                      if annotation = cell.find("./office:annotation", XMLNS_OFFICE).first
                        if text = annotation.find("./text:p", XMLNS_TEXT).first
                          sheet[x,y].annotation = text.content.to_s
                          cell_content = true
                        end
                      end
                    end
                    repeated = (cell["number-columns-repeated"]||'1').to_i - 1
                    if repeated > 0
                      repeated.times do |i|
                        sheet[x+i+1,y] = sheet[x,y]
                      end if cell_content
                      cell_offset += repeated
                    end
                    row_content = true if cell_content
                  end

                  repeated = (row["number-rows-repeated"]||'1').to_i - 1
                  if repeated > 0
                    repeated.times do |i|
                      sheet.row(sheet.rows(y), :row=>(y+i+1))
                    end if row_content
                    row_offset += repeated
                  end
                  
                end
                # What else ?
              end
            end
          end

          if spreet.nil?
            raise StandardError.new("Missing or bad content.xml")
          end
        end        
        return spreet
      end


      def self.write(spreet, file, options={})
        xml_escape = "to_s.gsub('&', '&amp;').gsub('\\'', '&apos;').gsub('<', '&lt;').gsub('>', '&gt;')"
        xml_escape << ".force_encoding('US-ASCII')" if xml_escape.respond_to?(:force_encoding)
        mime_type = MIME_ODS
        # name = #{table.model.name}.model_name.human.gsub(/[^a-z0-9]/i,'_')
        Zip::OutputStream.open(file) do |zile|
          # MimeType in first place
          zile.put_next_entry('mimetype', nil, nil, Zip::Entry::STORED)
          zile << mime_type
          
          # Manifest
          doc = LibXML::XML::Document.new
          doc.root = LibXML::XML::Node.new('manifest')
          ns = LibXML::XML::Namespace.new(doc.root, 'manifest', XMLNS_MANIFEST)
          doc.root.namespaces.namespace = ns
          files = {
            "/" => {"media-type" => mime_type},
            "content.xml" => {"media-type" => MIME_XML}
          }
          for path, attributes in files
            doc.root << entry = LibXML::XML::Node.new('file-entry', nil, ns)
            attributes['full-path'] = path
            for name, value in attributes.sort
              self.add_attr(entry, name, value, ns)
            end
          end
          zile.put_next_entry('META-INF/manifest.xml')
          xml = doc.to_s(:indent=>false)
          xml.force_encoding('US-ASCII') if xml.respond_to? :force_encoding
          zile << xml

          # Content
          doc = LibXML::XML::Document.new
          doc.root = LibXML::XML::Node.new('document-content')
          nss = {}
          for prefix, ns in XMLNS.select{|k,v| k != :manifest}
            nss[prefix] = LibXML::XML::Namespace.new(doc.root, prefix.to_s, ns)
          end
          doc.root.namespaces.namespace = nss[:office]
          add_attr(doc.root, "version", "1.1", nss[:office])

          doc.root << automatic_styles = LibXML::XML::Node.new("automatic-styles", nil, nss[:office])

          automatic_styles << style = LibXML::XML::Node.new("date-style", nil, nss[:number])
          add_attr(style, "name", "DMY", nss[:style])
          add_attr(style, "automatic-order", "true", nss[:number])
          style << token = LibXML::XML::Node.new("day", nil, nss[:number])
          add_attr(token, "style", "long", nss[:number])
          style << token = LibXML::XML::Node.new("text", "/", nss[:number])
          style << token = LibXML::XML::Node.new("month", nil, nss[:number])
          add_attr(token, "style", "long", nss[:number])
          style << token = LibXML::XML::Node.new("text", "/", nss[:number])
          style << token = LibXML::XML::Node.new("year", nil, nss[:number])

          automatic_styles << style = LibXML::XML::Node.new("style", nil, nss[:style])
          add_attr(style, "name", "CE1", nss[:style])
          add_attr(style, "family", "table-cell", nss[:style])
          add_attr(style, "data-style-name", "DMY", nss[:style])

          automatic_styles << style = LibXML::XML::Node.new("style", nil, nss[:number])
          add_attr(style, "name", "COL", nss[:style])
          add_attr(style, "family", "table-column", nss[:number])
          style << token = LibXML::XML::Node.new("table-column-properties", nil, nss[:style])
          add_attr(token, "break-before", "auto", nss[:fo])
          add_attr(token, "use-optimal-column-width", "true", nss[:style])

          doc.root << body = LibXML::XML::Node.new("body", nil, nss[:office])
          body << spreadsheet = LibXML::XML::Node.new("spreadsheet", nil, nss[:office])
          for sheet in spreet.sheets
            spreadsheet << table = LibXML::XML::Node.new("table", nil, nss[:table])
            add_attr(table, "name", sheet.name, nss[:table])
            table << table_columns = LibXML::XML::Node.new("table-columns", nil, nss[:table])
            for x in 0..sheet.bound.x
              table_columns << table_column = LibXML::XML::Node.new("table-column", nil, nss[:table])
              add_attr(table_column, "style-name", "COL", nss[:table])
            end
            table << table_rows = LibXML::XML::Node.new("table-rows", nil, nss[:table])
            sheet.each_row do |row| # #{record} in #{table.records_variable_name}\n"
              table_rows << table_row = LibXML::XML::Node.new("table-row", nil, nss[:table])
              for cell in row
                table_row << table_cell = LibXML::XML::Node.new("table-cell", nil, nss[:table])
                unless cell.empty?
                  add_attr(table_cell, "value-type", cell.type, nss[:office])
                  if cell.type == :float # or percentage
                    add_attr(table_cell, "value", cell.value, nss[:office])
                  elsif cell.type == :currency
                    add_attr(table_cell, "value", cell.value.to_f, nss[:office])
                    add_attr(table_cell, "currency", cell.value.currency_as_string, nss[:office])
                  elsif cell.type == :date
                    if cell.value.is_a? Date
                      add_attr(table_cell, "date-value", cell.value.to_s, nss[:office])
                      add_attr(table_cell, "style-name", "CE1", nss[:table])
                    elsif cell.value.is_a?(DateTime) or cell.value.is_a?(Time) 
                      add_attr(table_cell, "datetime-value", cell.value.to_xsd, nss[:office])
                    end
                  elsif cell.type == :time
                    add_attr(table_cell, "time-value", cell.value.to_s, nss[:office])
                  elsif cell.type == :boolean
                    add_attr(table_cell, "boolean-value", cell.value.to_s, nss[:office])
                  end
                  table_cell << LibXML::XML::Node.new("p", cell.text, nss[:text])
                end
                unless cell.annotation.nil?
                  table_cell << annotation = LibXML::XML::Node.new("annotation", nil, nss[:office])
                  annotation << LibXML::XML::Node.new("p", cell.annotation, nss[:text])
                end
              end
            end
          end

          zile.put_next_entry('content.xml')        
          xml = doc.to_s(:indent=>false)
          xml.force_encoding('US-ASCII') if xml.respond_to? :force_encoding
          zile << xml

          #   zile.put_next_entry('content.xml')        
          #   zile << ("<?xml version=\"1.0\" encoding=\"UTF-8\"?><office:document-content xmlns:office=\"urn:oasis:names:tc:opendocument:xmlns:office:1.0\" xmlns:style=\"urn:oasis:names:tc:opendocument:xmlns:style:1.0\" xmlns:text=\"urn:oasis:names:tc:opendocument:xmlns:text:1.0\" xmlns:table=\"urn:oasis:names:tc:opendocument:xmlns:table:1.0\" xmlns:draw=\"urn:oasis:names:tc:opendocument:xmlns:drawing:1.0\" xmlns:fo=\"urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:meta=\"urn:oasis:names:tc:opendocument:xmlns:meta:1.0\" xmlns:number=\"urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0\" xmlns:presentation=\"urn:oasis:names:tc:opendocument:xmlns:presentation:1.0\" xmlns:svg=\"urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0\" xmlns:chart=\"urn:oasis:names:tc:opendocument:xmlns:chart:1.0\" xmlns:dr3d=\"urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0\" xmlns:math=\"http://www.w3.org/1998/Math/MathML\" xmlns:form=\"urn:oasis:names:tc:opendocument:xmlns:form:1.0\" xmlns:script=\"urn:oasis:names:tc:opendocument:xmlns:script:1.0\" xmlns:ooo=\"http://openoffice.org/2004/office\" xmlns:ooow=\"http://openoffice.org/2004/writer\" xmlns:oooc=\"http://openoffice.org/2004/calc\" xmlns:dom=\"http://www.w3.org/2001/xml-events\" xmlns:xforms=\"http://www.w3.org/2002/xforms\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:field=\"urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:field:1.0\" office:version=\"1.1\"><office:scripts/>")
          #   # Styles
          #   default_date_format = '%d/%m%Y' # ::I18n.translate("date.formats.default")
          #   zile << ("<office:automatic-styles><style:style style:name=\"co1\" style:family=\"table-column\"><style:table-column-properties fo:break-before=\"auto\" style:use-optimal-column-width=\"true\"/></style:style><style:style style:name=\"header\" style:family=\"table-cell\"><style:text-properties fo:font-weight=\"bold\" style:font-weight-asian=\"bold\" style:font-weight-complex=\"bold\"/></style:style><number:date-style style:name=\"K4D\" number:automatic-order=\"true\"><number:text>"+default_date_format.gsub(DATE_REGEXP){|x| "</number:text>"+DATE_ELEMENTS[x[1..1]]+"<number:text>"} +"</number:text></number:date-style><style:style style:name=\"ce1\" style:family=\"table-cell\" style:data-style-name=\"K4D\"/></office:automatic-styles>")
          
          #   zile << ("<office:body><office:spreadsheet>")
          #   # Tables
          #   for sheet in spreet.sheets
          #     zile << ("<table:table table:name=\"#{xmlec(sheet.name)}\">")
          #     zile << ("<table:table-column table:number-columns-repeated=\"#{sheet.bound.x+1}\"/>")
          #     # zile << ("<table:table-header-rows><table:table-row>"+columns_headers(table).collect{|h| "<table:table-cell table:style-name=\"header\" office:value-type=\"string\"><text:p>'+(#{h}).#{xml_escape}+'</text:p></table:table-cell>"}.join+"</table:table-row></table:table-header-rows>")
          #     sheet.each_row do |row| # #{record} in #{table.records_variable_name}\n"
          #       zile << "<table:table-row>"
          #       for cell in row
          #         if cell.empty?
          #           zile << "<table:table-cell/>"
          #         else
          #           zile << "<table:table-cell"+(if cell.type == :decimal
          #                                          " office:value-type=\"float\" office:value=\"#{xmlec(cell.value)}\""
          #                                        elsif cell.type == :boolean
          #                                          " office:value-type=\"boolean\" office:boolean-value=\"#{xmlec(cell.value ? 'true' : 'false')}\""
          #                                        elsif cell.type == :date
          #                                          " office:value-type=\"date\" table:style-name=\"ce1\" office:date-value=\"#{xmlec(cell.value)}\""
          #                                        else
          #                                          " office:value-type=\"string\""
          #                                        end)+"><text:p>"+xmlec(cell.text)+"</text:p></table:table-cell>"
          #         end
          #       end
          #       zile << "</table:table-row>"
          #     end
          #     zile << ("</table:table>")
          #   end
          #   zile << ("</office:spreadsheet></office:body></office:document-content>")
        end
        # Zile is finished
      end
      
    end
  end
end
