class Object
  include Kernel

  def eql?(other)
    `#{self}.constructor == #{other}.constructor && #{self} == #{other}`
  end

  def ===(other)
    eql?(other) or kind_of?(other)
  end

  # XXX
  def instance_of?(klass)
    `#{self}.#<attr:_class> === #{klass}`
  end

  # XXX
  def kind_of?(klass)
    `#<globalattr:kind_of>(#{self}, #{klass})`
  end
  alias is_a? kind_of?

  def initialize
  end

  # XXX
  def class
    `#{self}.#<attr:_class>`
  end

  def to_s
    `#{self}.toString()`
  end

  alias inspect to_s
  alias hash to_s

  def method(id)
    Method.new(self, id)
  end
end
