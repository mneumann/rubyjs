#
# Models parsed methods.
#
# Copyright (c) 2007-2009 by Michael Neumann (mneumann@ntecs.de).
#

module RubyJS

  require 'rubyjs/method_extractor'

  #
  # Describes a parsed method.
  #
  # A method has a +name+ and belongs to an EntityModel (+entity_model+)
  # which can either be a ClassModel or a ModuleModel.
  #
  # MethodModel further contains the raw +sexp+ that comes directly from
  # the parse tree, and the sexp converted to Node objects in +node+.
  #
  class MethodModel

    attr_reader :name, :sexp, :entity_model
    attr_accessor :node # the associated Compiler::Node

    def self.all_for(entity)
      ary = []
      methods = MethodExtractor.extract(entity)
      methods[:instance].each {|name, sexp|
        ary << MethodModel.new(self, name, sexp)
      }
      methods[:class].each {|name, sexp|
        ary << MethodModel.new(self, name, sexp, true)
      }
      return ary
    end

    def initialize(entity_model, name, sexp, is_class_method=false)
      @entity_model = entity_model
      @name, @sexp = name, sexp
      @is_class_method = is_class_method
      @node = nil
    end

    def class_method?
      @is_class_method
    end

    def instance_method?
      not class_method?
    end

  end # class MethodModel

end # module RubyJS
