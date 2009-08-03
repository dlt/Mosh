class Mosh < Hash

	def initialize(hash = {})
	end

	def extract_method_names(response_sample, prefix = '')
 		response_sample.each_pair.inject([]) do |arr, (key, value)|
    	method_name = prefix + key
			if value.is_a?(Hash)
      	arr << extract_hash_method_names(value, method_name + '_')
			elsif value.is_a?(Array) && all_items_are_hashes(value)
      	arr << extract_array_method_names(value, method_name + '_')
      end
      arr << method_name
    end.flatten
	end

	def extract_hash_method_names(hash, prefix = '')
  	meths = extract_method_names(hash, prefix)
    meths.each do |method_name|
    	add_method(hash, method_name)
    end
    meths
  end

	def extract_array_method_names(array, prefix = '')
  	array.collect {|item| extract_hash_method_names(item, '')}.flatten
	end

	def add_method(response_item, method_name)
  	keys = method_name.split '_'
    method = method_string(method_name.gsub(':','_'), keys)
    response_item.instance_eval method
	end
   
	def all_items_are_hashes(array)
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
end
