
module RuleMonsterEngine

	def fight
		init_fight
		play_rounds
		restructor
	end


	def get_sides
		@sides.clone
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

	def prompt_player_action(character, opponents, friends)

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

					attack = Attack.new(character, opponents)
					attack.choose_target(opponents, 'manual')
					return 

				when 'b'
					_cls(character)
					_block(character, opponents)
				when 'h'
					_cls(character)
					did_heal, text = _heal(character, friends)
					if(did_heal)
						return did_attack, text, false
					end
			end
		
			_cls(character)
		}
	end



	def _cls(character)
		draw_active_player(character, CURSOR_RESTORE)
		send_active_player(character, 'cursor_clear_rows', 10)
		draw_active_player(character, CURSOR_RESTORE)
	end


	def _sub_round_init(character)
		draw_all(character.do_bleed)
		character.recover_from_wounds
		character.current_ob = character.ob
		character.current_blocks = Hash.new
	end

	def play_sub_round(round, sub_round, combatants, friends, enemies, actor )

		if(not opponents_left(enemies))
			throw :game_over
		end

		_sub_round_init(actor)

		actions = Array.new

		if(actor.human?) 
			action = prompt_player_action(actor, enemies, friends)
			actions.push(action)
		else
			action = Attack.new(actor, enemies)
			action.choose_target(enemies, actor.personality)
			actions.push(action)
		end

		while(actions.length>0)

			new_action = action.resolve()

			if(new_action)
				actions.push(action)
			end

			draw = Draw.new(round, sub_round, combatants, @side1, @side2)
			draw.set_writers(method(:draw_all))

			action.draw(draw)
		end

	end
	#/play_sub_round


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

		mem_dump

		sub_round=1

		@combatants.each { |actor|

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

				play_sub_round(round, sub_round, @combatants, friends, enemies, actor )

			rescue Exception => e
	
				print COLOUR_RED + '<<<SUB ROUND ERR HANDLER>>>' + COLOUR_RESET

				p "#{e}"
				p e.message  
				p e.backtrace.inspect

			end

			prompt_anyone

			sub_round += 1

			if(not @players.left?)
				p "All players have left the game!\n"
				throw :game_over
			end

			if(not combatants_left(@side1) or not combatants_left(@side2))
				throw :game_over
			end
		}
	end
end
