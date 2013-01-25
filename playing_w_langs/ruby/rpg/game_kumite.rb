class Kumite < Game

	def initialize(*args)
		@name = 'kumite'
		super(@name, *args)

		@sides = Array.new
		@sides.push('humans')
		@sides.push('kobolds')

		@kumiteist_id = 0
	end

	def restructor
		@games.del_game(@instance_id)
		game = Kumite.new(@games)
		@games.add_games(game)
	end

	def init_fight

		@players.all.each { |player|

			@side1.push(player.character)
			player.character.current_side = 1

			@kumiteist_id = player.id

			break # just 1 player
		}


		init_opponents(true)

	end

	def init_opponents(first)

		@combatants = Array.new
		@side2      = Array.new

		opponent = rand(6)	

		if(first)
			opponent=1
		end

		if(opponent==0)
			char = Troll.new('dummy', 'pc', 'artificial')
			char.current_side = 2
			@side2.push(char)
			rename_trolls(@side2)
		elsif(opponent ==1)
			char = Kobold.new('dummy', 'pc', 'artificial')
			char.current_side = 2
			@side2.push(char)
			rename_kobolds(@side2)
		elsif(opponent ==2)
			char = Orc.new('dummy', 'pc', 'artificial')
			char.current_side = 2
			@side2.push(char)
			rename_orcs(@side2)
		elsif(opponent ==3)
			char = Dwarf.new('dummy', 'pc', 'artificial')
			char.current_side = 2
			@side2.push(char)
			rename_dwarfs(@side2)
		elsif(opponent ==4)
			char = Elf.new('dummy', 'pc', 'artificial')
			char.current_side = 2
			@side2.push(char)
			rename_elfs(@side2)
		else
			char = Human.new('dummy', 'pc', 'artificial')
			char.current_side = 2
			@side2.push(char)
			rename_humans(@side2)
		end

		@side1.each  { |xpc| @combatants.push(xpc) }
		@side2.each  { |xpc| @combatants.push(xpc) }
	end


	def fight
		init_fight

		player = @players.get_player(@kumiteist_id)
		character = player.character

		i=0
		while true
			send_all('clear_screen')
			draw_all("Kumite, streak=#{i}" + EOL)
			prompt_anyone

			if(character.kumite_streak < i)
				character.kumite_streak = i
			end

			character.check_hitpoints
			
			send_all('clear_screen')
			play_rounds

			if(not character.unconscious and not character.dead)
				init_opponents(false)
			else
				break
			end

			i += 1
		end
	
		send_all('clear_screen')
		draw_all("End of Kumite, streak=#{i}")
		prompt_anyone

		send_all('clear_screen')
		send_all('draw', 'GAME OVER - ENTER TO GET BACK')
		send_all('ack')
		send_all('game_over')

		restructor
	end

	def play_rounds

		round=1
		catch (:game_over) do
			while true

				@side1.each { |char| char.roll_initiative }
				@side2.each { |char| char.roll_initiative }

				@side1.sort! { |a,b| a.initiative <=> b.initiative }
				@side2.sort! { |a,b| a.initiative <=> b.initiative }

				@combatants.sort! { |a,b| a.initiative <=> b.initiative }

				play_round(round)

				round=round+1
			end
		end

	end
end

