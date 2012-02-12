
class Critical
	attr_accessor :type, :level
end

class Weapon
	attr_accessor :name, :fumble, :criticalType1, :criticalType2

	def to_s
		@name + ", fumble=" + @fumble.to_s()	
	end

	def initialize(name)
		@name   = name
		@fumble = 1 + rand(8)
	end

	def damage_table(result)

		if(result<80)
			return 0, nil
		end

		hp = 0
		crit = Critical.new()

		if(rand(2)==1)
			crit.type = "slash"
		else
			crit.type = "krush"
		end

		#print COLOUR_YELLOW + crit.type + COLOUR_RESET + "\n"

		case result
			when -9999 .. 100
				crit = nil
			when 100 .. 115
				crit.level = "A"
			when 116 .. 130
				crit.level = "B"
			when 131 .. 140
				crit.level = "C"
			when 141 .. 150
				crit.level = "D"
			when 151 .. 9999
				crit.level = "E"
		end

		hp = (result-80) / 2

		return hp, crit

	end

	def resolve_critical(attacker, critical, defender)

		_, rolls, _, dice_arr = roll_to_s(roll_die('critical'), false, false, nil)
		_roll = rolls[0]

		mega_bonus = 0
		if(_roll==66)
			mega_bonus = 33
		end

		crit_bonus = 0
		case critical.level
			when "B"
				crit_bonus += 5
			when "C"
				crit_bonus += 10
			when "D"
				crit_bonus += 15
			when "E"
				crit_bonus += 20
		end
	
		result = _roll + crit_bonus + mega_bonus

		wound = Wound.new()

		target_bonus = 0
=begin
		# wounds should have severity, perhaps 1 to 3
		# 1 = bruised/cut, 2 = crushed/sliced, 3 = shattered/severed 4 = lethal direct
		# these need to be considered in combination w/wound targets


so eg

class knee

	@bruisable     = true
	@cuttable      = true
	@crushable     = true
	@slicable      = true
	@shatterable   = true
	@severable     = true # "leg severed from knee down"
	@lethal_direct = false
end

class head

	@bruisable     = true # "face bruised"
	@cuttable      = true # "face cut"
	@crushable     = true # "skull fracture"
	@slicable      = false 
	@shatterable   = true # "skull shattered" => lethal_direct
	@severable     = true # "head severed"
	@lethal_direct = true, shatterable, severable
end

 => something like that, por ejemplo

=end		
		case result
			when 0 ... 10
				return -1, 'Zip!'
			when 10 ... 20
				wound.damage = 1 + rand(10)	
			when 20 ... 40
				wound.damage = 1 + rand(10)	
				wound.stun   = 1
			when 40 ... 60
				wound.damage = 1 + rand(10) + 10
				wound.stun   = 2
				wound.uparry = 1
				target_bonus = 5
			when 60 ... 80
				wound.damage = 1 + rand(15) + 10
				wound.stun   = 3
				wound.uparry = 2
				target_bonus = 15
			when 80 ... 90
				wound.damage = 1 + rand(15) + 15	
				target_bonus = 25
			when 90 ... 95
				wound.damage = 1 + 30
				wound.prone = 3
				target_bonus = 35
			when 95 ... 100
				wound.damage = 1 + rand(30) + 30
				wound.unconscious = true
				target_bonus = 40
			when 100 ... 9999
				wound.dead   = true
				target_bonus = 60
		end
