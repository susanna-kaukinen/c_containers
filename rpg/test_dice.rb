#!/home/susanna/.rvm/rubies/ruby-1.9.3-p0/bin/ruby

require './ansi.rb'
require './dice.rb'
require 'securerandom'

def write(*vargs)
	print *vargs
end

while true
	fumble = 5
#	print COLOUR_CYAN + "Rolling for attack, fumble=#{fumble}" + EOL + COLOUR_RESET
	draw_roll(print, roll_die('attack', fumble), true, true, fumble)
	print EOL

	#print COLOUR_MAGENTA + "Rolling for critical" + EOL + COLOUR_RESET
	draw_roll(print, roll_die('critical'), false, false, nil)
	print EOL
	
end
