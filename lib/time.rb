# encoding: UTF-8

class ::Time
  
  def to_xsd
    if self.utc?
      self.strftime("%Y-%m-%dT%H:%M:%S")
    else
      self.strftime("%Y-%m-%dT%H:%M:%S%z")
    end
  end

end
