module Spreet
  module Handlers

    # Default handler
    class Base
      
      def self.read(file, options={})
        raise NotImplementedError.new
      end
      
      def self.write(spreet, file, options={})
        raise NotImplementedError.new
      end
      
    end

    
  end
end
