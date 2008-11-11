module RubyJS

  require 'sexp_processor'
  require 'parse_tree'
  require 'unified_ruby'

  #
  # Extract method bodies out of Classes or Modules
  # and unifies the sexp.
  #
  class MethodExtractor < SexpProcessor
    attr_reader :c_methods, :i_methods

    def initialize
      super()

      self.strict = false 
      self.auto_shift_type = false
      self.require_empty = false
      self.unsupported.delete(:cfunc)

      @i_methods = {}  # instance methods
      @c_methods = {}  # class methods
    end

    def self.extract(entity)
      unifier = Unifier.new
      e = new()
      e.process(*ParseTree.new.parse_tree(entity))

      c, i = {}, {}

      e.c_methods.each {|k, v| 
        begin
          c[k] = unifier.process(v) 

          # convert :defs into :defn
          c[k].shift
          c[k].shift
          c[k].unshift(:defn)
        rescue UnsupportedNodeError => ex
          raise unless ex.message =~ /cfunc/
        end
      }
      e.i_methods.each {|k, v|
        begin
          i[k] = unifier.process(v)
        rescue UnsupportedNodeError => ex
          raise unless ex.message =~ /cfunc/
        end
      }

      {:class => c, :instance => i}
    end

    def process_defs(sexp)
      defs, _self, name, code, *r = *sexp
      raise unless r.empty?
      raise unless _self == s(:self)
      @c_methods[name.to_s] = sexp
      return s()
    end

    def process_defn(sexp)
      defn, name, code, *r = *sexp
      raise unless r.empty?
      @i_methods[name.to_s] = sexp
      return s()
    end
  end

end # module RubyJS
