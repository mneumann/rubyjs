module Kernel
  def nil?
    false
  end

  def loop
    while true
      yield
    end
  end

  def puts(str)
    `alert(#{str.to_s})`
    return nil
  end

  def p(*args)
    args.each do |arg|
      puts arg.inspect
    end
    return nil
  end
  
  def method_missing(id, *args, &block)
    raise NoMethodError, "undefined method `#{id}' for #{self.inspect}" 
  end

  # id is a Javascript name, e.g. $aaa
  # XXX
  def __invoke(id, args, &block) `
    var m = #<self>[#<id>];
    if (m)
      return m.apply(#<self>, [#<block>].concat(#<args>));
    else
      return #<self>.#<m:method_missing>.apply(#<self>, 
        [#<block>].concat([#<globalattr:mm>[#<id>]]).concat(#<args>));` 
  end
  
  # NOTE: In Ruby __send is __send__
  # XXX
  def __send(id, *args, &block) `
    var m = #<self>[#<globalattr:mm_reverse>[#<id>]];
    if (m) 
      return m.apply(#<self>, [#<block>].concat(#<args>));
    else
      return #<self>.#<m:method_missing>.apply(#<self>, [#<block>].concat([#<id>]).concat(#<args>));`
  end
  alias send __send

  # XXX
  def respond_to?(id) `
    var m = #<globalattr:mm_reverse>[#<id>]; 
    return (m !== undefined && #<self>[m] !== undefined && !#<self>[m].#<attr:_mm>)`
  end

  def proc(&block)
    Proc.new(&block)
  end

  def raise(*args)
    ex = 
    if args.empty?
      RuntimeError.new("")
    else
      first = args.shift
      if first.kind_of?(Class) # FIXME: subclass of Exception
        first.new(*args)
      elsif first.instance_of?(Exception) 
        if args.empty?
          first
        else
          ArgumentError.new("to many arguments given to raise")
        end
      elsif first.instance_of?(String)
        if args.empty?
          RuntimeError.new(first)
        else
          ArgumentError.new("to many arguments given to raise")
        end
      else
        TypeError.new("exception class/object expected")
      end
    end

    `throw(#{ex})`
    return nil
  end
end
