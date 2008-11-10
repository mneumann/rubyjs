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
end
