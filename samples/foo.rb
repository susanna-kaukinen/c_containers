

module B

	attr_accessor :bbb1

	def initialize
		@bbb1 = 0
		@bbb2 = 0
	end
end


class A

	include B

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

clas = b

case clas

	when A:
		print 'yes, class a'
		
		puts   clas.bbb1
	else
		print 'que?'
	
end

puts

if(b==A)
	print 'yes'
else
	print 'no'
end
puts

if(b === A)
	print 'yes'
else
	print 'no'
end



