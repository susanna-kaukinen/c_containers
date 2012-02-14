
# normal proper row, for attack etc. text
def row_proper()

	h = (@side1.length > @side2.length) ? @side1.length : @side2.length
	
	row = "\033[" + (3+h).to_s + ';H'
end

class Draw

	def initialize (round, sub_round, combatants, side1, side2)
		
		@round = round
		@sub_round = sub_round
		@combatants = combatants
		@side1 = side1
		@side2 = side2
	end

	def set_writers(draw_all, draw_all_with_dice_roll_delay, draw_active_player, ask_active_player, send_active_player)
		@draw_all                      = draw_all
		@draw_all_with_dice_roll_delay = draw_all_with_dice_roll_delay
		@draw_active_player            = draw_active_player
		@ask_active_player             = ask_active_player
		@send_active_player	       = send_active_player
	end

	def draw_active_player(actor, *vargs)
		@draw_active_player.call(actor, *vargs)
	end

	def ask_active_player(blocker, *vargs)
		@ask_active_player.call(blocker, *vargs)
	end

	def send_active_player(actor, cmd, *vargs)
		@ask_active_player.call(actor, cmd, *vargs)
	end

	def _colour_names(draw_number, xpc, active_xpc, opponent, fury, first_draw, damage_type)
	
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

			case draw_number
				when 1
					name = name
				when 2
					name = COLOUR_CYAN + COLOUR_REVERSE + name + COLOUR_RESET
				when 3
					if(damage_type=='none')
						name = COLOUR_CYAN + COLOUR_REVERSE + name + COLOUR_RESET
					elsif(damage_type=='hp')
						name = COLOUR_RED + name + COLOUR_RESET
					elsif(damage_type=='critical')
						name = COLOUR_RED + COLOUR_REVERSE + name + COLOUR_RESET
					else
						name = name
					end
			end
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

	def _hp_and_wounds_to_s(draw_number, active_xpc, xpc, opponent, damage_type)

		str = ''

		if(draw_number==2 and xpc==opponent)
			str += COLOUR_CYAN + COLOUR_REVERSE
			str += ' ? / ? '
			str += COLOUR_RESET
			str += '          '
		else 

			if(draw_number==3 and xpc==opponent)
				if(damage_type=='none')
					str += COLOUR_CYAN + COLOUR_REVERSE
				elsif(damage_type=='hp')
					str += COLOUR_RED
				elsif(damage_type=='critical')
					str += COLOUR_RED + COLOUR_REVERSE
				else
					# nop
				end
			end

			curr_hp = xpc.current_hp.to_s
			while(curr_hp.length<3)
				curr_hp = ' ' + curr_hp
			end

			if(xpc==active_xpc and xpc.bleeding>0)
				str += COLOUR_RED + curr_hp.to_s + COLOUR_RESET
			else
				str += curr_hp.to_s
			end

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

			if(xpc.bleeding>0)
				if(xpc==active_xpc)
					str += COLOUR_RED + 'b' + xpc.bleeding.to_s + COLOUR_RESET
				else
					str += 'b' + xpc.bleeding.to_s
				end
			end
		
			if(draw_number==3 and xpc==opponent)
				str += COLOUR_RESET
			end
		end

		return str

	end


	def draw_subround(draw_number, active_xpc, targets, damage_type)

		rnd        = @round
		opponent   = targets[0] # TODO
		fury       = false #TODO
		first_draw = false #TODO


		top_bar = "==================---/--- Round: #" + rnd.to_s + " (" + @sub_round.to_s + "/" + @combatants.length.to_s + ") ==========================#{draw_number}\n"

		str=''
	
		if(draw_number==1)	
			str += SCREEN_CLEAR
		end

		str += CURSOR_UP_LEFT
		str += top_bar
		
		print top_bar

		idx_longest_name = @combatants.each_with_index.inject(0) { | max_i, (combatant, idx) | combatant.name.length > @combatants[max_i].name.length ? idx : max_i }

		names_width = @combatants[idx_longest_name].name.length


		@side1.each_with_index { | xpc,i |
			row_col = "\033[" + (2+i).to_s + ';' + '0' + 'H'
			str += row_col

			str += _colour_names(draw_number, xpc, active_xpc, opponent, fury, first_draw, damage_type)

			set_pos_y = "\033[" + '20' + 'G'
			str += set_pos_y

			str += _hp_and_wounds_to_s(draw_number, active_xpc, xpc, opponent, damage_type)

		}

		@side2.each_with_index { | xpc,i |

			row_col = "\033[" + (2+i).to_s + ';' + '36' + 'H'
			str += row_col

			str += _colour_names(draw_number, xpc, active_xpc, opponent, fury, first_draw, damage_type)
			
			set_pos_y = "\033[" + (36+20).to_s + 'G'
			str += set_pos_y

			str += _hp_and_wounds_to_s(draw_number, active_xpc, xpc, opponent, damage_type)

		}


		return str

	end

	def draw_all(*vargs)
		@draw_all.call(*vargs)
	end	

	def first_draw(actor, targets)
		str = draw_subround(1, actor, targets, 'none')
		draw_all(str)
	end

	def draw_attack(attacker, did_attack, targets, damage_type, mix_attack, mix_damage)
	
		def _draw_strs_and_dice(attacker, mix_str_arr)
			i=0
			while i < mix_str_arr.length

				if(mix_str_arr[i].is_a? Array)
					roll_strs = mix_str_arr[i]

					roll_strs.each_with_index {|str,i|
						#p str
						if(i<roll_strs.length-1)
							@draw_all_with_dice_roll_delay.call(str)
						end
					}
				else
					@draw_all.call(mix_str_arr[i])
				end

				i += 1
			end
		end

		p "draw_attack: #{attacker} #{targets} #{mix_attack} #{mix_damage}"
		
		str = draw_subround(2, attacker, targets, damage_type)
		draw_all(str)

		if(not did_attack)
			draw_all(row_proper)
		end

		draw_all(row_proper)

		_draw_strs_and_dice(attacker, mix_attack)

		if(mix_damage and not mix_damage == false) # latter is hack, find out where it comes from
			_draw_strs_and_dice(attacker, mix_damage)
		end

		str = draw_subround(3, attacker, targets, damage_type)
		draw_all(str)

	end

	def draw_block(blocker, targets)
		str = draw_subround(2, blocker, targets, 'none')
		draw_all(str)

		print COLOUR_CYAN + "draw_block: " + COLOUR_RESET

		str = ''
		targets.each_with_index { |target,i| 
			str += target.name
			if(i < targets.length-1)
				str += ', '
			end
		}

		draw_all row_proper + "#{blocker.name} blocks against #{str}"
	end

	def _cls(character)
		@draw_active_player.call(character, CURSOR_RESTORE)
		@send_active_player.call(character, 'cursor_clear_rows', 10)
		@draw_active_player.call(character, CURSOR_RESTORE)
	end

end

