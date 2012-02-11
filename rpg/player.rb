
def send_msg(player, call, *vargs) # typically: player, call, [opt]

	msg = Array.new
	msg.push(call)

	vargs.each { |varg|
		msg.push(varg)
	}

	player.tell(msg)
end

def send_question(player, replyto, question, *vargs)

	msg = Array.new

	msg.push(replyto)
	msg.push(question)

	vargs.each { |varg|
		msg.push(varg)
	}

	player.ask(msg)
end


#<def_Player>
class Player

	attr_accessor :id
	attr_accessor :name
	attr_accessor :thread
	attr_accessor :character
	attr_accessor :current_side

	def initialize(name, socket, games)

		@id = SecureRandom.uuid

		@monitor = Monitor.new

		@assertions = SynchronisedStack.new
		@questions  = SynchronisedStack.new #FIXME
		#@assertions = Array.new
		#@questions  = Array.new

		@name   = name
		@socket = socket
		@games  = games

		@character = nil
		@current_game = nil

	end

	#<def_run>
	def run(threads)

		def _cleanup(cause)
			begin

				if(not @socket.closed?)
					if(cause != nil)
						write(cause.to_s)
						write(cause.message)	
						write(cause.backtrace.inspect)
					end
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

						if(i%1000000==0) then
							if(character != nil)
								print "#{name}/#{character.name}: #{i} steps\n"
							else
								print "#{name}/char=nil: #{i} steps\n"
							end
						end
						#if(i>=0) then print "#{name}: #{i} steps\n" end

						Thread.pass
						#sleep(0.001)

					}

				rescue Exception => e

					p 'Exception:' + e.to_s

					p e.message  
					p e.backtrace.inspect

					_cleanup(e)
				end

				_cleanup(nil)
			}




	end
	# </def_run>

	def step

		# tell
		while(@assertions.length>0)

			msg = @assertions.shift

	
			if    ( msg[0] == 'create_character')

				create_character(self)

			elsif ( msg[0] == 'choose_game' )

				choose_game(@games, self)

			elsif ( msg[0] == 'join_game')

				game = msg[1]
				game.join(self)

			elsif ( msg[0] == 'waiting_room' )

				game = msg[1]
				waiting_room(game, self)

			elsif ( msg[0] == 'play_game')

				@current_game = msg[1]
				@current_game.enter(self)

			elsif ( msg[0] == 'clear_screen')

				write(SCREEN_CLEAR+CURSOR_UP_LEFT)

			elsif ( msg[0] == 'draw')

				write("#{msg[1]}")

			elsif ( msg[0] == 'cursor_clear_rows' )

				amt_rows = msg[1]
				cursor_clear_rows(amt_rows)

			elsif ( msg[0] == 'ack')

				read

			elsif ( msg[0] == 'game_over' )

				if(@current_game) then 
					@current_game = nil
				end


				create_character(self)

			else
				err = "UNKNOWN MESSAGE: #{msg}\n" 
				raise NameError.new(err)

			end
			#}
		end

		# ask
		while (@questions.length>0)

			msg = @questions.shift

			replyto  = msg[0]
			question = msg[1]

			print "<<<<<ASK'D: #{question} /ASK'D>>>>>"

			response = Array.new
			response.push(question) # type
			response.push('reply')  # sub_type

			if(question == 'prompt_all')
				choice = read
			elsif(question == 'exit')
				_cleanup(NameError.new('player requested exit'))
			else
				choice = read
			end
			response.push(choice)

			if(replyto != nil)
				replyto.call(response)
			end
		end
	end
	

	def tell(*vargs)
		@assertions.push(*vargs)
	end

	def ask(*vargs)
		@questions.push(*vargs)
	end

	def respond(response)
		tell(response)
	end

	def write(*vargs)

		if(vargs[0].is_a? Array)
			return write(*vargs[0]), write(*vargs[1..(vargs.length)])
		end

		vargs.each {|v|
=begin
			print COLOUR_MAGENTA
			p v
			print COLOUR_CYAN
			v = v.gsub("\n", "\n\r")
			p v
			print COLOUR_RESET
=end
=begin
			print COLOUR_CYAN
			p v
			print COLOUR_RESET
=end
			@socket.write(v)
		}
		
		@socket.flush
	end

	def write2(*vargs)

		vargs.each { | varg |
			
			i=0
			while i < varg.length
				@socket.putc(varg[i])
				i += 1
			end
		}
		@socket.flush
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

