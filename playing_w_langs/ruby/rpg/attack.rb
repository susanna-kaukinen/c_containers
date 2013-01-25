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
	attr_accessor :mix_damage # uglies, contain both strings and arrays which will be pumped empty
	attr_accessor :mix_damage #  while drawing. These contain the dice results arrays and then just text.
	attr_accessor :fury
	attr_accessor :reverse

	def initialize(attacker)
		super(attacker, attacker.brains)

		@attacker   = attacker
		@manner     = @attacker.personality

		@did_attack = false

		@mix_damage = Array.new
		@mix_damage = Array.new

		@damage_type = ''

		@fury           = false
		@fumble         = false
		@counter_strike = false
		@counter_strike = nil
		@reverse        = 0
	end

	def resolve

		can_attack, why_cant = @attacker.can_attack_now()

		if(not can_attack)
			text = _explain_why_not(@attacker, 'attack', why_cant)
			@mix_attack = Array.new
			@mix_attack << text
			return Array.new
		end


		attack # <===


		new_actions = Array.new()

		if(@fury)
			new_actions.push('fury')
			# fury gets <<<FURY>>> text from weapon.rb (2012-02)
		elsif(@fumble)
			new_actions.push('fumble')

			@mix_attack << CURSOR_SAVE
			@mix_attack << COLOUR_YELLOW_BLINK + COLOUR_REVERSE + cursor_to(12, 57) + '<<<FUMBLE>>>' + COLOUR_RESET
			@mix_attack << CURSOR_RESTORE

		elsif (@counter_strike)
		
			counter_strike = Array.new()
			counter_strike.push('counter_strike')
			counter_strike.push(@counter_striker)	
			new_actions.push(counter_strike)

			@mix_attack << CURSOR_SAVE

			case @reverse
				when 0
					@mix_attack << EOL + COLOUR_YELLOW_BLINK + cursor_to(12, 58) + '<<<COUNTER>>>' + COLOUR_RESET
				when 1
					@mix_attack << EOL + COLOUR_YELLOW_BLINK+ COLOUR_REVERSE + cursor_to(12, 58) + '<<<REVERSE>>>' + COLOUR_RESET
				else
					#nop
			end
			@mix_attack << CURSOR_RESTORE
		end

		p "return: #{new_actions}"

		return new_actions
		
	end

	def attack()

		if(@targets and @targets.length>0)
			print COLOUR_CYAN +  "attack: #{@attacker.name} =/=> #{@targets[0].name}..." + COLOUR_RESET + EOL
		else
			print COLOUR_CYAN +  "attack: #{@attacker.name} =/=> <<<NO TARGETS>>>" + COLOUR_RESET + EOL
		end

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
			@mix_attack << EOL + opponent.name + COLOUR_CYAN + ' blocks' + COLOUR_RESET + ' againts ' + @attacker.name + " w/" + COLOUR_CYAN + "#{block}" + COLOUR_RESET + EOL
		end

		result = @attacker.current_ob - opponent.current_db - block + roll_result

		@mix_attack << " => result:" + result.to_s() + EOL

		@fury, @damage_type, @mix_damage = @attacker.active_weapon.deal_damage(@attacker, opponent, result)

		if(@damage_type=='none' and result<0)
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
				return targets
			else
				draw._cls(@attacker)

				chosen_target = nil

				targets.each_with_index { |target,i|
					if(cmd == i.to_s)
						chosen_target = target

						_targets = Array.new
						_targets.push(chosen_target)

						return _targets
					end
				}

			end
		
			draw._cls(@attacker)

		}
	end


end

