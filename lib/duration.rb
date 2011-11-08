# encoding: utf-8

# Class to manage durations (or intervals in SQL vocabulary)
class Duration
  # 365.25 * 86_400 == 31_557_600
  SECONDS_IN_YEAR = 31_557_600 # 31_556_926 => 31_556_928
  SECONDS_IN_MONTH = SECONDS_IN_YEAR / 12
  
  FIELDS = [:years, :months, :days, :hours, :minutes, :seconds]
  attr_accessor *FIELDS
  attr_reader :sign
  
  def initialize(*args)
    @years, @months, @days, @hours, @minutes, @seconds = 0, 0, 0, 0, 0, 0
    @sign = 1
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
    unless string.match(/^\-?P(\d+Y)?(\d+M)?(\d+D)?(T(\d+H)?(\d+M)?(\d+(\.\d+)?S)?)?$/)
      raise ArgumentError.new("Malformed string")
    end
    strings = string.split('T')
    strings[0].gsub(/\d+[YMD]/) do |token|
      code, count = token.to_s[-1..-1], token.to_s[0..-2].to_i
      if code == "Y"
        @years = count
      elsif code == "M"
        @months = count
      elsif code == "D"
        @days = count
      end
      token
    end
    strings[1].to_s.gsub(/(\d+[HM]|\d+(\.\d+)?S)/) do |token|
      code, count = token.to_s[-1..-1], token.to_s[0..-2]
      if code == "H"
        @hours = count.to_i
      elsif code == "M"
        @minutes = count.to_i
      elsif code == "S"
        @seconds = count.to_f
      end
      token
    end
    self.sign = (string.match(/^\-/) ? -1 : 1)
    return self
  end

  def sign=(val)
    @sign = (val >= 0 ? 1 : -1)
  end

  def to_s(compression = :normal)
    if compression == :maximum
      return (@sign > 0  ? "" : "-")+"P#{@years.to_s+'Y' if @years > 0}#{@months.to_s+'M' if @months > 0}#{@days.to_s+'D' if @days > 0}"+((@hours.zero? and @minutes.zero? and @seconds.zero?) ? '' : "T#{(@hours.to_s+'H') if @hours > 0}#{(@minutes.to_s+'M') if @minutes > 0}#{((@seconds.floor != @seconds ? @seconds.to_s : @seconds.to_i.to_s)+'S') if @seconds > 0}")
    elsif compression == :minimum
      return (@sign > 0  ? "" : "-")+"P"+@years.to_s+"Y"+@months.to_s+"M"+@days.to_s+"DT"+@hours.to_s+"H"+@minutes.to_s+"M"+@seconds.to_s+"S"
    else
      return (@sign > 0  ? "" : "-")+"P"+((@years.zero? and @months.zero? and @days.zero?) ? '' : @years.to_s+"Y"+@months.to_s+"M"+@days.to_s+"D")+((@hours.zero? and @minutes.zero? and @seconds.zero?) ? '' : "T"+@hours.to_s+"H"+@minutes.to_s+"M"+(@seconds.round != @seconds ? @seconds.to_s : @seconds.to_i.to_s)+"S")
    end
  end

  # Export all values to hash 
  def to_hash
    {:years=>@years, :months=>@months, :days=>@days, :hours=>@hours, :minutes=>@minutes, :seconds=>@seconds, :sign=>@sign}
  end

  # Computes a duration in seconds based on theoric and statistic values
  # Because the relation between some of date parts isn't fixed (such as the number of days in a month), 
  # the order relationship between durations is only partial, and the result of a comparison 
  # between two durations may be undetermined.
  def to_f
    count = @seconds
    count += 60 * @minutes
    # 60 * 60 = 3_600
    count += 3_600 * @hours
    # 60 * 60 * 24 = 86_400
    count += 86_400 * @days
    # 365.25/12 * 86_400 == 31_557_600/12 == 2_629_800
    count += SECONDS_IN_MONTH * @months
    # 365.25 * 86_400 == 31_557_600
    count += SECONDS_IN_YEAR * @years
    return @sign * count
  end

  def to_i
    self.to_f.to_i
  end

  # Normalize seconds, minutes, hours and month with their fixed relations
  def normalize!(normalize_method = :right)
    if normalize_method == :seconds
      count = self.to_f
      @years = (count / SECONDS_IN_YEAR).floor
      count -= @years * SECONDS_IN_YEAR
      @months = (count / SECONDS_IN_MONTH).floor
      count -= @months * SECONDS_IN_MONTH
      @days = (count / 86_400).floor
      count -= @days * 86_400
      @hours = (count / 3_600).floor
      count -= @hours * 3_600
      @minutes = (count / 60).floor
      count -= @minutes * 60
      @seconds = count
    else
      if @seconds >= 60
        minutes = (@seconds / 60).floor
        @seconds -= minutes * 60
        @minutes += minutes
      end
      if @minutes >= 60
        hours = (@minutes / 60).floor
        @minutes -= hours * 60
        @hours += hours
      end
      if @hours >= 24
        days = (@hours / 24).floor
        @hours -= days * 24
        @days += days
      end
      # No way to convert correctly days in month 
      if @months >= 12
        years = (@months / 12).floor
        @months -= years * 12
        @years += years
      end
    end
    return self
  end

  def normalize(normalize_method = :right)
    self.dup.normalize!(normalize_method)
  end

end
