require 'ostruct'
require 'brock'
require 'erb'

class Settings
  attr_reader :schema, :values

  def initialize(definitions, values={})
    @schema = Brock::Schema.new(definitions)
    @values = values
  end

  def method_missing(meth, *args, &block)
    name = meth.to_sym

    if field = schema.fields.find{|f| f.name == name }
      field_value(field, name)
    elsif value = values[name]
      value
    else
      nil
    end
  end

  def field_value(field, name)
    if values.has_key?(name)
      field.parse_param(values[name])
    else
      field.default
    end
  end

  def erb(template)
    ERB.new(template).result(binding)
  end
end