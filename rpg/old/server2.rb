#!/home/susanna/.rvm/rubies/ruby-1.9.3-p0/bin/ruby

require 'socket'
require 'monitor'
require 'rubygems'
require 'json'
require 'yaml'
require 'securerandom'

Thread.abort_on_exception = true

class Player

	attr_accessor :name

	include MonitorMixin

	def initialize(*args, name)
		super(*args)

		@assertions = Array.new # stack
		@questions  = Array.new # stack

		@name = name
	end

	def run()

		def _cleanup()
			print 'SOUTH'
			exit
		end

		begin
			Thread.start() {

				@thread = Thread.current

				i=0
				loop {
					self.synchronize do
	
						step

						Thread.pass

						i += 1

						if(i%1000==0) then print "#{name}: #{i} steps\n" end

						#sleep(0.001) # replace with a lock that gets kicked when we get a msg
					end
				}
			}

		rescue Exception => e

			_cleanup

		end

	end

	def step

		if(@assertions.length>0)
			ass = @assertions.pop
			ass.each { | msg | print "[#{msg}]" }
		end

		if(@questions.length>0)

			que = @questions.pop

			que.each { | replyto, question | 
				
				if(question[0..2] == 'who')
					replyto.call("I am #{@name}")

				end
			}
		end

	end
	

	def tell(*vargs)
		self.synchronize do
			@assertions.push(vargs)
		end
	end

	def ask(what, reply_to)
		self.synchronize do
			h = Hash.new
			h[reply_to] = what
			@questions.push(h)
		end
	end

	def respond(response)
		tell(response)
	end

end


def main

	p1 = Player.new('p1')
	p2 = Player.new('p2')

	p1.run
	p2.run

	p1.tell(p2.name, 'says', 'hello')

	p2.ask('who are you', p1.method(:respond))
	p1.ask('who are you', p2.method(:respond))


	a = ''
	while a.length<2
		a=gets
	end

end

main



