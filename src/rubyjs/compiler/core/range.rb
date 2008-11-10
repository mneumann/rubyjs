class Range
  def initialize(first, last, exclude_last=false)
    @first, @last = first, last
    @exclude_last = exclude_last ? true : false
  end

  def exclude_end?
    @exclude_last
  end

  def first
    @first
  end
  alias begin first

  def last
    @last
  end
  alias end last

  def ==(obj)
    `if (#{self}.constructor != #{obj}.constructor) return false;`
    @first == obj.first and @last == obj.last and @exclude_last == obj.exclude_end?
  end

  def eql?(obj)
    `if (#{self}.constructor != #{obj}.constructor) return false;`
    @first.eql?(obj.first) and @last.eql?(obj.last) and @exclude_last == obj.exclude_end? 
  end

  def include?(obj)
    return false if obj < @first
    if @exclude_last
      obj < @last 
    else
      obj <= @last
    end
  end

  alias member? include?
  alias === include?

  def each
    current = @first
    return if @first > @last
    if @exclude_last
      while current < @last
        yield current
        current = current.succ
      end
    else
      while current <= @last
        yield current
        current = current.succ
      end
    end
  end

  def to_a
    arr = []
    return arr if @first > @last
    current = @first
    if @exclude_last
      while current < @last
        arr << current
        current = current.succ
      end
    else
      while current <= @last
        arr << current
        current = current.succ
      end
    end
    return arr
  end

  def to_s
    if @exclude_last
      "#{@first}...#{@last}"
    else
      "#{@first}..#{@last}"
    end
  end

  def inspect
    if @exclude_last
      "#{@first.inspect}...#{@last.inspect}"
    else
      "#{@first.inspect}..#{@last.inspect}"
    end
  end

end
