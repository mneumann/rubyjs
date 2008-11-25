module Enumerable
  def map(&block)
    result = []
    if block
      each {|elem| result << yield elem }
    else
      each {|elem| result << elem }
    end
    result
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
