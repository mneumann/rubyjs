$LOAD_PATH.unshift "../src"

require 'rubygems'
require 'test/unit'
require 'rubyjs/model'
require 'rubyjs/method_model'

module RubyJS; module Environment

  module T1
  end

  module T2
  end

  module T3
  end

  module T1
    include T2
  end

  module X
    include T2
  end

  class Object
    include X

    def hallo
    end
  end

  class Array < Object
    include X

    class B < Object
      class C; end
    end
    
    def hallo
    end
  end

  class Blah
  end

  class Blubb < Blah
  end

  class Blubb2 < Blah
  end

  class Blubb3 < Blubb2
  end

end; end


class TC_Model < Test::Unit::TestCase
  def setup
    @world = RubyJS::WorldModel.new(::RubyJS::Environment)
    @world.register_all_entities!
  end

  def test_order
    exp = %w(T2 T1 T3 X Object Array Array::B Array::B::C Blah Blubb Blubb2 Blubb3)
    assert_equal exp, @world.entity_models_sorted.map {|e| e.name}
  end

  def test_lookup
    obj = ::RubyJS::Environment::Object
    obj_model = @world.lookup(obj)
    assert_equal obj, obj_model.entity
    assert_equal nil, obj_model.sclass
    assert_equal [], obj_model.sclasses
    assert_equal "Object", obj_model.name
    assert_equal [
      ::RubyJS::Environment::X,
      ::RubyJS::Environment::T2
    ], obj_model.modules.map{|m| m.entity}
  end
end
