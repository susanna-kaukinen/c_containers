#!/home/susanna/.rvm/rubies/ruby-1.9.3-p0/bin/ruby

require 'socket'
require 'monitor'
require 'rubygems'
require 'json'
require 'yaml'
require 'securerandom'
require 'monitor'

require './player.rb'
require './weapon.rb'
require './character.rb'
require './synchronised_stack.rb'
require './ansi.rb'
require './create_character.rb'
require './choose_game.rb'
require './waiting_room.rb'
require './dice.rb'
require './wound.rb'
require './mem.rb'
require './monsters.rb'
require './game_core.rb'
require './game_orcs.rb'
require './game_trolls.rb'
require './game_kobold_ambush.rb'
require './names.rb'


Thread.abort_on_exception = true

EOL = "\n\r"

# <def_main>
def main

	def _connector_loop(games)
		server = TCPServer.open(20025)
		threads = Hash.new

		i=0
		while true

			i += 1
			socket = server.accept

			if(socket)
				p = Player.new("p#{i}", socket, games)
				p.run(threads)
				send_msg(p, 'create_character')
			end

			sleep 0.5
		end
	end

	games = Games.new
	orcs  = Orcs.new(games)
	troll = Trolls.new(games)
	kobls = KoboldAmbush.new(games)

	games.add_games(orcs, troll, kobls)

	_connector_loop(games)


end
#</def_main>

main


