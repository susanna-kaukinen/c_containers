#!/usr/bin/ruby

a = 'Hello world'
puts(a[3])
#puts a.methods

i=0
while i<3
	system('whoami')
	i=i+1
end

i=0
system ('whoami') until (i=i+1)==7

b = 'Hello, Ruby'
puts b['Ruby']

puts b
i=-1
print i , '=>' , b[i..i],"\n" until (i=i+1)==b.length

i=0
print 'Sentence num=',i,"\n" until (i=i+1)==7

print 'foo'=='foo',"\n"

catch (:done) do
	while true
		guess=1+secret=rand(10)+1

		until guess.to_i==secret
			puts 'Guess twixt 1 and 10'
			guess = gets
			throw :done if guess=="q\n"
			print 'You guessed=' , guess, "\n"
			print 'Hint:',secret,"\n"
		end

		print 'yes!',"\n"
	end
end



