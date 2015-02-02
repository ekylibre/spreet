module Spreet

  class Document
    attr_reader :sheets
    @@handlers = {}
    @@associations = {}
    
    def initialize(option={})
      @sheets = Sheets.new(self)
    end

    def write(file, options={})
      handler = self.class.extract_handler(file, options.delete(:format))
      handler.write(self, file, options)
    end

    class << self
    
      def register_handler(klass, name, options={})
        if klass.respond_to?(:read) or klass.respond_to?(:write)
          if name.is_a?(Symbol)
            @@handlers[name] = klass # options.merge(:class=>klass)
          elsif
            raise ArgumentError.new("Name is invalid. Symbol expected, #{name.class.name} got.")
          end
        else
          raise ArgumentError.new("Handler do not support :read or :write method.")
        end
      end
      
      def read(file, options={})
        handler = extract_handler(file, options.delete(:format))
        return handler.read(file, options)
      end

      def extract_handler(file, handler_name=nil)
        file_path = Pathname.new(file)
        extension = file_path.extname.to_s[1..-1]
        if !handler_name and extension.size > 0
          handler_name = extension.to_sym
        end
        if @@handlers[handler_name]
          return @@handlers[handler_name]
        else
          raise ArgumentError.new("No corresponding handler (#{handler_name.inspect}). Available: #{@@handlers.keys.collect{|k| k.inspect}.join(', ')}.")
        end
      end

    end
    
  end  


end
