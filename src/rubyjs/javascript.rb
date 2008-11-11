require 'javascript/misc'
require 'javascript/variable'
require 'javascript/conditional'
require 'javascript/iterator'
require 'javascript/method'
require 'javascript/string'

module RubyJS; class Compiler
  
  class Node

    #
    # Needs this node to be bracketized when used as receiver?
    # By default, no.
    #
    # Examples: 
    #
    #   A number as receiver needs to be bracketized
    #
    #       8.to_s -> (8).to_s
    #
    #   A boolean needs not
    #
    #       true.to_s -> true.to_s
    #
    def brackets?
      false
    end

    #
    # Compound statements have special behaviour in case of 
    # <tt>get(:mode) == :last</tt>, in that they pass the mode 
    # further to their sub-statements instead of generating 
    # a "return" on their own.
    #
    def compound?
      false
    end

    #
    # External function to generate javascript of a Node.
    #
    # Calls method <tt>as_javascript</tt> internally, but
    # might take special actions (e.g. surround the output).
    #
    def javascript(mode=nil)
      raise ArgumentError unless [nil, :expression, :statement, :last].include?(mode)
      h = {}
      h[:mode] = mode if mode != nil
      set(h) {
        if get(:mode) == :last and !compound?
          "return (" + as_javascript + ")"
        else
          as_javascript
        end
      }
    end

    def as_javascript
      raise "Unimplemented Javascript conversion for #{self.class.name} (#{self.kind})"
    end

    #
    # We do some minor optimizations if we face some literal values
    # where we already know the outcome.
    #
    def conditionalize(cond, negate=false)
      case cond
      when Nil, False
        negate ? "true" : "false"
      when True, StringLiteral, NumberLiteral #...
        negate ? "false" : "true"
      else
        str = cond.javascript(:expression)
        tmp = "t1" # TODO: need temporary variable!!!
        if negate
          "(#{tmp}=(#{str}),#{tmp}===false||#{tmp}===nil)"
        else
          "(#{tmp}=(#{str}),#{tmp}!==false&&#{tmp}!==nil)"
        end
      end
    end

  end # class Node

end; end # class Compiler; module RubyJS
