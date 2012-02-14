
module RuleMonsterEngine

	def fight
		init_fight
		play_rounds
		restructor
	end

	def get_sides
		@sides.clone
	end

	def prompt_player_action(character, opponents, friends)

		p "prompt_player_action: #{character.name}, #{opponents[0].name}... #{friends[0].name} ..."

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

			draw_active_player(row_proper())
			draw_active_player(character, 'Choose action:')

			prompt = ' '
			prompt += "(a)=attack (#{character.current_ob}) " if(can_attack)
			prompt += '(b)=block  ' if(can_block)
			prompt += '(h)=heal   ' if(character.can_heal?)
			
			draw_active_player(character, prompt)

			print "cMD"
			cmd = ask_active_player(character, 'sub_round_action')

			case cmd
				when 'a'
					_cls(character)

					attack = Attack.new(character)
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

	def play_sub_round(round, sub_round, combatants, friends, enemies, actor )

		if(not opponents_left(enemies))
			throw :game_over
		end
			
		draw = Draw.new(round, sub_round, combatants, @side1, @side2)
		draw.set_writers(method(:draw_all), method(:draw_all_with_dice_roll_delay))
		draw.first_draw(actor, enemies)

		actor.recover_from_wounds
		draw_all(actor.do_bleed)
		actor.current_ob = actor.ob
		actor.current_blocks = Hash.new

		actions = Array.new

		if(actor.human?) 
			action = prompt_player_action(actor, enemies, friends)
			actions.push(action)
		else
			action = Attack.new(actor)
			action.choose_target(enemies, actor.personality)
			actions.push(action)
		end

		i=0
		while(actions.length > 0)

			action = actions.shift

			if(i>0)
				prompt_anyone
				draw.first_draw(actor, enemies)
			end

			new_action = action.resolve()

			throw :game_over if(not opponents_left(enemies))

			case new_action
				when 'fury'
					p "FURY ENABLED"
					new_action = Attack.new(action.attacker)
					new_action.actor_type = 'artificial'
					new_action.choose_target(enemies, 'smart')

				when 'fumble'
					p "FUMBLE ENABLED"
					new_action = Attack.new(action.attacker)

					_self = Array.new
					_self.push(@attacker)

					new_action.actor_type = 'artificial'
					new_action.choose_target(_self, 'smart')
			end

			if(new_action != 'no_new_action')
				actions.push(new_action)
			end

			action.draw(draw)

			i+=1
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
