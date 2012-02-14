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

	str += " " + why_cant + COLOUR_RESET + EOL

	return str

end

class Attack < Action

	attr_accessor :attacker
	attr_accessor :did_attack
	attr_accessor :mix_damage
	attr_accessor :mix_damage
	attr_accessor :attackees
	attr_accessor :fury

	def initialize(attacker)
		super(attacker, attacker.brains)

		@attacker   = attacker
		@manner     = @attacker.personality

		@did_attack = false

		@mix_damage = Array.new
		@mix_damage = Array.new
		@attackees  = Array.new

		@damage_type = ''

		@fury           = false
		@fumble         = false
		@counter_strike = false
		@counter_strike = nil
	end

	def resolve

		can_attack, why_cant = @attacker.can_attack_now()

		if(not can_attack)
			text = _explain_why_not(@attacker, 'attack', why_cant)
			@mix_attack = Array.new
			@mix_attack << text
			return Array.new
		end

		attack


		new_actions = Array.new()

		new_actions.push('fury')   if(@fury)
		new_actions.push('fumble') if(@fumble)

		if (@counter_strike)
		
			counter_strike = Array.new()
			counter_strike.push('counter_strike')
			counter_strike.push(@counter_striker)	
			new_actions.push(counter_strike)
		end

		p "return: #{new_actions}"

		return new_actions
		
	end

	def attack()

		print COLOUR_CYAN +  "attack: #{@attacker.name} =/=> #{@targets[0].name}..." + COLOUR_RESET + EOL

		opponent = @targets[0] # one for now

		@mix_attack = Array.new

		if(opponent==nil)
			@mix_attack << "No-one to attack!"
			return false, @mix_attack, nil, opponent, false
		end

		@did_attack = true

		@mix_attack << cursor_to(7,28)
		@mix_attack << '<<< ATTACK >>>'
		@mix_attack << EOL

		f = @attacker.active_weapon.fumble
		roll_result, rolls, fumbled, attack_dice_array = roll_to_s(roll_die('attack', f), true, true, f)

		@mix_attack << attack_dice_array

		if(fumbled==true) # @TODO
			@mix_attack << EOL + "<<<#{@attacker.name} fumbled>>>" + EOL
			@fumble = true
			return
		end 

		block = opponent.blocks?(@attacker.name)

		if(block>0)
			@mix_attack << opponent.name + COLOUR_CYAN + ' blocks' + COLOUR_RESET
			@mix_attack << ' against ' + @attacker.name + " w/#{block}" +
			EOL
		end

		result = @attacker.current_ob - opponent.current_db - block + roll_result

		@mix_attack << " => result:" + result.to_s() +
		EOL

		@fury, @damage_type, @mix_damage = @attacker.active_weapon.deal_damage(@attacker, opponent, result)

		if(@damage_type=='none' and block>0) # FIXME
			@counter_striker = opponent
			@counter_strike  = true
		end

	end



	# if we have a multi-attack w/many targets, the @damage_type will break, but if we have repetitive
	# attacks there is no problem
	def draw(draw)
		draw.draw_attack(@active_xpc, @did_attack, @targets, @damage_type, @mix_attack, @mix_damage )
	end

	def choose_target_menu(draw, targets)

		text='' #TODO

		loop {
			draw.draw_active_player(@attacker, 'Choose target:')


			prompt = "\n\n"
			prompt += ' (a)=Auto target' + "\n "

			targets.each_with_index { |target,i|
				prompt += "(#{i})" + target.name + " "
				if(i%2==1)
					prompt += EOL
				end
			}
			
			draw.draw_active_player(@attacker, prompt)

			cmd = draw.ask_active_player(@attacker, 'attack_option')

			if(cmd == 'a')
				draw._cls(@attacker)
				targets = ai_choose_target(targets, @attacker.personality)
			else
				draw._cls(@attacker)

				chosen_target = nil

				targets.each_with_index { |target,i|
					if(cmd == i.to_s)
						chosen_target = target
						break
					end
				}

				return chosen_target
			end
		
			draw._cls(@attacker)

		}
	end


end

