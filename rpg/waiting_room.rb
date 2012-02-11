def waiting_room(game, player)

	def _waiting_room(game, player, write, bottom_text)


		_print_header(write)

		write COLOUR_REVERSE + "Game: #{game.name}" + COLOUR_RESET + EOR
		
		write "Players waiting: #{game.amt_players}" + EOR

		players = game.players

		players.each_with_index { |player,i|

			stats = " #{player.character.name} " +
		 		"(#{player.character.current_hp}" +
				"/#{player.character.current_db}" +
				"/#{player.character.current_ob})"


			if(i>=2) 
				write "#{stats}..." + EOR
				break
			else
				write "#{stats}" + EOR
			end
			
		}
		
	
		write COLOUR_YELLOW_BLINK + ' F' + COLOUR_RESET + ' = start Fight'    + EOR
		write COLOUR_GREEN_BLINK  + ' G' + COLOUR_RESET + ' = re-choose Game' + EOR

		if(bottom_text!=nil)
			# nop			
		elsif(character != nil)
			bottom_text = ""
		else
			bottom_text = ""
		end

		write_bottom_text(write, bottom_text)
		bottom_text = nil

		cmd = player.prompt('cmd')

		case cmd[0]
			when 'f'
				game.invite_all
				throw(:done)
			when 'g'
				game.leave(player)
				send_msg(player, 'choose_game')
				throw(:done)
		end

		return 'game', bottom_text
	end

	# |choose_game

	bottom_text = 'welcome to the waiting room'

	while true
		screen, bottom_text = _waiting_room(game, player, player.method(:write), bottom_text)
	end

end



