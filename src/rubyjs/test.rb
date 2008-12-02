require 'rubygems'
gem 'ParseTree', '> 3.0.0'
$LOAD_PATH.unshift ".."

require 'rubyjs'

RubyJS.eval_into(RubyJS::Environment, [File.expand_path("..")]) {
  require 'rubyjs/example'
  require 'rubyjs/javascript/core/all'
}

def with_encoder(file='encoder.yml')
  require 'yaml'
  encoder = 
    if File.exist?(file)
      YAML.load(File.read(file))
    else
      RubyJS::JavascriptNaming::NameEncoder.new
    end
  encoder.reset_local_cache!
  begin
    yield encoder
  ensure
    File.open(file, 'w+') {|f| f << encoder.to_yaml}
  end
end

if __FILE__ == $0
  with_encoder {|encoder| STDOUT << RubyJS::CodeGenerator.new(encoder).generate }
end
