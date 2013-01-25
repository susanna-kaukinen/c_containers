#!/home/susanna/.rvm/rubies/ruby-1.9.3-p0/bin/ruby

require 'socket'
require 'monitor'
require 'rubygems'
require 'json'
require 'yaml'
require 'securerandom'
require 'monitor'



require './weapon.rb'
require './player.rb'

require './synchronised_stack.rb'
require './ansi.rb'
require './create_character.rb'
require './choose_game.rb'
require './waiting_room.rb'
require './dice.rb'
require './wound.rb'
require './mem.rb'

require './character.rb'
require './xp.rb' 
require './monsters.rb'
require './names.rb'

require './actions.rb'
require './attack.rb'
require './block.rb'
require './heal.rb'
require './attack.rb'
require './no_action.rb'
require './draw.rb'
require './ai.rb'
require './rule_monster_engine.rb'
require './game_core.rb'


	require './game_orcs.rb'
	require './game_trolls.rb'
	require './game_kobold_ambush.rb'
	require './game_kumite.rb'


Thread.abort_on_exception = true

# probably totally useless to add there here
def create_games 
	games  = Games.new
	orcs   = Orcs.new(games)
	troll  = Trolls.new(games)
	kobls  = KoboldAmbush.new(games)
	kumite = Kumite.new(games)

	games.add_games(orcs, troll, kobls, kumite)

	return games
end


# <def_main>
def main

	def _connector_loop(port, games)
		server = TCPServer.open(port)
		threads = Hash.new

		i=0
		while true

			i += 1
			socket = server.accept

			socket.write('Welcome, hit enter!')
			cmd = socket.gets

			auto = false
			if(cmd[0] == 'a')
				auto = true
			end	

			if(socket)
				p = Player.new("p#{i}", socket, games)
				p.run(threads)

				if(not auto)
					send_msg(p, 'create_character')
				else
					#p.character = Character.new('testplayer','b', 'biological')
					p.character = Character.load('Rage')
					p.character.current_side = 1
					p.character.current_player_id = p.id
					p.games = games
					xxx    = Kumite.new(games)
					games.add_games(xxx)
					#xxx    = Orcs.new(games)
					xxx.join(p, true)
					catch (:done) { 
						send_msg(p, 'clear_screen')
						xxx.enter(p) 
					}
				end
			end

			sleep 0.5
		end
	end

	port   = ARGV[0].to_i

	games = create_games

	_connector_loop(port, games)


end
#</def_main>

main


