# <def_create_character>
def create_character(player)

	def _exit(player)

		_player = player.remove
		_player = nil

		Thread.current.exit
	end

	def _print_header(write)

		clear_screen (write)

		write "#{COLOUR_RED}Rule Monster#{COLOUR_RESET} v2.0, early beta.              It\'s still 1984.\n\n"
	end

	def write_bottom_text(write, *vargs)

		if(vargs[0] == nil) then return end

		write CURSOR_SAVE + cursor_to(11,1)

		clear = ''
		for i in 0..71 do clear += ' ' end
		write clear

		write cursor_to(11,1)

		vargs[0] = "\t\t\t" + vargs[0]

		write vargs

		write CURSOR_RESTORE
	end
	
	def no_character_txt
		return "?no character"
	end

	def _draw_main_screen(character, write, bottom_text)

		_print_header(write)

		write COLOUR_YELLOW_BLINK    + ' N ' + COLOUR_RESET + ' = New character  '   +
			COLOUR_BLUE_BLINK    + ' L ' + COLOUR_RESET + ' = Load character '   +
			COLOUR_GREEN_BLINK   + ' H ' + COLOUR_RESET + ' = Heal character '

		write COLOUR_WHITE_BLINK     + ' S ' + COLOUR_RESET + ' = Save character '   +
			COLOUR_CYAN_BLINK    + ' T ' + COLOUR_RESET + ' = Toggle screen  '   +
			COLOUR_YELLOW_BLINK  + ' C ' + COLOUR_RESET + ' = Character '

		write COLOUR_RED_BLINK       + " Q " + COLOUR_RESET + ' = Quit           '   + 
			COLOUR_GREEN_BLINK   + ' P ' + COLOUR_RESET + ' = Play (start)   '   +
			COLOUR_MAGENTA_BLINK + ' X ' + COLOUR_RESET + ' = view eXperience'
		

		if(bottom_text!=nil)
			# nop			
		elsif(character != nil)
			bottom_text = "player: #{character.name}"
		else
			bottom_text = no_character_txt
		end

		write_bottom_text(write, bottom_text)
	end

	def _character(player, write, bottom_text)

		def __draw_character_screen(player, write, bottom_text, what)

		_print_header(write)

		write COLOUR_YELLOW_BLINK    + ' RR' + COLOUR_RESET + ' = Reroll Stats   ' +
			COLOUR_BLUE_BLINK    + ' M ' + COLOUR_RESET  + ' = Main menu      ' +
			COLOUR_GREEN_BLINK   + ' L ' + COLOUR_RESET  + ' = Level character'
#TODO : rotate stats w/one key, e.g. 's', kind of a ring buffer st
		write COLOUR_WHITE_BLINK     + ' S ' + COLOUR_RESET + ' = view Stats     ' +
			COLOUR_CYAN_BLINK    + ' W ' + COLOUR_RESET + ' = view Wounds    ' +
			COLOUR_YELLOW_BLINK  + ' X ' + COLOUR_RESET + ' = view XP        '
			
		write EOL

		player.write player.character.to_s(what)

		if(bottom_text!=nil)
			# nop			
		elsif(character != nil)
			bottom_text = "player: #{character.name}"
		else
			bottom_text = no_character_txt
		end

		write_bottom_text(write, bottom_text)

		end

		#| _character

		what = 'stats'
		bottom_text = 'name:' + player.character.name

		loop {

			__draw_character_screen(player, write, bottom_text, what)
			
			bottom_text = nil

			cmd = player.prompt('cmd')

			case cmd
				when 'RR'
					what = 'stats'
					player.character = Character.new(character.name, 'pc', 'biological')
					player.character.current_player_id = player.id
					bottom_text = "#{player.character.name} reborn!"
				when 'l'
					if(player.character.can_level?)
						_level(player, write, bottom_text)
					else
						bottom_text = "?need more XP"
					end
				when 's'
					what = 'stats'
					bottom_text = 'name:' + player.character.name
				when 'w'
					what = 'wounds'
					bottom_text = 'name:' + player.character.name
				when 'x'
					what = 'xp'
					bottom_text = 'name:' + player.character.name
				when 'm'
					return
			end

			clear_screen(player.method(:write))
		}

	end

	def _handle_main_screen_cmd(player, write) 	

		bottom_text = nil

		cmd = player.prompt('cmd')

			case cmd[0]
				when 'n'
					name = player.prompt('name')
					if(name.length<2 or name.length>14)
						bottom_text = "bad name"
					else
						player.character = Character.new(name, 'pc', 'biological')
						player.character.current_player_id = player.id
						bottom_text = "#{player.character.name}!"
					end
									
				when 'q'
					send_question(player, nil, 'exit')
					throw (:done)
				when 'l'
					name = player.prompt('name')
					new_character = Character::load(name)

					if(new_character == nil)
						bottom_text = '?load error'
					else
						player.character = new_character
						bottom_text = "#{player.character.name} loaded."
					end

				when 's'
					if(player.character and player.character.save)
						bottom_text = "#{player.character.name} saved."
					else
						bottom_text = '?save error'
					end
					
				when 'p'
					if(player.character == nil)
						bottom_text = '?no character'
					else
						send_msg(player, 'choose_game')
						throw(:done)
					end
				when 'c'
					if(character)
						_character(player, write, bottom_text)
					else
						bottom_text = no_character_txt
					end

				when 'x'
					clear_screen(player.method(:write))
					if(player.character)
						player.write player.character.xp_s
						player.read
					else
						bottom_text = no_character_txt
					end
				when 'h'
					if(player.character)
						player.character.heal_self_fully(true)
						bottom_text = "#{player.character.name} healed."
					end
			end

			return 'main', bottom_text
	end

	def _main_screen(player, write, bottom_text)
		_draw_main_screen(player.character, write, bottom_text)
		return  _handle_main_screen_cmd(player, write)
	end

	# <|def_create_character>

	while true
		screen, bottom_text = _main_screen(player, player.method(:write), bottom_text)
	end
end

#</def_create_character>


