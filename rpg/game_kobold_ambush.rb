class KoboldAmbush < Orcs

	def initialize(*args)
		super(*args)

		@name = 'kobold ambush'
		@sides = Array.new
		@sides.push('humans')
		@sides.push('kobolds')
	end

	def restructor
		@games.del_game(@instance_id)
		game = KoboldAmbush.new(@games)
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

		while (@side1.length <3) 
			char = Human.new('dummy', 'pc', 'artificial')
			char.current_side = 1
			@side1.push(char)
		end

		rename_humans(@side1)

		char = Troll.new('dummy', 'pc', 'artificial')
		char.current_side = 2
		@side2.push(char)

		rename_trolls(@side2)
	
		while(@side2.length < 7)
			char = Kobold.new('dummy', 'pc', 'artificial')
			char.current_side = 2
			@side2.push(char)
		end
		
		rename_kobolds(@side2)

		@side1.each  { |xpc| @combatants.push(xpc) }
		@side2.each  { |xpc| @combatants.push(xpc) }

	end
end

