# Some helper things
class Marathon::Util
  class << self

    # Checks if parameter is of allowed value.
    # ++name++: parameter's name
    # ++value++: parameter's value
    # ++allowed++: array of allowd values
    # ++nil_allowed++: allow nil values
    def validate_choice(name, value, allowed, nil_allowed = true)
      if value.nil?
        unless nil_allowed
          raise Marathon::Error::ArgumentError, "#{name} must not be nil"
        end
      else
        # value is not nil
        unless allowed.include?(value)
          msg = nil_allowed ? "#{name} must be one of #{allowed}, or nil" : "#{name} must be one of #{allowed}"
          raise Marathon::Error::ArgumentError, msg
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
  end
end