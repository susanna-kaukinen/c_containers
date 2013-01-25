class Trolls < Game

	def initialize(*args)
		@name = 'troll'
		super(@name, *args)

		@sides = Array.new
		@sides.push('humans')
		@sides.push('trolls')
	end

	def restructor
		@games.del_game(@instance_id)
		game = Trolls.new(@games)
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

		@side2.push(Troll.new('', 'pc', 'artificial'))
		@side2.push(Troll.new('', 'pc', 'artificial'))
		@side2.push(Troll.new('', 'pc', 'artificial'))

		rename_trolls(@side2)
	
		@side2.each  { |xpc| xpc.current_side = 2 }

		@side1.each  { |xpc| @combatants.push(xpc) }
		@side2.each  { |xpc| @combatants.push(xpc) }

	end
end

