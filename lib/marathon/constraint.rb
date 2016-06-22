# This class represents a Marathon Constraint.
# See https://mesosphere.github.io/marathon/docs/constraints.html for full details.
class Marathon::Constraint < Marathon::Base

  # Create a new constraint object.
  # ++array++: Array returned by API, holds attribute, operator and parameter.
  def initialize(array)
    raise Marathon::Error::ArgumentError, 'array must be an Array' unless array.is_a?(Array)
    raise Marathon::Error::ArgumentError,
          'array must be [attribute, operator, parameter] where only parameter is optional' \
      unless array.size != 2 or array.size != 3
    super
  end

  def attribute
    info[0]
  end

  def operator
    info[1]
  end

  def parameter
    info[2]
  end

  def to_s
    if parameter
      "Marathon::Constraint { :attribute => #{attribute} :operator => #{operator} :parameter => #{parameter} }"
    else
      "Marathon::Constraint { :attribute => #{attribute} :operator => #{operator} }"
    end
  end

  # Returns a string for listing the constraint.
  def to_pretty_s
    info.join(':')
  end
end