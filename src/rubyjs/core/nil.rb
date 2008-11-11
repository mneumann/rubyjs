class NilClass
  OBJECT_CONSTRUCTOR__ = "NilClass"

  class << self
    undef_method :new
    undef_method :allocate 
  end

  def nil?
    true
  end

  def to_s
    ""
  end

  def to_i
    0
  end

  def to_f
    0.0
  end

  def to_a
    []
  end

  def to_splat
    []
  end

  def inspect
    "nil"
  end
end
