# Base class for all the API specific classes.
class Marathon::Base

  include Marathon::Error

  attr_reader :info

  # Create the object
  # ++hash++: object returned from API. May be Hash or Array.
  # ++attr_readers++: List of attribute readers.
  def initialize(hash, attr_readers = [])
    raise ArgumentError, 'hash must be a Hash' if attr_readers and attr_readers.size > 0 and not hash.is_a?(Hash)
    raise ArgumentError, 'hash must be Hash or Array' unless hash.is_a?(Hash) or hash.is_a?(Array)
    raise ArgumentError, 'attr_readers must be an Array' unless attr_readers.is_a?(Array)
    @info = Marathon::Util.keywordize_hash(hash)
    attr_readers.each { |e| add_attr_reader(e) }
  end

  # Return application as JSON formatted string.
  def to_json
    info.to_json
  end

  private

  # Create attr_reader for @info[key].
  # ++key++: key in @info
  def add_attr_reader(key)
    sym = key.to_sym
    self.class.send(:define_method, sym.id2name) { |*args, &block| info[sym] }
  end
end