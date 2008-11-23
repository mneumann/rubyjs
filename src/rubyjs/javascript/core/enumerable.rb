module Enumerable
  def map(&block)
    if block
      result = []
      each {|elem| result << yield elem }
      result
    else
      to_a
    end
  end
  alias collect map

  def select
    result = []
    each {|elem| result << elem if yield elem }
    result
  end
  alias find_all select

  def reject
    result = []
    each {|elem| result << elem unless yield elem }
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
