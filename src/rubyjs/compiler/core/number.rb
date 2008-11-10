class Number
  OBJECT_CONSTRUCTOR__ = "Number"

  class << self
    undef_method :new
    undef_method :allocate 
  end

  def to_s(base=10)
    `#{self}.toString(#{base})`
  end

  def inspect
    `#{self}.toString()`
  end

  def +(x)  `#{self} + #{x}` end
  def -(x)  `#{self} - #{x}` end
  def -@()  `-#{self}` end
  def +@()  `#{self}` end
  def *(x)  `#{self} * #{x}` end
  def /(x)  `#{self} / #{x}` end
  def <(x)  `#{self} < #{x}` end
  def <=(x) `#{self} <= #{x}` end
  def >(x)  `#{self} > #{x}` end
  def >=(x) `#{self} >= #{x}` end
  def ==(x) `#{self} == #{x}` end
  def %(x)  `#{self} % #{x}` end
  def |(x)  `#{self} | #{x}` end
  def &(x)  `#{self} & #{x}` end
  def ^(x)  `#{self} ^ #{x}` end
  def ~()   `~#{self}` end

  def succ() `#{self}+1` end

  def times
    i = 0
   `for(;#{i} < #{self}; ++#{i}) { #{yield i} }`
    return self
  end

  def downto(x)
    i = self 
   `for(;#{i} >= #{x}; --#{i}) { #{yield i} }`
    return self
  end

  def upto(x)
    i = self 
   `for(;#{i} <= #{x}; ++#{i}) { #{yield i} }`
    return self
  end

end

# for compatibility
class Fixnum < Number; end
class Bignum < Number; end
class Float < Number; end
