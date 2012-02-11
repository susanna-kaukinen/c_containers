class Games

	def initialize
		@games = Array.new # FIXME should prolly be synch'd
	end

	def add_games(*vargs)
		vargs.each { |game| @games.push(game) }
	end

	def del_game(instance_id)
		@games.each_with_index { |game,i|
			if(game.instance_id == instance_id)
				game=nil
				@games.delete_at(i)
				return
			end
		}
		raise ArgumentError.new("Cannot find instance_id=#{instance_id} to delete!")
	end

	def length
		@games.length
	end

	def get_all
		return @games
	end

end

class Players


	def initialize()
		@players = Array.new # FIXME synch
	end

	def add(player)
		@players.push(player)
	end

	def del(player)
		@players.each_with_index { |p,i|		
			if(p.id == player.id)
				@players.delete_at(i)
				return
			end
		}
		raise :could_not_delete_player_not_found
	end

	def length
		@players.length
	end

	def left?
		@players.length > 0 ? true : false
	end
	
	def all
		return @players.clone
	end

	def write_all(*vargs)
		@players.each { |player| player.write(*vargs) }
	end

	def send_all(call, *vargs)
		@players.each { |player|
			send_msg(player, call, *vargs)
		}
	end

	def send_active_player(character, call, *vargs)
		@players.each_with_index { |player,i|
			if(character.current_player_id != nil and character.current_player_id == player.character.current_player_id)
				send_msg(player, call, *vargs)
				return
			end
		}
		raise :player_missing
	end

	def send_all_but_active_player(character, call, *vargs)
		@players.each_with_index { |player,i|
			if(character.current_player_id != nil and character.current_player_id != player.character.current_player_id)
				send_msg(player, call, *vargs)
			end
		}
	end

	def ask_active_player(character, question, reply_to)
		@players.each_with_index { |player,i|
=begin
			p player
			p i

			p 'char'
			if(character)
				p character
				if (character.current_player_id)
					p character.current_player_id
				end
			end

			p 'pchar'
			if(player.character)
				p player.character
				if(player.character.current_player_id)
					p player.character.current_player_id
				end
			end
=end

			if(character.current_player_id != nil and character.current_player_id == player.character.current_player_id)
				send_question(player, reply_to, question, nil)
				return
			end
		}
		raise :player_missing
	end

	def ask_all(question, reply_to, *vargs)
		@players.each_with_index { |player,i|
			send_question(player, reply_to, question, *vargs)
		}
	end

	def get_player(player_id)
		@players.each_with_index { |player,i|
			if(player_id == player.id)
				return player
			end
		}
		raise :player_missing
	end

end

class Game

	include RuleMonsterEngine

	attr_accessor :name
	attr_accessor :instance_id
	
	def initialize(name, games)

		@games = games # for restructor

		@instance_id = SecureRandom.uuid

		@message_queue = SynchronisedStack.new

		@name = name

		@combatants = Array.new    # all npcs + pcs
 
		@side1 = Array.new    # all friendly fighters
		@side2 = Array.new    # all opposing fighters
 
		@players    = Players.new

	end


	def Game.finalize(id)
		puts COLOR_MAGENTA + "Object #{id} dying at #{Time.new}" + COLOUR_RESET
	end

	def join(player)
		@players.add(player)
		@players.write_all("#{player.character.name} entered game #{name}")

		send_msg(player, 'waiting_room', self)
		throw :done
	end

	def leave(player)
		@players.del(player)
		@players.write_all("#{player.character.name} left game #{name}")
	end

	def amt_players
		return @players.length
	end

	def players
		@players.all
	end

	def invite_all # FIXME
		players.each { |player|
			send_msg(player, 'play_game', self)
		}
	end

	def enter(player)

		Thread.start() do
	
			begin	
				fight
			rescue Exception => e

				p e.message  
				p e.backtrace.inspect
				throw :error_during_game

			ensure
				# child should delete game

			end
		end

		throw :done # caller goes back
	end

	def send_all(call, *vargs)
		@players.send_all(call, *vargs)
	end

	def send_all_but_active_player(character, call, *vargs)
		@players.send_all(character, call, *vargs)
	end

	def send_active_player(character, call, *vargs)
		@players.send_active_player(character, call, *vargs)
	end

	def draw_active_player(character, *vargs)
		send_active_player(character, 'draw',*vargs)
	end

	def draw_all(*vargs)
		@players.send_all('draw', *vargs)
	end

	def draw_all_but_active_player(character, *vargs)
		@players.send_all_but_active_player(character, 'draw',*vargs)
	end

	def message_push(response)
		@message_queue.push(response)
	end

	def message_handler(question)

		i=0
		loop {
			if(@message_queue.length>0)

				msg = @message_queue.shift
				type     = msg[0]
				sub_type = msg[1]

				p "{{{{{GAME: #{msg} :/GAME}}}}}"

				if(question == type)

					if(type == 'prompt_anyone')
						return	
					end

					if(type == 'prompt_all')
						@waiting_for_n_players -= 1

						p "@waiting_for_n_players"
						p @waiting_for_n_players

						if(@waiting_for_n_players <= 0)
							p "@waiting_for_n_players RELEASE"
							throw :all_players_prompted
						end	
					end

					if(sub_type=='reply')
						choice = msg[2]
						print COLOUR_GREEN + "CHOICE = #{choice}" + COLOUR_RESET + EOL
						return choice
					end
				else 
					p "discarding #{type}/#{sub_type}, when question=#{question}"
				end
			end

			i +=1

			Thread.pass

			#if(i%1000000==0) then print "GAME: #{i} steps\n" end
			sleep(0.1)
			if(i%100==0) then print "GAME: #{i} steps\n" end
			#if(i>=0) then print "GAME: #{i} steps\n" end

		}

	end

	def ask_all (question, *vargs)

		@players.ask_all(question, self.method(:message_push), *vargs)

		choice =  nil
		catch (:all_players_prompted) do
			choice = message_handler(question)
		end
		return choice
	end

	def prompt_all()
		question='prompt_all'
		@waiting_for_n_players = @players.length
		return ask_all(question, @waiting_for_n_players)
	end

	def prompt_anyone()
		str = cursor_to(13,64)
		str += COLOUR_BLUE + COLOUR_REVERSE
		str += '<enter>'
		str += COLOUR_RESET
		draw_all(str)
		ask_all('prompt_anyone')
	end


	def ask_active_player(character, question)
		@players.ask_active_player(character, question, self.method(:message_push))
		return message_handler(question)
	end

	def play_rounds

		round=1
		catch (:game_over) do
			while true

				@side1.each { |char| char.roll_initiative }
				@side2.each { |char| char.roll_initiative }

				@side1.sort! { |a,b| a.initiative <=> b.initiative }
				@side2.sort! { |a,b| a.initiative <=> b.initiative }

				@combatants.sort! { |a,b| a.initiative <=> b.initiative }

				play_round(round)

				round=round+1
			end
		end

		send_all('clear_screen')
		send_all('draw', 'GAME OVER - ENTER TO GET BACK')
		send_all('ack')
		send_all('game_over')
	end

end


