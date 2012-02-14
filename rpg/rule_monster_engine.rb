
module RuleMonsterEngine

	def fight
		init_fight
		play_rounds
		restructor
	end

	def get_sides
		@sides.clone
	end

	def prompt_player_action(draw, character, opponents, friends, _cls)

		p "prompt_player_action: #{character.name}, #{opponents[0].name}... #{friends[0].name} ..."

		draw_all_but_active_player(character, "#{character.name} ponders action, please wait...")

		can_attack, why_cant_attack = character.can_attack_now()
		can_block,  why_cant_block  = character.can_block_now()
	
		draw_active_player(character, CURSOR_SAVE)	

		loop {

			if(can_attack == false and can_block == false)
				text = _explain_why_not(character, 'do anything', 'is incapacitated')
				text += EOL
				draw_active_player(character, text)
				return NoAction.new(character, text)
			end

			if(character.current_ob<10)
				text = _explain_why_not(character, 'take more actions', 'all ob used up!')
				text += EOL
				draw_active_player(character, text)
				return NoAction.new(character, text)
			end	

			draw_active_player(character, row_proper())
			draw_active_player(character, 'Choose action:')

			prompt = ' '
			prompt += "(a/A)=attack (#{character.current_ob}) " if(can_attack)
			prompt += '(b)=block  ' if(can_block)
			prompt += '(h)=heal   ' if(character.can_heal?)
			
			draw_active_player(character, prompt)

			print "cMD"
			cmd = ask_active_player(character, 'sub_round_action')

			case cmd
				when 'a'
					_cls.call(character)

					attack = Attack.new(character)
					attack.choose_target(draw, attack, opponents, 'manual')
					return attack
				when 'A'
					_cls.call(character)
					attack = Attack.new(character)
					attack.choose_target(draw, attack, opponents, 'auto')
					return attack

				when 'b'
					_cls.call(character)
					block = Block.new(character)
					block.choose_target(draw, block, opponents, 'manual')
					return block
				when 'h'
					_cls.call(character)
					heal = Heal.new(character)
					heal.character(friends, heal, 'manual')
					return heal
			end
		
			_cls.call(character)
		}
	end

	def play_sub_round(round, sub_round, combatants, friends, enemies, actor )

		if(not opponents_left(enemies))
			throw :game_over
		end
			
		draw = Draw.new(round, sub_round, combatants, @side1, @side2)
		draw.set_writers(method(:draw_all), 
			method(:draw_all_with_dice_roll_delay),
			method(:draw_active_player),
			method(:ask_active_player),
			method(:send_active_player))

		draw.first_draw(actor, enemies)

		actor.recover_from_wounds
		draw_all(actor.do_bleed)
		actor.current_ob = actor.ob
		actor.current_blocks = Hash.new

		actions = Array.new

		if(actor.human?) 
			action = prompt_player_action(draw, actor, enemies, friends, draw.method(:_cls))
			actions.push(action)
			draw.draw_all(SCREEN_CLEAR)
		else

			if((rand(4)>=0))
				action = Block.new(actor)
				action.choose_target(draw, action, enemies, 'smart')
				actions.push(action)
			else
				action = Attack.new(actor)
				action.choose_target(draw, action, enemies, actor.personality)
				actions.push(action)
			end
		end

		i=0
		counter_strikeS=0
		while(actions.length > 0)

			throw :game_over if(not opponents_left(enemies))

			action = actions.shift

			if(i>0)
				prompt_anyone
				draw.first_draw(actor, enemies)
			end

			p "action.class=#{action.class}"
			new_actions = action.resolve()

			while(new_actions.length>0)

				new_action=new_actions.shift

				if(new_action.is_a? Array)
					new_action_actor = new_action[1]
					new_action       = new_action[0]
				end

				p "new_action=#{new_action}"

				case new_action
					when 'fury'
						p "FURY ENABLED"
						new_action = Attack.new(action.attacker)
						new_action.actor_type = 'artificial'
						new_action.choose_target(draw, new_action, enemies, 'smart')
	
					when 'counter_strike'

						break if(counter_strikeS>=2)

						new_action = Attack.new(new_action_actor)
						new_action.actor_type = 'artificial'

						if(counter_strikeS==0)
							new_action.reverse = 1
						else
							new_action.reverse = 2
						end

						_original_attacker = Array.new
						_original_attacker.push(action.attacker)
						new_action.choose_target(draw, new_action, _original_attacker, 'smart')
						counter_strikeS += 1

					when 'fumble'
						p "FUMBLE ENABLED"
						new_action = Attack.new(action.attacker)

						_self = Array.new
						_self.push(action.attacker)

						new_action.actor_type = 'artificial'
						new_action.choose_target(draw, new_action, _self, 'smart')
				end

				if(new_action != 'no_new_action')
					actions.push(new_action)
				end

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
	
				print COLOUR_RED + '<<<SUB ROUND ERR HANDLER>>>'

				p "#{e}"
				p e.message  
				p e.backtrace.inspect

				p COLOUR_RESET
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
