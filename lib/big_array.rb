# encoding: utf-8

# Class to manage big hash with lot of pairs
class BigArray

  def initialize(klass_name=nil, partition=8, levels=4)
    @partition = partition.to_i
    raise ArgumentError.new("Partition must be an integer > 0") unless @partition > 0
    @levels = levels.to_i
    raise ArgumentError.new("Levels must be an integer > 0") unless @levels > 0
    klass_name ||= "#{self.class.name}#{@partition}_#{@levels}"
    @base_class = "Array"
    code  = ""
    code << "class #{klass_name}\n"
    code << "  def initialize()\n"
    code << "    @root = #{@base_class}.new\n"
    code << "  end\n\n"
    code << "  def [](index)\n"
    code << dive do |pointer|
      "return nil"
    end.strip.gsub(/^/, '    ')+"\n"
    code << "    return cursor[#{index_at_level(@levels)}]\n"
    code << "  end\n\n"
    code << "  def []=(index, value)\n"
    # code << "    index, value = args[0], args[1]\n"
    code << dive do |pointer|
      "#{pointer} = #{@base_class}.new"
    end.strip.gsub(/^/, '    ')+"\n"
    code << "    return cursor[#{index_at_level(@levels)}] = value\n"
    code << "  end\n\n"
    code << "  def delete(index)\n"
    # code << "    index, value = args[0], args[1]\n"
    code << dive do |pointer|
      "return nil"
    end.strip.gsub(/^/, '    ')+"\n"
    code << "    return cursor.delete(#{index_at_level(@levels)})\n"
    code << "  end\n\n"
    code << "end\n"
    # raise code
    eval(code)
    return self.class.const_get(klass_name)
  end

  private

  def dive(&block)
    code = ""
    for level in 1..(@levels-1)
      pointer = "#{level == 1 ? '@root' : 'cursor'}[#{index_at_level(level)}]"
      code << "unless #{pointer}.is_a?(#{@base_class})\n"
      code << yield(pointer).to_s.strip.gsub(/^/, '  ')+"\n"
      code << "end\n"
      code << "cursor = #{pointer}\n"
    end
    return code
  end

  def index_at_level(level, variable="index")
    v = variable
    v = "(#{v} >> #{(@levels-level)*@partition})" if level < @levels
    return "#{v}&#{2**@partition-1}"
  end


end
