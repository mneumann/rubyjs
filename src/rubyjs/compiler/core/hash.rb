# XXX
#
# We prefix every element by a ":"
#
class Hash
  include Enumerable

  #
  # Construct an empty Hash
  #
  def initialize() `
    #<self>.#<attr:items> = {}; 
    #<self>.#<attr:default_value> = #<nil>;
    return #<nil>`
  end

  #
  # Construct a Hash from key, value pairs, e.g.
  #
  #   Hash.new_from_key_value_list(1,2, 3,4, 5,6)
  #
  # will result in
  #
  #   {1 => 2, 3 => 4, 5 => 6}
  #
  def self.new_from_key_value_list(*list) 
    raise ArgumentError if list.length % 2 != 0 
    obj = allocate()
    `
    // 
    // we use an associate array to store the items. But unlike
    // Javascript, the entries are arrays which contain the collisions.
    // NOTE that we have to prefix the hash code with a prefix so that
    // there are no collisions with methods etc.   
    // I prefix it for now with ":".
    //
    var items = {};
    var hashed_key, current_key, current_val;
   
    for (var i = 0; i < #<list>.length; i += 2)
    {
      current_key = #<list>[i];
      current_val = #<list>[i+1];
      hashed_key = ":" + current_key.#<m:hash>();

      // make sure that a bucket exists
      if (!items[hashed_key]) items[hashed_key] = [];

      items[hashed_key].push(current_key, current_val);
    }

    #<obj>.#<attr:items> = items; 
    #<obj>.#<attr:default_value> = #<nil>;
    return #<obj>;
    `
  end

  def self.new_from_jsobject(jsobj) 
    obj = new()
  end

  def [](key) `
    if (!#<self>.#<attr:items>)
    {
      // this is a Javascript Object, not a RubyJS Hash object.
      // we directly look the key up. it's fast but not Ruby-like,
      // so be careful!
      
      var elem = #<self>[#<key>];
      return (elem == null ? #<nil> : elem);
    }

    var hashed_key = ":" + #<key>.#<m:hash>();
    var bucket = #<self>.#<attr:items>[hashed_key];

    if (bucket)
    {
      //
      // find the matching element inside the bucket
      //

      for (var i = 0; i < bucket.length; i += 2)
      {
        if (bucket[i].#<m:eql?>(#<nil>,#<key>))
          return bucket[i+1];
      }
    }

    // no matching key found -> return default value
    return #<self>.#<attr:default_value>;
    `
  end

  def []=(key, value) `
    if (!#<self>.#<attr:items>)
    {
      // this is a Javascript Object, not a RubyJS Hash object.
      // we directly look the key up. it's fast but not Ruby-like,
      // so be careful!
      
      #<self>[#<key>] = #<value>;
      return #<value>; 
    }

    var hashed_key = ":" + #<key>.#<m:hash>();
    var bucket = #<self>.#<attr:items>[hashed_key];

    if (bucket)
    {
      //
      // find the matching element inside the bucket
      //

      for (var i = 0; i < bucket.length; i += 2)
      {
        if (bucket[i].#<m:eql?>(#<nil>,#<key>))
        {
          // overwrite value
          bucket[i+1] = #<value>;
          return #<value>;
        }
      }
      // key not found in this bucket. append key, value pair to bucket
      bucket.push(#<key>, #<value>);
    }
    else 
    {
      //
      // create new bucket
      //
      #<self>.#<attr:items>[hashed_key] = [#<key>, #<value>];
    }
    return #<value>;
    `
  end

  def keys
    map {|k,v| k}
  end

  def values
    map {|k,v| v}
  end

  def each() `
    if (!#<self>.#<attr:items>)
    {
      // this is a Javascript Object, not a RubyJS Hash object.
      // we directly look the key up. it's fast but not Ruby-like,
      // so be careful!
      var key, value;
      for (key in #<self>)
      {
        value = #<self>[key];`
        yield `(key == null ? #<nil> : key)`, `(value == null ? #<nil> : value)`;
     `
      }
      
      return #<nil>;
    }

    var key, bucket, i;
    for (key in #<self>.#<attr:items>)
    {
      if (key.charAt(0) == ":")
      {
        bucket = #<self>.#<attr:items>[key];
        for (i=0; i<bucket.length; i+=2)
        {`
        yield `bucket[i]`, `bucket[i+1]`
        `
        }
      }
    }
    return #<nil>;
    `
  end

  def inspect
    str = "{"
    str += map {|k, v| (k.inspect + "=>" + v.inspect) }.join(", ")
    str += "}"
    str
  end

  def to_s
    strs = []
    each {|k, v| strs << k; strs << v}
    strs.join("")
  end

end
