
class Draw

	def initialize (round, sub_round, combatants, side1, side2)
		
		@round = round
		@sub_round = sub_round
		@combatants = combatants
		@side1 = side1
		@side2 = side2
	end

	def set_writers(draw_all)
		@draw_all = draw_all

	end

	# normal proper row, for attack etc. text
	def row_proper()

		h = (@side1.length > @side2.length) ? @side1.length : @side2.length
		
		row = "\033[" + (3+h).to_s + ';H'
	end

	def _colour_names(xpc, active_xpc, opponent, fury, first_draw)
	
		name = xpc.name

		if(name == active_xpc.name)
			if(xpc.can_attack_now[0])
				if(fury and not first_draw)
					name = COLOUR_YELLOW + COLOUR_REVERSE + name + COLOUR_RESET
				else
					name = COLOUR_GREEN + COLOUR_REVERSE + name + COLOUR_RESET
				end
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


	def draw_subround(active_xpc, targets)

		rnd        = @round
		opponent   = targets.shift
		fury       = false #TODO
		first_draw = false #TODO

		top_bar = "==================---/--- Round: #" + rnd.to_s + " (" + @sub_round.to_s + "/" + @combatants.length.to_s + ") ===========================\n"
		
		str = SCREEN_CLEAR + CURSOR_UP_LEFT
		str += top_bar
		
		print top_bar

		idx_longest_name = @combatants.each_with_index.inject(0) { | max_i, (combatant, idx) | combatant.name.length > @combatants[max_i].name.length ? idx : max_i }

		names_width = @combatants[idx_longest_name].name.length

		@side1.each_with_index { | xpc,i |
			row_col = "\033[" + (2+i).to_s + ';' + '0' + 'H'
			str += row_col

			str += _colour_names(xpc, active_xpc, opponent, fury, first_draw)

			set_pos_y = "\033[" + '20' + 'G'
			str += set_pos_y

			str += _hp_and_wounds_to_s(xpc)
		}

		@side2.each_with_index { | xpc,i |

			row_col = "\033[" + (2+i).to_s + ';' + '36' + 'H'
			str += row_col

			str += _colour_names(xpc, active_xpc, opponent, fury, first_draw)
			
			set_pos_y = "\033[" + (36+20).to_s + 'G'
			str += set_pos_y

			str += _hp_and_wounds_to_s(xpc)
		}


		p 'LLL'
		p str
		return str

	end

	def draw_attack(attacker, did_attack, targets, mix_attack, mix_damage)
	
		def _draw_strs_and_dice(mix_str_arr)
			i=0
			while i < mix_str_arr.length

				if(mix_str_arr[i].is_a? Array)
					roll_strs = mix_str_arr[i]

					roll_strs.each_with_index {|str,i|
						p str
						@draw_all.call(str)
						if(i<roll_strs.length-1)
							sleep(ROLL_DELAY)
						end
					}
				else
					@draw_all.call(mix_str_arr[i])
				end

				i += 1
			end
		end

		p 'DRAW'
		p 'DRAW'
		p 'DRAW'
		p 'TTT'
		p attacker
		p targets
		p mix_attack
		p mix_damage
		p 'TTT'

		str = draw_subround(attacker, targets)
		p str
		@draw_all.call(str)

		if(not did_attack)
			@draw_all.call(row_proper + mix_attack)
		end

		@draw_all.call(row_proper)

		_draw_strs_and_dice(mix_attack)

		if(mix_damage and not mix_damage == false) # latter is hack, find out where it comes from
			_draw_strs_and_dice(mix_damage)
		end
	end
end

