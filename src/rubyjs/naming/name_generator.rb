module RubyJS

  #
  # Generates unique names from a (custom) alphabet.
  #
  class NameGenerator

    DEFAULT_ALPHABET = ('a' .. 'z').to_a + ('A' .. 'Z').to_a + ('0' .. '9').to_a + ['_', '$']

    def initialize(alphabet=DEFAULT_ALPHABET)
      @alphabet = alphabet
      @digits = [0]
    end

    #
    # Can be overwritten in subclasses. A new name is generated if
    # valid?(name) returns false.
    #
    def valid?(name)
      true
    end
    
    # 
    # We generate names using a g-adic development where g=alphabet.size
    #
    # The least significant digit is the first. If you think of it as a
    # bit-string, then bit 0 would be @digits[0].
    #
    # In each call to next we try to increase the least significant
    # digit.  If it overflows, then we reset it to zero and increase the
    # next digit.  This continues up to the most significant digit. If
    # this overflows, we introduce a new most significant digit and set
    # this to "zero".
    #

    def next
      loop do
        name = @digits.reverse.map {|d| @alphabet[d] }.join("")
        sz = @alphabet.size

        i = 0
        loop do
          # increase or initialize with 0
          @digits[i] = @digits[i] ? @digits[i] + 1 : 0

          if @digits[i] >= sz
            @digits[i] = 0
            i += 1
          else
            break
          end
        end

        return name if valid?(name)
      end
    end

    def self.test
      gen = new()
      arr = []
      10_000.times { arr << gen.next }
      expect(arr.size) == arr.uniq.size 

      gen = new(DEFAULT_ALPHABET)
      arr = []
      DEFAULT_ALPHABET.size.times { arr << gen.next }
      expect(arr).all?("elements have size == 1") {|i| i.size == 1}
      arr = []
      (DEFAULT_ALPHABET.size**2).times { arr << gen.next }
      expect(arr).all?("elements have size == 2") {|i| i.size == 2}
    end

  end # class NameGenerator

end # module RubyJS
