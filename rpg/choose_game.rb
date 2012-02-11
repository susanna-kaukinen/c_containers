
def choose_game(games, player)

	def _choose_game(games, player)
		clear_screen(player.method(:write))

		games.get_all.each_with_index { |game,i|
			player.write "#{i+1}) #{game.name}" + EOR
		}
		
		game_idx = player.read
		game_idx = game_idx.to_i

		if(game_idx>0 && game_idx<=games.length)

			chosen_game = games.get_all[game_idx-1]

			if(chosen_game.is_a? Game)
				return chosen_game
			end
		else
			bottom_text = "Bad game index: #{game_idx}"
			return nil
		end
	end
				
	def _choose_sides(game, player)		
		clear_screen(player.method(:write))

		sides = game.get_sides

		sides.each_with_index { |side,i|
			player.write "#{i+1}) #{side}" + EOR
		}
		
		side = player.read
		side = side.to_i
		side -= 1

		if(side>=0 && side<sides.length)

			chosen_side = game.get_sides[side]

			if(chosen_side.is_a? String)

				player.character.current_side = side + 1

				return true
			end
		else
			bottom_text = "Bad game index: #{side}"
			return false
		end
	end


	def _handle_game_screen_cmd(games, player)

		bottom_text = nil

		cmd = player.prompt('cmd')

		case cmd[0]
			when 'm'
				send_msg(player, 'create_character')
				throw :done
			when 'n'
				chosen_game = _choose_game(games, player)

				if(chosen_game != nil)
					if(_choose_sides(chosen_game, player))
						send_msg(player, 'join_game', chosen_game)
						throw :done
					end
				end

		end

		return 'game', bottom_text
	end

	def _draw_game_screen(write, bottom_text)

		_print_header(write)
	
		write COLOUR_YELLOW_BLINK + ' J' + COLOUR_RESET + ' = Join game'          + EOR
		write COLOUR_RED_BLINK    + " N" + COLOUR_RESET + ' = New game'           + EOR 
		write COLOUR_BLUE_BLINK   + ' M' + COLOUR_RESET + ' = back to main Menu'  + EOR

		if(bottom_text!=nil)
			# nop			
		elsif(character != nil)
			bottom_text = ""
		else
			bottom_text = ""
		end

		write_bottom_text(write, bottom_text)
	end

	def _game_screen(games, player, write, bottom_text)
		_draw_game_screen(player.method(:write), bottom_text)
		return _handle_game_screen_cmd(games, player)
	end

	
	# |choose_game

	while true
		screen, bottom_text = _game_screen(games, player, player.method(:write), bottom_text)
	end

end



