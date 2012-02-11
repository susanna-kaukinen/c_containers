OPEN_END_START = 56
ROLL_DELAY     = 0.8

def d100(n)
	#TODO
end

def _1d100()	
  #return 1 + rand(100)
  return 1 + SecureRandom.random_number(100)
end

def count_result(rolls)

	result = 0
	
	rolls.each { |roll| result += roll }

	#p "count_result: rolls=#{rolls}, result=#{result}"

	return result
end

def roll_dice(n)
	#end
end

def roll_die(type, *vargs)

	has_open_end = true

	case type
		when 'attack'
			fumble       = vargs[0]
		when 'critical'
			has_open_end = false
		else
			weapon   = nil
	end

	i=0

	rolls = Array.new
	rolls[0] = _1d100

	fumbled = false
	if(type=='attack' and fumble and rolls[0]<fumble) then
		fumbled=true
	end

	result = 0

	while true
		if (has_open_end == false or rolls[i]<OPEN_END_START)
			return count_result(rolls), rolls, fumbled
		end

		i += 1
		rolls[i] = _1d100
	end
end

def colour_1d100_roll_s(roll, fumble)

	#p "colour_1d100_roll_s: roll=#{roll}, fumble=#{fumble}"

	case roll
		when -9999 .. fumble
			die_colour = COLOUR_RED
		when fumble .. 25
			die_colour = ''
		when 26 .. 75
			die_colour = COLOUR_WHITE
		when 76 .. OPEN_END_START
			die_colour = COLOUR_GREEN
		else
			die_colour = COLOUR_GREEN
	end

	die_colour + '<' + COLOUR_REVERSE + roll.to_s + COLOUR_RESET + die_colour + '>' + COLOUR_RESET
end 

def draw_roll(write, die_roll, has_open_end, has_fumble, fumble)

	
	result     = die_roll[0]
	rolls      = die_roll[1]
	fumbled    = die_roll[2]

	#p "roll_to_s: result=#{result}, rolls=#{rolls}, fumbled=#{fumbled}"
	#p "roll_to_s: has_open_end=#{has_open_end}, has_fumble=#{has_fumble}, fumble=#{fumble}"


	if(has_fumble==false)
		fumble = -1
	end

	str = 'Rolling... '
	if(has_open_end)
		roll_colour = COLOUR_MAGENTA
	else
		roll_colour = COLOUR_CYAN
	end
	write(roll_colour + str + COLOUR_RESET)

	sleep(ROLL_DELAY)

	str = ''

	if(rolls.length>1)
		
		rolls.each_with_index { |roll,i|

			str += colour_1d100_roll_s(roll, fumble)

			write str
			sleep(ROLL_DELAY)

			if(i > rolls.length)
				break
			end

			str = ' + '

		}


	else
		str = colour_1d100_roll_s(rolls[0], fumble)
		write str
		sleep(ROLL_DELAY)
	end

	#str = ' ===> ' + roll_colour + '<' + COLOUR_REVERSE + result.to_s + COLOUR_RESET +
	#	         roll_colour + '>' + COLOUR_RESET + EOR

	str = " ===> " + colour_1d100_roll_s(result, fumble)

	write str
end






