#!/usr/bin/ruby

def pr(*vargs)
	vargs.each { |str| print str.to_s }
	print "\n"
end

pr 'create hash easily:'

A = { 'age' => 10 }
B = { 'age' => 20 }
C = { 'age' => 30 }

pr 'print hash easily:'

[A,B,C].each { |a| p a }

pr 'sum values from hash easily:'

sum = [A,B,C].inject(0) {|sum, o| sum + o['age']}

pr 'sum=' , sum

pr 'find smallest index in hash easily:'

array = [A,B,C]
min_index = array.each_with_index.inject(0) { |min_index, (current_hash, current_index) | 
	current_hash['age'] < array[min_index]['age'] ? current_index : min_index 
}
		
pr "hash w/smallest value for key='a':"

p array[min_index]

pr "hash w/greatest value for key='a':"

max_index = array.each_with_index.inject(0) { |max_index, (current_hash, current_index) |
	current_hash['age'] > array[max_index]['age'] ? current_index : max_index
}

p array[max_index]

pr "Tai lyhyemmin:"

max = array.each_with_index.inject(0) { |max, (obj, idx) | obj['age'] > array[max]['age'] ? idx : max }

p array[max]