#wound.dead   = true # test fury
#wound.unconscious = true

		if(critical.type == 'slash')
			wound.bleeding = wound.stun
			wound.stun = 0

			wound.uparry /= 2
		end
		

		target_result = 1 + rand(100) + target_bonus
		case target_result
			when -9999 ... 7
				wound.target = 'secondary arm'
			when 7 ... 14
				wound.target = 'weapon arm'
			when 14 ... 21
				wound.target = 'left leg' # thigh, calf, foot, ankle, knee (is below)
			when 21 ... 28
				wound.target = 'right leg'
			when 28 ... 35 
				wound.target = 'stomach' # @see side below
			when 35 ... 42
				wound.target = 'side' # can be cut to organs, ribs can break
			when 42 ... 48
				wound.target = 'back'
			when 48 ... 55
				wound.target = 'neck' # compare: throat. neck breaks/throat is sliced
			when 55 ... 62
				wound.target = 'shoulder' # can break or shatter
			when 62 ... 70
				wound.target = 'elbow'   # can break or shatter
			when 70 ... 77
				wound.target = 'knee'	 # joints can be shattered or perhaps severed, these need to be object w/properties, perhaps - have
			when 77 ... 84                   # properties like severable and crushable and so forth
				wound.target = 'throat'  # can be crushed or slashed or punctured
			when 84 ... 91
				wound.target = 'skull'   # can be crushed, should be head if severed and head punctured
			when 91 ... 9999
				wound.target = 'groin'   # for slash wounds, can bleed profusely

		end

		text = wound.apply(defender, wound.target)

		return _roll, text, wound, dice_arr
	end
	# /resolve_critical

	def deal_damage(attacker, defender, result)

		text_dice_mix_arr = Array.new

		already_unco = false
		already_unco = true  if(defender.unconscious)

		already_dead = false
		already_dead = true  if(defender.dead)

		hp_damage, critical, wound = damage_table(result)

		
		defender_hp_pre_base_damage = defender.current_hp
		defender.current_hp       -= hp_damage

		if(hp_damage>0)
			text_dice_mix_arr << name + " deals " + COLOUR_RED + hp_damage.to_s() + COLOUR_RESET + " hit points of damage "
		else
			if(defender.dead || defender.unconscious)
				text_dice_mix_arr << attacker.name + "misses"
			else
				if(rand(2)==1)
					evade = "dodges"
				else
					evade = "blocks"
				end
				text_dice_mix_arr << defender.name + " " + evade + " the attack\n"
			end
		end

		if(critical)
			_roll, crit_text, wound, dice_arr = resolve_critical(attacker, critical, defender)
			#text2 = COLOUR_WHITE_BLINK + "\nCritical: " + critical.level + ' ' + critical.type + "es, roll=" + COLOUR_YELLOW + _roll.to_s + COLOUR_RESET
			text_dice_mix_arr << COLOUR_WHITE_BLINK + " ==> Critical: " + critical.level + ' ' + critical.type + COLOUR_RESET + EOL
			text_dice_mix_arr << dice_arr
			text_dice_mix_arr << EOL
			text_dice_mix_arr << crit_text 
			text_dice_mix_arr << EOL
		end

		resove_attack_effects_and_xp_bookkeep(attacker, defender, hp_damage, defender_hp_pre_base_damage, wound, already_dead, already_unco)

		if(defender.current_hp<0 and defender.dead == false)
			if(defender.unconscious==false)
				text_dice_mix_arr << COLOUR_YELLOW_BLINK + defender.name + " falls unconscious.\n" + COLOUR_RESET
			else
				text_dice_mix_arr << COLOUR_YELLOW_BLINK + defender.name + " is unconscious.\n" + COLOUR_RESET
			end
			defender.unconscious = true
		end

		if(defender.current_hp < -defender.hp or defender.dead == true)
			defender.dead = true
			text_dice_mix_arr << COLOUR_RED_BLINK + defender.name + " is DEAD!\n" + COLOUR_RESET
		end
		
		fury=false
		if(wound and wound.dead) # critical kill gives character a 2nd attack
			fury=true
			text_dice_mix_arr << COLOUR_YELLOW_BLINK + COLOUR_REVERSE + cursor_to(12, 61) + '<<<FURY>>>' + COLOUR_RESET
		end

		return fury, text_dice_mix_arr

	end #/deal_damage

end

def resove_attack_effects_and_xp_bookkeep(attacker, defender, hp_damage, defender_hp_pre_base_damage, wound, already_dead, already_unco)

	#p attacker.xp

	# first figure out if the defender is already out cold


	if(already_unco or already_dead)
		# no xp to either
	else
		attacker.xp.add_damage_inflicted(hp_damage)
		defender.xp.add_damage_sustained(hp_damage)

	end

	defender_before_wound = defender.clone
	defender_before_wound.current_hp = defender_hp_pre_base_damage
	
	defender.apply_wound_effects_after_attack # apply damage NOW

	if(already_unco or already_dead)
		# no xp to either
	else
		if(wound) 

			if(wound.damage>0)
				attacker.xp.add_damage_inflicted(wound.damage)
				defender.xp.add_damage_sustained(wound.damage)
			end

			attacker.xp.add_wound_inflicted(wound)
			defender.xp.add_wound_sustained(wound)

			attacker.xp.add_critical_ko_inflicted(defender_before_wound)            if(wound.unconscious)
			defender.xp.add_critical_ko_sustained(defender_before_wound.strength)   if(wound.unconscious)

			attacker.xp.add_critical_kill(defender_before_wound)                    if(wound.dead)
			defender.xp.add_critical_kill_sustained(defender_before_wound.strength) if(wound.dead)
		end
	end

	if(already_unco or already_dead)
		# no xp
	else
		if(defender.unconscious and not wound.unconscious)
			attacker.xp.add_ko_inflicted(defender_before_wound)
			defender.xp.add_ko_sustained(defender_before_wound.strength)
		end

		if(defender.dead and not wound.dead)
			attacker.xp.add_kill(defender_before_wound)
			defender.xp.add_kill_sustained(defender_before_wound.strength)
		end
	end

	#p attacker.xp
	#p 'U>>>' + already_unco.to_s
	#p 'D>>>' + already_dead.to_s

end


