# XXX
#
# Every method that returns an element has to
# check this element for +null+. This is required
# to seamlessly use Javascript data without needing
# to convert it before usage.
#
# The reverse, passing a RubyJS Array to Javascript
# without conversion of +nil+ to +null+ is of course
# not possible!
#
# NOTE: Following condition holds true:
#   v == null <=> v=null || v=undefined
#
class Array
  OBJECT_CONSTRUCTOR__ = "Array"

  include Enumerable

=begin
  def each() 

    RubyJS::inline %{
      for (var i=0; i < this.length; i++) {
        #{yield RubyJS::js2ruby(`this[#{i}]`)}
      }
    }, :i

    return self
  end
=end


  def each() `
    var elem;
    for (var i=0; i < #<self>.length; i++) {
      elem = #<self>[i];`
      yield `(elem == null ? #<nil> : elem)`
   `}
    return #<self>`
  end

  def each_with_index() `  
    var elem;
    for (var i=0; i < #<self>.length; i++) {
      elem = #<self>[i];` 
      yield `(elem == null ? #<nil> : elem)`, `i`
   `}
    return #<self>`
  end

  def join(sep="")
    str = ""
    self.each_with_index {|elem, i|
      str += elem.to_s
      str += sep if i != self.length-1
    }
    str
  end

  def to_a
    self
  end

  def to_ary
    self
  end

  def self.new
    `return []`
  end

  # TODO: test that otherArray is array 
  def +(otherArray)
    `return #<self>.concat(#<otherArray>)`
  end

  def dup
    `return #<self>.concat()`
  end

  def reverse
    `return #<self>.concat().reverse()`
  end

  def reverse!
    `#<self>.reverse(); return #<self>`
  end

  def length
    `return #<self>.length`
  end

  alias size length

  def first
    #RubyJS::js2ruby(`this[0]`) 
    `var v = #<self>[0]; return (v == null ? #<nil> : v)`
  end

  def last
    #RubyJS::js2ruby(`this[this.length-1]`) 
    `var v = #<self>[#<self>.length - 1]; return (v == null ? #<nil> : v)`
  end

  def clear
    `#<self>.length=0; return #<self>` 
  end

  # TODO: check arrary bounds
  def [](i)
    `var v = #<self>[#<i>]; return (v == null ? #<nil> : v)`
  end

  def []=(i, val)
    `return (#<self>[#<i>] = #<val>)`
  end

  def push(*args)
    `#<self>.push.apply(#<self>, #<args>); return #<self>`
  end

  def <<(arg)
    `#<self>.push(#<arg>); return #<self>`
  end

  def pop() 
    #RubyJS::js2ruby(`this.pop()`)
    `
    var elem = #<self>.pop();
    return (elem == null ? #<nil> : elem)`
  end

  def shift() 
    #RubyJS::js2ruby(`this.shift()`)

    `
    var elem = #<self>.shift();
    return (elem == null ? #<nil> : elem)`
  end

=begin
  def delete(obj)
    i = 0
    while `#{i} < this.length` 
      if obj.eql?(RubyJS::js2ruby(`this[#{i}]`))
      else
      end
    end
  end
=end

  def delete(obj) `
    var del = false;
    for (var i=0; i < #<self>.length; i++)
    {
      if (#<obj>.#<m:eql?>(#<nil>, #<self>[i]))
      {
        #<self>.splice(i,1);
        del = true;
        // stay at the current index unless we are at the last element!
        if (i < #<self>.length-1) --i; 
      }
    }
    return del ? #<obj> : #<nil>`
  end
 
  def unshift(*args)
    `#<self>.unshift.apply(#<self>, #<args>); return #<self>`
  end

  def empty?
    `return (#<self>.length == 0)`
  end

  def to_s
    map {|i| i.to_s}.join
  end

  def inspect
    str = "["
    str += self.map {|elem| elem.inspect}.join(", ")
    str += "]"
    str
  end

  def eql?(other)
    `
    if (!(#<other> instanceof Array)) return false;
    if (#<self>.length != #<other>.length) return false;  

    //
    // compare element-wise
    //
    for (var i = 0; i < #<self>.length; i++) 
    {
      if (! #<self>[i].#<m:eql?>(#<nil>, #<other>[i]))
      {
        // 
        // at least for one element #eql? holds not true
        //
        return false;
      }
    }
    
    return true;
    `
  end
end
