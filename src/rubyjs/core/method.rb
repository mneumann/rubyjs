class Method
  # XXX
  def initialize(object, method_id)
    @object, @method_id = object, method_id

    if m = `#{object}[#<globalattr:mm_reverse>[#{method_id}]] || #{nil}`
      @method = m
    else
      raise NameError, "undefined method `#{method_id}' for class `#{object.class.name}'"
    end
  end

  # XXX
  def call(*args, &block)
    `#{@method}.apply(#{@object}, [#{block}].concat(#{args}))`
  end

  def inspect
    "#<Method: #{@object.class.name}##{@method_id}>"
  end
end
