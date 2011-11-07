# encoding: utf-8

# Class to manage durations (or intervals in SQL vocabulary)
class Duration
  FIELDS = [:years, :months, :days, :hours, :minutes, :seconds]
  attr_accessor *FIELDS
  
  def initialize(*args)
    @years, @months, @days, @hours, @minutes, @seconds = 0, 0, 0, 0, 0, 0
    if args.size == 1 and args[0].is_a? String
      self.parse(args[0])
    else
      @years   = (args.shift || 0).to_i
      @months  = (args.shift || 0).to_i
      @days    = (args.shift || 0).to_i
      @hours   = (args.shift || 0).to_i
      @minutes = (args.shift || 0).to_i
      @seconds = (args.shift || 0).to_i      
    end
  end

  def parse(string)
    strings = args[0].split('T')
    strings[0].match(/\d+[YMD]/) do |token|
      code, count = token[0..0], token[0..-2].to_i
      if code == "Y"
        @years = count
      elsif code == "M"
        @months = count
      elsif code == "D"
        @days = count
      end
    end
    strings[1].match(/\d+[HMS]/) do |token|
      code, count = token[0..0], token[0..-2].to_i
      if code == "H"
        @hours = count
      elsif code == "M"
        @minutes = count
      elsif code == "S"
        @seconds = count
      end
    end
    @sign = -1 if string.match(/^\-/)
    return self
  end

  def to_s
    (@negative ? "-" : "")+"P"+(@years.zero? and @months.zero? and @days.zero? ? '' : @years.to_s+"Y"+@month.to_s+"M"+@days.to_s+"D")+(@hours.zero? and @minutes.zero? and @seconds.zero? ? '' : "T"+@hours.to_s+"H"+@minutes.to_s+"M"+@seconds.to_s+"S")
  end

end
