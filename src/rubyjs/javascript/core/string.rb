#
# NOTE: Strings in RubyJS are immutable!!!
#
class String
  OBJECT_CONSTRUCTOR__ = "String"

  def +(str)
    `#{self} + #{str}`
  end
  
  def empty?
    `#{self} === ""`
  end

  def rjust(len, pad=" ")
    raise ArgumentError, "zero width padding" if pad.empty?

    n = len - self.length
    return self if n <= 0 

    fillstr = ""
    `while(#{fillstr}.length < #{n}) #{fillstr} += #{pad}`

    return fillstr[0,n] + self
  end

  def ljust(len, pad=" ")
    raise ArgumentError, "zero width padding" if pad.empty?

    n = len - self.length
    return self if n <= 0 

    fillstr = ""
    `while(#{fillstr}.length < #{n}) #{fillstr} += #{pad}`

    return self + fillstr[0,n]
  end

  def inspect
    # prototype.js
    specialChar = `{
      '\\b': '\\\\b',
      '\\t': '\\\\t',
      '\\n': '\\\\n',
      '\\f': '\\\\f',
      '\\r': '\\\\r',
      '\\\\': '\\\\\\\\'
    }`

    escapedString = self.gsub(/[\x00-\x1f\\]/) {|match| 
      character = `#{specialChar}[#{match}]` 
      `#{character} ? #{character} : 
       '\\\\u00' + ("0" + #{match}.charCodeAt().toString(16)).substring(0,2)`
    }

    `'"' + #{escapedString}.replace(/"/g, '\\\\"') + '"'`
  end

  def to_s
    self
  end

  def strip
    `#{self}.replace(/^\\s+/, '').replace(/\\s+$/, '')`
  end

  def split(str)
    `#{self}.split(#{str})`
  end

  def length
    `#{self}.length`
  end
  alias size length

  def index(substring, offset=0) 
    i = `#{self}.indexOf(#{substring}, #{offset})`
    return `#{i} == -1 ? #{nil} : #{i}`
  end

  def =~(pattern) 
    i = `#{self}.search(#{pattern})`
    return `#{i} == -1 ? #{nil} : #{i}`
  end

  def gsub(pattern, replacement=nil)
    # from prototype.js
    result, source, match = "", self, nil
   `while(#{source}.length > 0) {
      if (#{match} = #{source}.match(#{pattern})) {
        #{result} += #{source}.slice(0, #{match}.index)` 
        if replacement
          result += replacement 
        else
          result += yield(match.first).to_s
        end
   `    #{source} = #{source}.slice(#{match}.index + #{match}[0].length);
      } else {
        #{result} += #{source}; #{source} = '';
      }
    }`
    return result
  end

  def sub(pattern, replacement)
    # FIXME: block
    `#{self}.replace(#{pattern}, #{replacement})`
  end

  def [](index, len=nil)
    if len
      if len >= 0
        # substring access
        `#{self}.substring(#{index}, #{index}+#{len})`
      else
        nil
      end
    else
      # single character access
      # FIXME: returns a string and not a Fixnum!
      # But: Ruby 1.9+ has this behaviour!!!
      `#{self}.charAt(#{index}) || #{nil}`
    end
  end
end
