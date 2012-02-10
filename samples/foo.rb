
class A

	attr_accessor :a

	def initialize
		@a=0
	end

	def inc
		@a += 1
	end
end


b = A.new

b.a += 3

print b.a
print "\n"

b.inc

print b.a
print "\n"
