
class Players


	def initialize()
		@players = Array.new # FIXME synch
	end

	def add(player)
		@players.push(player)
	end

	def del(player)
		@player.each { |p|		
			if(p.id == player.id)
				@player.delete_at(i)
			end
		}
	end

	def length
		@players.length
	end

	def write_all(*vargs)
		@players.each { |player| player.write(vargs) }
	end

end

class Game

	attr_accessor :name
	
	def initialize(game_type)
		@type = game_type
		@name = @type # FIXME

		@players = Players.new
	end

	def enter(player)
		@players.add(player)
		@players.write_all("#{player.character.name} entered game #{name}")
		player.tell('waiting_room', self)
		throw :done
	end

	def create_extra_pcs
	
	end

	def create_npcs

	end

	def play_round

	end

	def play_sub_round

	end

	def victory_conditions

	end

end

class Games


	def initialize
		@games = Array.new
	end

	def add_games(*vargs)
		vargs.each { |game| @games.push(game) }
	end

	def length
		@games.length
	end

	def get_all
		return @games
	end

end

