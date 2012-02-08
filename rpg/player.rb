
#<def_Player>
class Player

	attr_accessor :name
	attr_accessor :thread
	attr_accessor :character

	def initialize(name, socket, games)

		@monitor = Monitor.new

		#@assertions = SynchronisedStack.new
		#@questions  = SynchronisedStack.new #FIXME
		@assertions = Array.new
		@questions  = Array.new

		@name   = name
		@socket = socket
		@games  = games

		@character = nil
	end

	#<def_run>
	def run(threads)

		def _cleanup()
			begin

				if(not @socket.closed?)
					write 'Bye, then!'
					@socket.close
				end

			rescue Exception => e

				p 'Exception:' + e.to_s

				p e.message  
				p e.backtrace.inspect

			ensure
				@socket = nil
				p "#{name} is dead"
				Thread.current.exit
			end
		end


			# <|def_run>
			Thread.start(threads, @name) {

				begin

					threads[name] = Thread.current

					i=0
					loop {

						catch (:done) { 
							step
						}

						i += 1

						#if(i%1000==0) then print "#{name}: #{i} steps\n" end
						#if(i>=0) then print "#{name}: #{i} steps\n" end

						Thread.pass
						sleep(0.001)

					}

				rescue Exception => e

					p 'Exception:' + e.to_s

					p e.message  
					p e.backtrace.inspect

					_cleanup()
				end

				_cleanup()
			}




	end
	# </def_run>

	def step


		# tell
		if(@assertions.length>0)
			ass = @assertions.pop
			ass.each { | msg | 


				if(msg == 'create_character')

					create_character(self)

				elsif ( msg == 'choose_game' )

					choose_game(@games, self)

				elsif ( msg == 'go_lobby')

					write 'TODO'

				elsif ( msg[0] == 'play_game')

					game = msg[1]
					game.enter(self)
	
				elsif ( msg[0] == 'waiting_room' )

					game = msg[1]
					waiting_room(game, self)

				else
					print "UNKNOWN MESSAGE: #{msg}\n" 
					raise  (:unknown_message)

				end
			}
		end

		# ask
		if(@questions.length>0)

			ques = @questions.pop

			ques.each { | question, replyto | 
				
				if(question[0..2] == 'who')
					replyto.call("I am #{@name}")
				elsif(question == 'exit')
					if(replyto!=nil)
						replyto.call("#{name} exiting...")
					end
					_cleanup()
				end
			}
		end
	end
	

	def tell(*vargs)

		@assertions.push(vargs)
	end

	def ask(what, reply_to)
		h = Hash.new
		h[what] = reply_to
		@questions.push(h)
	end

	def respond(response)
		tell(response)
	end

	def write(*vargs)
		@socket.puts(vargs)
	end

	def write2(*vargs)

		vargs.each { | varg |
			
			i=0
			while i < varg.length
				@socket.putc(varg[i])
				i += 1
			end
		}
	end

	def read()
		return @socket.gets().chomp()
	end

	def query(*vargs)
		write(vargs)
		return read	
	end

	def prompt(txt)
		write2(txt + " > ")
		return read
	end

end
# </def_Player>

