def choose_game(games, player)


	def _handle_game_screen_cmd(games, player)

		bottom_text = nil

		cmd = player.prompt('cmd')

		case cmd[0]
			when 'm'
				player.tell('create_character')
				throw :done
			when 'n'
				clear_screen(player.method(:write))

				games.get_all.each_with_index { |game,i|
					player.write "#{i+1}) #{game.name}"
				}
				
				game_idx = player.read
				game_idx = game_idx.to_i

				if(game_idx>0 && game_idx<=games.length)

					chosen_game = games.get_all[game_idx-1]

					if(chosen_game.is_a? Game)
						game = Array.new
						game.push('play_game')
						game.push(chosen_game)
						player.tell(game)
						throw :done
					end
				else
					bottom_text = "Bad index: #{game_idx}"
				end
				
		end

		return 'game', bottom_text
	end

	def _draw_game_screen(write, bottom_text)

		_print_header(write)
	
		write COLOUR_YELLOW_BLINK + ' J' + COLOUR_RESET + ' = Join game'
		write COLOUR_RED_BLINK    + " N" + COLOUR_RESET + ' = New game'
		write COLOUR_BLUE_BLINK   + ' M' + COLOUR_RESET + ' = back to main Menu'

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



