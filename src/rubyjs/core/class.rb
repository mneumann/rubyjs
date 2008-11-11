class Class
  # XXX
  def allocate 
    `new #{self}.#<attr:object_constructor>()`
  end

  def new(*args, &block)
    obj = allocate()
    obj.initialize(*args, &block)
    obj
  end

  def ===(other)
    eql?(other) or other.kind_of?(self)
  end

  # XXX
  def name
    `#{self}.#<attr:classname>`
  end

  alias inspect name

  # XXX
  def self.new(superclass, classname, object_constructor=nil)
    object_constructor ||= `function() {}`
    `new #{self}.#<attr:object_constructor>(#{Class}, #{superclass}, #{classname}, #{object_constructor});`
  end
end
