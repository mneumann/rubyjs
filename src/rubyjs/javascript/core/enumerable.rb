module Enumerable
  def map(&block)
    result = []
    each {|elem| result << (block ? block.call(elem) : elem) }
    result
  end
  alias collect map

  def select
    result = []
    each {|elem|
      if yield(elem)
        result << elem 
      end
    }
    result
  end
  alias find_all select

  def reject
    result = []
    each {|elem|
      unless yield(elem)
        result << elem
      end
    }
    result
  end

  def to_a
    result = []
    each {|elem| result << elem}
    result
  end

  def all?
    each {|elem| return false unless yield elem }
    true
  end

  def any?
    each {|elem| return true if yield elem }
    false
  end
end
