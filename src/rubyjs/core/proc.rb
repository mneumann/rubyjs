class Proc
  OBJECT_CONSTRUCTOR__ = "Function"

  # XXX
  def self.new(&block)
    raise ArgumentError, "tried to create Proc object without a block" unless block
    #
    # wrap block inside another function, that catches iter_break returns.
    #
    `function() {
      try {
        return #<block>.#<m:call>.apply(#<block>, arguments);
      } catch(e) 
      {
        if (e instanceof #<globalattr:iter_jump>) 
        {
          if (e.#<attr:scope> == null)
          {`
            raise LocalJumpError, "break from proc-closure"
         `}
          return e.#<attr:return_value>;
        }
        else throw(e);
      }
    }`
  end

  def call(*args)
   `switch (#{args}.length) {
      case 0:
        return #{self}();
      case 1:
        return #{self}(#{args}[0]);
      default:
        return #{self}(#{args});
    }`
    nil
  end
end
