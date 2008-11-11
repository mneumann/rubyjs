# 
# Evals into the given module_scope.
#
# Copyright (c) 2007, 2008 by Michael Neumann (mneumann@ntecs.de).
#

module RubyJS

  EvalInfoStruct = Struct.new(:module_scope, :loaded, :load_path, :eval_proc, :platform)

  EvalInfo = EvalInfoStruct.new

  class ::Object

    #
    # Installs the RubyJS__require handler as "require" for the
    # execution of the block.
    #
    def RubyJS__install_require
      alias RubyJS__old_require require
      begin
        alias require RubyJS__require
        yield
      ensure
        alias require RubyJS__old_require
      end
    end

    #
    # A require method for code evaluated within RubyJS
    #
    def RubyJS__require(file)
      (::RubyJS::EvalInfo.load_path || ['.']).each do |path|
        name = ::File.expand_path(::File.join(path, file + ".rb"))
        if ::File.exists?(name)
          if ::RubyJS::EvalInfo.loaded.include?(name)
            return false
          else
            ::RubyJS::EvalInfo.loaded << name
            ::RubyJS.log "loading file: #{name}"
            ::RubyJS::EvalInfo.eval_proc.call(::File.read(name)) 

            #
            # load also platform specific file
            # load first matching platform
            #

            (::RubyJS::EvalInfo.platform || []).each do |plat|
              plat_name = ::File.expand_path(::File.join(path, file + "." + plat + ".rb"))
              next unless ::File.exists?(plat_name)
              unless ::RubyJS::EvalInfo.loaded.include?(plat_name)
                ::RubyJS::EvalInfo.loaded << plat_name
                ::RubyJS.log "loading platform specific file: #{plat_name}"
                ::RubyJS::EvalInfo.eval_proc.call(::File.read(plat_name))
                break
              end
            end
    
            return true
          end
        else
          next
        end
      end
      raise ::RuntimeError, "require: #{file} not found"
    end
  end

  def self.eval_into(module_scope, load_path=nil, platform=nil, &block)
    ::RubyJS::EvalInfo.load_path = load_path
    ::RubyJS::EvalInfo.platform = platform
    ::RubyJS::EvalInfo.module_scope = module_scope
    ::RubyJS::EvalInfo.loaded ||= [] # avoids recursive loads

    ::RubyJS::EvalInfo.eval_proc = proc {|str|
      ::RubyJS::EvalInfo.module_scope.module_eval(str)
    }

    RubyJS__install_require {
      block.call(::RubyJS::EvalInfo.eval_proc)
    }
  end

end # module RubyJS
