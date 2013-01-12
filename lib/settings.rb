require 'ostruct'
require 'erb'

class Settings < OpenStruct
  def erb(template)
    ERB.new(template).result(binding)
  end
end