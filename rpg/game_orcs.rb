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

		def _attack(character, opponents, override_opponent, opponent)

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

				_text, fury = attacker.active_weapon.deal_damage(attacker, opponent, result)
				text += _text

				return text, fury
			end

			# _attack

			fury=false

			can_attack, why_cant = character.can_attack_now()

			if(can_attack)

				manner = character.personality
				if(not override_opponent)
					opponent, manner = __choose_opponent(character, opponents)
				end

				text, fury = __do_attack(character, opponent, manner)

				opponent.apply_wound_effects_after_attack
				return true, text, opponent, fury
			else	
				text = _explain_why_not(character, 'attack', why_cant)
				return false, text, nil, fury
			end
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
					_cls(character)

					character.heal(friends)

					draw_active_player(character, "Healing all friends.")

					return true, text
				else
					_cls(character)

					friends.each_with_index { |healee,i|
						if(cmd == i.to_s)
							character.heal(healee)
							draw_active_player(character, "Healing " + healee.name)
						end
					}

					return true, text
				end
			
				_cls(character)

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

			def _player_choose_opponent(character, opponents)

				text='' #TODO

				loop {
					draw_active_player(character, 'Choose opponent:')

					prompt = ' (a)=Auto target' + "\n "

					opponents.each_with_index { |opponent,i|
						prompt += "(#{i})" + opponent.name + " "
						if(i%2==1)
							prompt += EOL
						end
					}
					
					draw_active_player(character, prompt)

					cmd = ask_active_player(character, 'attack_option')

					if(cmd == 'a')
						_cls(character)
						return false, text
					else
						_cls(character)

						chosen_opponent = nil

						opponents.each_with_index { |opponent,i|
							if(cmd == i.to_s)
								chosen_opponent = opponent
								break
							end
						}

						return true, text, chosen_opponent
					end
				
					_cls(character)

				}
			end

			def _cls(character)
				draw_active_player(character, CURSOR_RESTORE)
				send_active_player(character, 'cursor_clear_rows', 10)
				draw_active_player(character, CURSOR_RESTORE)
			end

			# _prompt_actor_actions

			draw_all_but_active_player(character, "#{character.name} ponders action, please wait...")

			can_attack, why_cant_attack = character.can_attack_now()
			can_block,  why_cant_block  = character.can_block_now()

		
			draw_active_player(character, CURSOR_SAVE)	
			loop {

				if(can_attack == false and can_block == false)
					text = _explain_why_not(character, 'do anything', 'is incapacitated')
					draw_active_player(character, text)
					return '', false
				end

				if(character.current_ob<10)
					text = _explain_why_not(character, 'take more actions', 'all ob used up!')
					draw_active_player(character, text)
					return '', false
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
						player_chosen, _, opponent = _player_choose_opponent(character, opponents)
						did_attack, text, _, fury = _attack(character, opponents, player_chosen, opponent)

						if(did_attack)
							return text, fury
						end
					when 'b'
						_cls(character)
						_block(character, opponents)
					when 'h'
						_cls(character)
						did_heal, text = _heal(character, friends)
						if(did_heal)
							return text, false
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

		fury = false

		if(actor.human?) 
			draw_subround(round, sub_round_number, actor, opponent)
			text, fury = _prompt_actor_actions(actor, enemies, friends) # in the future the npc:s could use this interface as well

		else
			did_attack, text, opponent, fury = _attack(actor, enemies, false, nil)
			if(did_attack == false) then opponent=nil end
			draw_subround(round, sub_round_number, actor, opponent)
		end

		if(text)
			text = row_proper + text
			draw_all(text)
		end

		while(fury)

			prompt_anyone

			did_attack, text, opponent, fury = _attack(actor, enemies, false, nil)
			if(did_attack == false) then opponent=nil end
			draw_subround(round, sub_round_number, actor, opponent)

			if(text)
				text = row_proper + text
				draw_all(text)
			end


			break
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
			char = Human.new('dummy', 'pc', 'artificial')
			char.current_side = 1
			@side1.push(char)
		end

		rename_humans(@side1)

		while(@side2.length < 5)
			char = Orc.new('dummy', 'pc', 'artificial')
			char.current_side = 2
			@side2.push(char)
		end
		
		rename_orcs(@side2)

		@side1.each  { |p| @combatants.push(p) }
		@side2.each  { |p| @combatants.push(p) }

	end
end


