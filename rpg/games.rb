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

		mem_dump

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
		return ask_all('prompt_anyone')
	end


	def ask_active_player(character, question)
		@players.ask_active_player(character, question, self.method(:message_push))
		return message_handler(question)
	end

end


class Orcs < Game

	def initialize(*args)
		super('orcs', *args)

		@sides = Array.new
		@sides.push('humans')
		@sides.push('orcs')
	end

	def Orcs.finalize(id)
		puts COLOR_MAGENTA +  "Object #{id} dying at #{Time.new}" + COLOUR_RESET
	end

	def get_sides
		@sides.clone
	end

	def restructor
		@games.del_game(@instance_id)
		game = Orcs.new(@games)
		@games.add_games(game)
	end

	def fight
		init_fight
		play_rounds
		restructor
	end

	def target_debug(*vargs)
		#print 'TARGET_DEBUG: ==>'
		print vargs
		print "\n"
	end

	def play_sub_round(round, sub_round_number, combatants, friends, enemies, actor )

		def _attack(character, opponents)

			def __choose_opponent(attacker, opponents)

				def ___prune_non_targets(personality, opponents)

					choice=''
			
					opps = Array.new

					if(personality == 'evil')

						choice = 'weakest'

						opponents.each { |opp|

							opp.check_hitpoints

							if (not opp.dead)
								target_debug COLOUR_GREEN + "#{opp.name} not dead, good target" + COLOUR_RESET
								opps.push(opp)
							else
								target_debug COLOUR_RED + "#{opp.name} is dead, not a target" + COLOUR_RESET
							end
						}
					else
						opponents.each { |opp|

							opp.check_hitpoints

							if (opp.current_hp>0 and not opp.dead and not opp.unconscious)
								target_debug COLOUR_GREEN + "#{opp.name} good target" + COLOUR_RESET
								opps.push(opp)
							else
								target_debug COLOUR_RED + "#{opp.name} not hp>0+not dead+not unco, not a target" + COLOUR_RESET
							end
						}

						if(personality == 'smart')
							choice = 'weakest'
						else
							choice = 'strongest'
						end

					end

					return opps, choice
				end

				def ___choose_from_remaining(opps, choice)

					def ____stronger(opp1, opp2)
			
						if(opp1.strength > opp2.strength)
							return true
						end
			
						return false
					end

					def ____weaker(opp1, opp2)

						if(opp1.strength < opp2.strength)
							return true
						end
			
						return false

					end

					case choice
						when 'weakest'
							idx = opps.each_with_index.inject(0) { | min_i, (opp, i) |
								if (____weaker(opp, opps[min_i]))
									i
								else
									min_i
								end
							}
							return opps[idx]

						when 'strongest'

							idx = opps.each_with_index.inject(0) { | max_i, (opp, i) |
								if (____stronger(opp, opps[max_i]))
									i
								else
									max_i
								end
								
							}
							return opps[idx]
					end
				end

				# __choose_opponent
		
				target_debug "total targets: #{opponents.length}"
				opps, choice = ___prune_non_targets(attacker.personality, opponents)
				target_debug "pruned targets: #{opps.length}"
				chosen_opponent = ___choose_from_remaining(opps, choice)

				opponents.each { |o| target_debug "#{o.name}=#{o.strength.to_s} (str)" }
				target_debug "#{attacker.name} (#{attacker.personality}) chose: #{chosen_opponent.name}"

				return chosen_opponent, attacker.personality

			end

			def __do_attack(attacker, opponent, manner)

				if(opponent==nil)
					draw_all "No-one to attack!"
					return
				end

				text = COLOUR_GREEN + 
				 	 COLOUR_REVERSE + 
					 attacker.name +
					 COLOUR_RESET +
					 " ATTACKS " +
					 COLOUR_RED +
					 COLOUR_REVERSE +
					 opponent.name +
					 COLOUR_RESET +
					  " with " +
					 attacker.active_weapon.name +
					 " in a " +
					 manner +
					 " manner..\n"

				__roll  = roll('attack', attacker.active_weapon, attacker, method(:__do_attack))
				_roll   = __roll[0]
				fumble  = __roll[2]
				text   += __roll[3]

				if(fumble==true)
					return
				end 

				block = opponent.blocks?(attacker.name)

				if(block>0)
					text += opponent.name + COLOUR_CYAN + ' blocks' + COLOUR_RESET + ' against ' + attacker.name + " w/#{block}"
				end

				result = attacker.current_ob - opponent.current_db - block + _roll

				text += " => result:" + result.to_s() + "\n"
				#print "ob-db-block+roll=result <=> #{attacker.current_ob}-#{opponent.current_db}-#{block}+#{_roll}=#{result}"

				text += attacker.active_weapon.deal_damage(attacker, opponent, result)

				return text
			end

			# _attack

			can_attack, why_cant = character.can_attack_now()

			if(can_attack)
				opponent, manner = __choose_opponent(character, opponents)
				text = __do_attack(character, opponent, manner)
				opponent.apply_wound_effects_after_attack
				return true, text, opponent
			end

			text = _explain_why_not(character, 'attack', why_cant)
			return false, text, nil
		end


		def _explain_why_not(character, what, why_cant)

			str = COLOUR_WHITE + COLOUR_REVERSE + character.name + COLOUR_RESET + " cannot " + what + ", reason: "

			if    (why_cant == nil)
				str += COLOR_MAGENTA + 'not able'
			elsif (why_cant == 'dead')
				str += COLOUR_RED + COLOUR_REVERSE
			elsif (why_cant == 'unconscious')
				str += COLOUR_RED
			elsif (why_cant == 'prone')
				str += COLOUR_YELLOW + COLOUR_REVERSE
			elsif (why_cant == 'downed')
				str += COLOUR_YELLOW_BLINK
			else
				str += COLOUR_YELLOW
			end

			str += " " + why_cant + COLOUR_RESET

			return str

		end

		def _heal(character, friends)

			if(not character.can_heal?)
				text = _explain_why_not(character, 'heal', 'not enough mana?')
				draw_active_player(character, text)
				return false
			end

			text='' #TODO

			loop {
				draw_active_player(character, 'Choose action:')

				prompt = ' (e)=all Equally' + "\n "

				friends.each_with_index { |opponent,i|
					prompt += "(#{i})" + opponent.name + " "
					if(i%2==1)
						prompt += "\r\n "
					end
				}
				
				draw_active_player(character, prompt)

				cmd = ask_active_player(character, 'heal_action')

				if(cmd == 'e')
			
					character.heal(friends)

					draw_active_player(character, "Healing all friends.")

					return true, text
				else
					friends.each_with_index { |healee,i|
						if(cmd == i.to_s)
							character.heal(healee)
							draw_active_player(character, "Healing " + healee.name)
						end
					}

					return true, text
				end
			

			}


		end

		def _block(character, opponents)
		
			can_block, why_cant = character.can_block_now()

			if(can_block==false)
				text = _explain_why_not(character, 'block', why_cant)
				draw_active_player(character, text)
				return false
			end

			loop {
				draw_active_player(character, 'Choose action:')

				prompt = ' (e)=all Equally' + "\n "

				opponents.each_with_index { |opponent,i|
					prompt += "(#{i})" + opponent.name + " "
					if(i%2==1)
						prompt += "\r\n "
					end
				}
				
				draw_active_player(character, prompt)

				cmd = ask_active_player(character, 'block_action')

				if(cmd == 'e')
			
					how_much = character.current_ob / opponents.length
					
					opponents.each_with_index { |opponent,i|
						character.block(opponent.name, how_much)
					}

					draw_active_player(character, "Blocking w/#{how_much} against all opponents.")

					return true
				else
					how_much = character.current_ob / 2

					opponents.each_with_index { |opponent,i|
						if(cmd == i.to_s)
							character.block(opponent.name, how_much)
							draw_active_player(character, "Blocking w/#{how_much} against " + opponent.name)
						end
					}

					return true
				end
			

			}
		end

		def _prompt_actor_actions(character, opponents, friends)


			def _cls(character)
				draw_active_player(character, CURSOR_RESTORE)
				send_active_player(character, 'cursor_clear_rows', 10)
				draw_active_player(character, CURSOR_RESTORE)
			end

			draw_all_but_active_player(character, "#{character.name} ponders action, please wait...")

			can_attack, why_cant_attack = character.can_attack_now()
			can_block,  why_cant_block  = character.can_block_now()

		
			draw_active_player(character, CURSOR_SAVE)	
			loop {

				if(can_attack == false and can_block == false)
					text = _explain_why_not(character, 'do anything', 'is incapacitated')
					draw_active_player(character, text)
					return
				end

				if(character.current_ob<10)
					text = _explain_why_not(character, 'take more actions', 'all ob used up!')
					draw_active_player(character, text)
					return
				end	

				draw_active_player(character, 'Choose action:')

				prompt = ' '
				prompt += "(a)=attack (#{character.current_ob}) " if(can_attack)
				prompt += '(b)=block  ' if(can_block)
				prompt += '(h)=heal   ' if(character.can_heal?)
				
				draw_active_player(character, prompt)

				cmd = ask_active_player(character, 'sub_round_action')

				case cmd
					when 'a'
						_cls(character)
						did_attack, text = _attack(character, opponents) #let char choose target
						if(did_attack)
							return text
						end
					when 'b'
						_cls(character)
						_block(character, opponents)
					when 'h'
						_cls(character)
						did_heal, text = _heal(character, friends)
						if(did_heal)
							return text
						end
				end
			
				_cls(character)
			}
		end

		def _sub_round_init(character)
			draw_all(character.do_bleed)
			character.recover_from_wounds
			character.current_ob = character.ob
			character.current_blocks = Hash.new
		end

		# |play_sub_round

		if(not opponents_left(enemies))
			throw :game_over
		end

		_sub_round_init(actor)

		did_attack = false
		text = ''
		opponent = nil

		if(actor.human?) 
			draw_subround(round, sub_round_number, actor, opponent)
			text = _prompt_actor_actions(actor, enemies, friends) # in the future the npc:s could use this interface as well

		else
			did_attack, text, opponent = _attack(actor, enemies)
			if(did_attack == false) then opponent=nil end
			draw_subround(round, sub_round_number, actor, opponent)
		end

		if(text)
			text = row_proper + text
			draw_all(text)
		end
	end
	#/play_sub_round

	# normal proper row, for attack etc. text
	def row_proper()

		h = (@side1.length > @side2.length) ? @side1.length : @side2.length
		
		row = "\033[" + (3+h).to_s + ';H'
	end

	def draw_subround(rnd, sub_round_number, active_xpc, opponent)

		def _colour_names(xpc, active_xpc, opponent)
		
			name = xpc.name
	
			if(name == active_xpc.name)
				if(xpc.can_attack_now[0])
					name = COLOUR_GREEN + COLOUR_REVERSE + name + COLOUR_RESET
				else
					name = COLOUR_RED   + COLOUR_REVERSE + name + COLOUR_RESET
				end
			elsif(opponent and name == opponent.name)
				name = COLOUR_RED + COLOUR_REVERSE + name + COLOUR_RESET
			else
				if(xpc.dead)
					name = COLOUR_RED    + name + COLOUR_RESET
				elsif(xpc.unconscious)	
					name = COLOUR_BLUE   + name + COLOUR_RESET
				elsif(xpc.prone>0 or xpc.downed>0 or xpc.stun>0)
					name = COLOUR_YELLOW + name + COLOUR_RESET
				elsif(xpc.current_hp/2 > xpc.hp)
					name = COLOUR_GREEN  + name + COLOUR_RESET
				end
			end

			return name
		end


		def _hp_and_wounds_to_s(xpc)

			str = ''

			curr_hp = xpc.current_hp.to_s
			while(curr_hp.length<3)
				curr_hp = ' ' + curr_hp
			end

			str += curr_hp.to_s
			str += '/'

			hp = xpc.hp.to_s
			while(hp.length<3)
				hp += ' '
			end

			str += hp.to_s

			str += ' '
			str += 'u' if (xpc.unconscious)
			str += 'D' if (xpc.dead)
			str += 's' + xpc.stun.to_s       if (xpc.stun>0)
			str += 'd' + xpc.downed.to_s  	 if (xpc.downed>0)
			str += 'p' + xpc.prone.to_s      if (xpc.prone>0)
			str += 'b' + xpc.bleeding.to_s   if (xpc.bleeding>0)

			return str

		end

		top_bar = "==================---/--- Round: #" + rnd.to_s + " (" + sub_round_number.to_s + "/" + @combatants.length.to_s + ") ===========================\n"
		
		str = SCREEN_CLEAR + CURSOR_UP_LEFT
		str += top_bar
		
		print top_bar

		idx_longest_name = @combatants.each_with_index.inject(0) { | max_i, (combatant, idx) | combatant.name.length > @combatants[max_i].name.length ? idx : max_i }

		names_width = @combatants[idx_longest_name].name.length

		@side1.each_with_index { | xpc,i |
			row_col = "\033[" + (2+i).to_s + ';' + '0' + 'H'
			str += row_col

			str += _colour_names(xpc, active_xpc, opponent)

			set_pos_y = "\033[" + '20' + 'G'
			str += set_pos_y

			str += _hp_and_wounds_to_s(xpc)
		}

		@side2.each_with_index { | xpc,i |

			row_col = "\033[" + (2+i).to_s + ';' + '36' + 'H'
			str += row_col

			str += _colour_names(xpc, active_xpc, opponent)
			
			set_pos_y = "\033[" + (36+20).to_s + 'G'
			str += set_pos_y

			str += _hp_and_wounds_to_s(xpc)
		}

		draw_all(str)

		draw_all(EOL)

	end

	def opponents_left(side)
		if(side==@side1)
			return combatants_left(@side2)
		elsif(side==@side2)
			return combatants_left(@side1)
		else
			raise :can_figure_out_opponents
		end
	end

	def combatants_left(side)

		side.each { |char|
			if(char.current_hp>0 and char.dead==false and char.unconscious==false)
				return true
			end
		}
		return false
	end

	def play_round(round)
		p '<<<NEW ROUND>>>'


		sub_round_number=1


		combatants_in_action_order = @combatants.sort { |a,b| a.initiative <=> b.initiative }

		combatants_in_action_order.each { |actor|

			friends = ''
			enemies = '' 

			if(actor.current_side == 1) 
				friends = @side1
				enemies = @side2
			elsif(actor.current_side == 2)
				friends = @side2 
				enemies = @side1
			else
				throw ArgumentError.new "Bad current_side=#{actor.current_side}, #{actor.name}"
			end

			begin
				p '<<<NEW SUB ROUND>>>'
				p "#{actor.name} #{actor.current_side} #{friends[0].name} <-> #{enemies[0].name}"

				play_sub_round(round, sub_round_number, @combatants, friends, enemies, actor )

			rescue Exception => e
	
				p '<<<SUB ROUND ERR HANDLER>>>'

				p "#{e}"
				p e.message  
				p e.backtrace.inspect

			end

			prompt_anyone

			sub_round_number += 1

			if(not @players.left?)
				p "All players have left the game!\n"
				throw :game_over
			end

			if(not combatants_left(@side1) or not combatants_left(@side2))
				throw :game_over
			end
		}
	end

	def play_rounds

		round=1
		catch (:game_over) do
			while true

				@side1.each { |char| char.roll_initiative }
				@side2.each { |char| char.roll_initiative }

				@side1.sort { |a,b| a.initiative <=> b.initiative }
				@side2.sort { |a,b| a.initiative <=> b.initiative }

				play_round(round)

				round=round+1
			end
		end

		send_all('clear_screen')
		send_all('draw', 'GAME OVER - ENTER TO GET BACK')
		send_all('ack')
		send_all('game_over')
	end

	def init_fight

		@players.all.each { |player|
			if(player.character.current_side==1)
				@side1.push(player.character)
			elsif(player.character.current_side==2)
				@side2.push(player.character)
			else
				raise ArgumentError.new("bad_player_side (#{player.character.current_side})")
			end
		}

		while (@side1.length <5) 
			char = Character.new('dummy', 'pc', 'artificial')
			char.current_side = 1
			@side1.push(char)
		end

		rename_humans(@side1)

		while(@side2.length < 5)
			char = Character.new('dummy', 'pc', 'artificial')
			char.current_side = 2
			@side2.push(char)
		end
		
		rename_orcs(@side2)

		@side1.each  { |p| @combatants.push(p) }
		@side2.each  { |p| @combatants.push(p) }

	end
end

class Trolls < Orcs

	def initialize(*args)
		super(*args)

		@name = 'troll'
		@sides = Array.new
		@sides.push('humans')
		@sides.push('trolls')
	end

	def init_fight

		@players.all.each { |player|
			if(player.character.current_side==1)
				@side1.push(player.character)
			elsif(player.character.current_side==2)
				@side2.push(player.character)
			else
				raise ArgumentError.new("bad_player_side (#{player.character.current_side})")
			end
		}

		while (@side1.length <5) 
			char = Character.new('dummy', 'pc', 'artificial')
			char.current_side = 1
			@side1.push(char)
		end

		rename_humans(@side1)

		@side2.push(Troll.new('Gargath the Troll', 'pc', 'artificial'))
		@side2.push(Troll.new('Bargunth the Troll', 'pc', 'artificial'))
	
		@side2.each  { |xpc| xpc.current_side = 2 }

		@side1.each  { |xpc| @combatants.push(xpc) }
		@side2.each  { |xpc| @combatants.push(xpc) }

	end
end


