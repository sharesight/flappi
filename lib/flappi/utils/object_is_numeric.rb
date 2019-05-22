# frozen_string_literal: true

class Object
  # Is the object an integer or convertible thereto?
  def is_i?
    return false if nil?

    try(:to_i).to_s == to_s
  end

  # Is the object a float or convertible thereto?
  def is_f?
    return false if nil?

    to_s =~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/
  end
end
