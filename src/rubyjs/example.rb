class Object
end

class Array < Object
  def hallo
    a = 1
    a ||= 4
    a &&= 5
  end

=begin
      def super
        @a = "hallo"
      end
      def test(a,b=1,c=4, *all, &block) a + 1; loop do c = 1 end end
=end
end
