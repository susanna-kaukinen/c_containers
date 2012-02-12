
class Attack < Action

	attr_accessor :did_attack
	attr_accessor :mix_damage
	attr_accessor :mix_damage
	attr_accessor :attackees
	attr_accessor :fury

	def initialize(attacker, enemies)
		super(attacker, attacker.brains)

		@attacker   = attacker
		@manner     = @attacker.personality

		@did_attack = false

		@mix_damage = Array.new
		@mix_damage = Array.new
		@enemies    = Array.new
		@attackees  = Array.new

		@fury       = false
		@fumble     = false
	end

	def resolve

		can_attack, why_cant = @attacker.can_attack_now()

		if(not can_attack)
			text = _explain_why_not(@attacker, 'attack', why_cant)
			mix_attack = Array.new
			mix_attack << text
			return
		end

		do_attack

		if(@fury)
			new_action = Attack.new(actor, enemies)		
			new_action.actor_type = 'artificial'
		end

		if(@fumble)
			enemies = Array.new
			enemies.push(actor)
			new_action = Attack.new(actor, enemies)		
			new_action.actor_type = 'artificial'
		end

		return new_action
		
	end

	def do_attack()

		p "do_attack: #{@attacker.name} =/=> #{@targets}"

		opponent = @targets.shift # one for now

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
			@mix_attack << "<<<#{@attacker} fumbled>>>" + EOL
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

		@fury, @mix_damage = @attacker.active_weapon.deal_damage(@attacker, opponent, result)

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

end

