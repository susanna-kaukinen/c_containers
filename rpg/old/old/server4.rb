#!/home/susanna/.rvm/rubies/ruby-1.9.3-p0/bin/ruby

require 'socket'
require 'monitor'
require 'rubygems'
require 'json'
require 'yaml'
require 'securerandom'

Thread.abort_on_exception = true

require 'monitor'


class Player

	attr_accessor :name

	def initialize(name)

		@assertions = Array.new
		@questions  = Array.new

		@name = name
	end

	def run(threads)

		def _cleanup(e)
			p e
			print 'SOUTH'
			exit
		end

		begin
			Thread.start() {

				i=0
				loop {

					step

					i += 1

					if(i>0) then print "#{name}: #{i} steps\n" end

					Thread.pass
					sleep(0.001)

				}
			}

		rescue Exception => e

			_cleanup(e)

		end

	end

	def step

		if(@assertions.length>0)
			ass = @assertions.pop
			ass.each { | msg | print "[#{msg}]\n" }
		end

		if(@questions.length>0)

			ques = @questions.pop

			ques.each { | replyto, question | 
				
				if(question[0..2] == 'who')
					replyto.call("I am #{@name}")
				end
			}
		end
	end
	

	def tell(*vargs)
		@assertions.push(vargs)
	end

	def ask(what, reply_to)
		h = Hash.new
		h[reply_to] = what
		@questions.push(h)
	end

	def respond(response)
		tell(response)
	end

end



def main

	threads = Hash.new

	p1 = Player.new('p1')
	p2 = Player.new('p2')

	p1.run(threads)
	p2.run(threads)
	p threads

	a = ''
	while a.length<2

	#	p1.tell(p2.name, 'says', 'hello')

	#	p2.ask('who are you', p1.method(:respond))
	#	p1.ask('who are you', p2.method(:respond))

		#p threads


		sleep(0.5)
		#a=gets
	end

end

main



