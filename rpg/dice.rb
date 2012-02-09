 
def roll(type, *vargs)

	text = ''

	case type
		
		when 'attack'
			weapon      = vargs[0]
			attacker    = vargs[1]
			__do_attack = vargs[2]

		else # critical, general
			weapon   = nil
			attacker = nil
	end

	first_roll=0
	result=0
	while true
		first_roll = roll = 1 + rand(100)

		# <weapon_fumble>
		if(type=='attack' and weapon and result==0 and roll<weapon.fumble) then
			text +=  result.to_s() + " => FUMBLE\n"
			if(attacker != nil) then
				text +=  attacker.name + " deals himself a blow:\n"
				__do_attack.call(attacker, attacker, 'fumblingly')
			end
			fumble=true
		end
		# </weapon_fumble>

		result += roll

		if(type=='critical')

			colour = ''	
			case roll
				when 80 ... 90
					colour = COLOUR_YELLOW
				when 90 ... 100
					colour = COLOUR_RED
			end

			text +=  colour + "Crit roll=" + roll.to_s() + COLOUR_RESET + "\n"
		else

			if(roll>=96)
				text +=  COLOUR_GREEN + "OPEN-ENDED: " + roll.to_s() + "\n" + COLOUR_RESET
			else
				if(result!=roll)
					text +=  "Roll:" + roll.to_s + "/" + result.to_s + "(tot)"
				else
					text +=  "Roll:" + roll.to_s
				end
			end
		end


		if (type=='critical' or roll<96)
			return result, first_roll, fumble, text
		end


	end
end


