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

  def each
   `for (#{i=0}; #{i} < #{self}.length; #{i}++) {
      #{ yield RubyJS::conv2ruby(`#{self}[#{i}]`) }
    }`
    self
  end

  def each_with_index
   `for (#{i=0}; #{i} < #{self}.length; #{i}++) {
      #{ yield RubyJS::conv2ruby(`#{self}[#{i}]`), i }
    }`
    self
  end

  def join(sep="")
    `#{ map {|elem| elem.to_s} }.join(#{sep})`
  end

  def to_a
    self
  end

  def to_ary
    self
  end

  def self.new
    `[]`
  end

  # TODO: test that +ary+ is array 
  def +(ary)
    `#{self}.concat(#{ary})`
  end

  def dup
    `#{self}.concat()`
  end

  def reverse
    `#{self}.concat().reverse()`
  end

  def reverse!
    `#{self}.reverse()`
    self
  end

  def length
    `#{self}.length`
  end

  alias size length

  def first
    RubyJS::conv2ruby(`#{self}[0]`) 
  end

  def last
    RubyJS::conv2ruby(`#{self}[#{self}.length-1]`)
  end

  def clear
    `#{self}.length = 0`
    self
  end

  # TODO: check arrary bounds
  def [](i)
    RubyJS::conv2ruby(`#{self}[#{i}]`)
  end

  def []=(i, val)
    `#{self}[#{i}] = #{val}`
  end

  def push(*args)
    `#{self}.push.apply(#{self}, #{args})`
    self
  end

  def <<(arg)
    `#{self}.push(#{arg})`
    self
  end

  def pop() 
    RubyJS::conv2ruby(`#{self}.pop()`)
  end

  def shift() 
    RubyJS::conv2ruby(`#{self}.shift()`)
  end

  def delete(obj)
    del = false
    i = 0
    while `#{i} < #{self}.length`
      if obj.eql?(RubyJS::conv2ruby(`#{self}[#{i}]`))
        `#{self}.splice(#{i}, 1)`
        del = true
        `if (#{i} < #{self}.length - 1) --#{i}` # stay at the current index unless we are at the last element
      end
      `#{i}++`
    end
    `#{del} ? #{obj} : #{nil}`
  end

  def unshift(*args)
    `#{self}.unshift.apply(#{self}, #{args})`
    self
  end

  def empty?
    `#{self}.length == 0`
  end

  def to_s
    map {|elem| elem.to_s}.join
  end

  def inspect
    "[" + map {|elem| elem.inspect}.join(", ") + "]"
  end

  def eql?(ary)
    `if (!(#{ary} instanceof Array) || #{self}.length != #{ary}.length) return false`

    #
    # Compare two equal-sized arrays element-wise
    #
    i = 0
    while `#{i} < #{self}.length`
      a = RubyJS::conv2ruby(`#{self}[#{i}]`)
      b = RubyJS::conv2ruby(`#{ary}[#{i}]`)
      return false unless a.eql?(b)
      `#{i}++`
    end
    true
  end
end
