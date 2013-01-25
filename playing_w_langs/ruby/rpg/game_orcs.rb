class Orcs < Game

	def initialize(*args)
		@name = 'orcs'
		super(@name, *args)

		@sides = Array.new
		@sides.push('humans')
		@sides.push('orcs')
	end

	def Orcs.finalize(id)
		puts COLOR_MAGENTA +  "Object #{id} dying at #{Time.new}" + COLOUR_RESET
	end

	def restructor
		@games.del_game(@instance_id)
		game = Orcs.new(@games)
		@games.add_games(game)
	end


	def init_fight

		@players.all.each { |player|
			if(player.character.current_side==1)
				@side1.push(player.character)
			elsif(player.character.current_side==2)
				@side2.push(player.character)
			else
				raise ArgumentError.new("bad_player_side (#{player.character.current_side})")
			end
		}

		while (@side1.length <5) 
			char = Human.new('dummy', 'pc', 'artificial')
			char.current_side = 1
			@side1.push(char)
		end

		rename_humans(@side1)

		while(@side2.length < 5)
			char = Orc.new('dummy', 'pc', 'artificial')
			char.current_side = 2
			@side2.push(char)
		end
		
		rename_orcs(@side2)

		@side1.each  { |p| @combatants.push(p) }
		@side2.each  { |p| @combatants.push(p) }

	end
end


