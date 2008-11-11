class Boolean
  OBJECT_CONSTRUCTOR__ = "Boolean"

  class << self
    undef_method :new
    undef_method :allocate 
  end

  def to_s
    `#{self} == true ? 'true' : 'false'`
  end

  def ==(obj)
    `#{self} == #{obj}`
  end

  alias inspect to_s
end
