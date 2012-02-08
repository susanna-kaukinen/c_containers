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

Thread.abort_on_exception = true

def choose_game(player)


	def _handle_game_screen_cmd(player)

		cmd = player.prompt('cmd')

		case cmd[0]
			when 'm'
				player.tell('create_character')
				throw :done
			when 'n'
				player.tell('choose_game')
				throw(:done)
		end

		return 'game'
	end

	def _draw_game_screen(write, bottom_text)

		_print_header(write)
	
		write COLOUR_YELLOW_BLINK + ' J' + COLOUR_RESET + ' = Join game'
		write COLOUR_RED_BLINK    + " N" + COLOUR_RESET + ' = New game'
		write COLOUR_BLUE_BLINK   + ' M' + COLOUR_RESET + ' = back to main Menu'

		if(bottom_text!=nil)
			# nop			
		elsif(character != nil)
			bottom_text = "<TODO>"
		else
			bottom_text = "<TODO>"
		end

		write_bottom_text(write, bottom_text)
	end

	def _game_screen(player, write, bottom_text)
		_draw_game_screen(player.method(:write), bottom_text)
		return _handle_game_screen_cmd(player)
	end

	
	# |choose_game

	while true
		screen, bottom_text = _game_screen(player, player.method(:write), bottom_text)
	end

end

# <def_main>
def main

	server = TCPServer.open(20025)

	threads = Hash.new


	i=0
	while true

		i += 1
		socket = server.accept

		if(socket)
			p = Player.new("p#{i}", socket)
			p.run(threads)
			p.tell('create_character')
		end

		sleep 0.5
	end

end
#</def_main>

main


