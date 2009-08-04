class Mosh < Hash

  def initialize(arg = {})
    copy_values arg
    add_hash_methods(arg, '', true)
  end

  def []=(key, value)
    key   = convert_key key
    value = convert_value value
    add_method(key, self)
    super
  end
  
  def [](key)
    key = convert_key key
    super
  end

  private
  def convert_key(key); key.to_s; end
  
  def convert_value(value)
    case value
      when Hash
        Mosh.new(value)
      when Array
        value.each_with_index {|item, idx| value[idx] = Mosh.new item if item.is_a? Hash}
      else
        value
    end
  end

  def extract_method_names(hash, prefix = '')
     hash.each_pair.inject([]) do |arr, (key, value)|

      method_name = prefix + key.to_s
      arr << method_name

      case value
        when Hash
          arr << add_hash_methods(value, method_name + '_')
        when Array 
          arr << extract_array_method_names(value, method_name + '_') if all_items_are_hashes?(value)
      end
      arr
    end.flatten
  end

  def add_hash_methods(hash, prefix = '', add_to_self = false)
    meths = extract_method_names(hash, prefix)
    meths.each do |method_name|
      if add_to_self
        add_method(method_name, self)
      else
        add_method(method_name, hash)
      end
    end
  end

  def extract_array_method_names(array, prefix = '')
    array.collect {|item| add_hash_methods(item, '')}.flatten 
  end

  def add_method(method_name, obj)
    keys    = method_name.split '_'
    method  = method_string(method_name.gsub(':','_'), keys)
    obj.instance_eval method unless self.respond_to? method
  end
   
  def all_items_are_hashes?(array)
    array.each do |item|
      return false unless item.is_a? Hash
    end
    true
  end

  def method_string(method_name, keys)
    hash_accessor = hash_keys_as_string(keys)
    %Q{
      def #{method_name}
        self#{hash_accessor}
      end
    }
  end

  def hash_keys_as_string(keys)
    keys.map {|k| "['#{k}']"}.join
  end

  def copy_values(other)
    other.each_pair{|key, value| self[key] = value}
  end
end
