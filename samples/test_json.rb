#!/home/susanna/.rvm/rubies/ruby-1.9.3-p0/bin/ruby

require "json"
 
class A
  def initialize(string, number)
    @string = string
    @number = number
  end
 
  def to_s
    "In A:\n   #{@string}, #{@number}\n"
  end
 
  def to_json(*a)
    {
      "json_class"   => self.class.name,
      "data"         => {"string" => @string, "number" => @number }
    }.to_json(*a)
  end
 
  def self.json_create(o)
    new(o["data"]["string"], o["data"]["number"])
  end
end

a = A.new("hello world", 5)
json_string = a.to_json
a = nil
puts json_string
b = JSON.parse(json_string)

print b.to_s

