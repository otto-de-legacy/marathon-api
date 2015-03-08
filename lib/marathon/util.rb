# Some helper things.
class Marathon::Util
  class << self

    # Checks if parameter is of allowed value.
    # ++name++: parameter's name
    # ++value++: parameter's value
    # ++allowed++: array of allowd values
    # ++nil_allowed++: allow nil values
    def validate_choice(name, value, allowed, nil_allowed = true)
      value = value[name] if value.is_a?(Hash)
      if value.nil?
        unless nil_allowed
          raise Marathon::Error::ArgumentError, "#{name} must not be nil"
        end
      else
        # value is not nil
        unless allowed.include?(value)
          if nil_allowed
            raise Marathon::Error::ArgumentError,
              "#{name} must be one of #{allowed.join(', ')} or nil, but is '#{value}'"
          else
            raise Marathon::Error::ArgumentError,
              "#{name} must be one of #{allowed.join(', ')} or nil, but is '#{value}'"
          end
        end
      end
    end

    # Check parameter and add it to hash if not nil.
    # ++opts++: hash of parameters
    # ++name++: parameter's name
    # ++value++: parameter's value
    # ++allowed++: array of allowd values
    # ++nil_allowed++: allow nil values
    def add_choice(opts, name, value, allowed, nil_allowed = true)
      validate_choice(name, value, allowed, nil_allowed)
      opts[name] = value if value
    end

    # Swap keys of the hash against their symbols.
    # ++hash++: the hash
    def keywordize_hash(hash)
      if hash.is_a?(Hash)
        new_hash = {}
        hash.each do |k,v|
          new_hash[k.to_sym] = keywordize_hash(hash[k])
        end
        new_hash
      elsif hash.is_a?(Array)
        hash.map { |e| keywordize_hash(e) }
      else
        hash
      end
    end

    # Merge two hashes but keywordize both.
    def merge_keywordized_hash(h1, h2)
      keywordize_hash(h1).merge(keywordize_hash(h2))
    end
  end
end