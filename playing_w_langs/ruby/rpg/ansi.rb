
COLOUR_BLACK      = "\033[01;30m";
COLOUR_RED        = "\033[01;31m";
COLOUR_GREEN      = "\033[01;32m";
COLOUR_YELLOW     = "\033[01;33m";
COLOUR_BLUE       = "\033[01;34m";
COLOUR_MAGENTA    = "\033[01;35m";
COLOUR_CYAN       = "\033[01;36m";
COLOUR_WHITE      = "\033[01;37m";

COLOUR_BLACK_BRIGHT      = "\033[22;30m";
COLOUR_RED_BRIGHT        = "\033[22;31m";
COLOUR_GREEN_BRIGHT      = "\033[22;32m";
COLOUR_YELLOW_BRIGHT     = "\033[22;33m";
COLOUR_BLUE_BRIGHT       = "\033[22;34m";
COLOUR_MAGENTA_BRIGHT    = "\033[22;35m";
COLOUR_CYAN_BRIGHT       = "\033[22;36m";
COLOUR_WHITE_BRIGHT      = "\033[22;37m";

COLOUR_BLACK_BLINK      = "\033[05;30m";
COLOUR_RED_BLINK        = "\033[05;31m";
COLOUR_GREEN_BLINK      = "\033[05;32m";
COLOUR_YELLOW_BLINK     = "\033[05;33m";
COLOUR_BLUE_BLINK       = "\033[05;34m";
COLOUR_MAGENTA_BLINK    = "\033[05;35m";
COLOUR_CYAN_BLINK       = "\033[05;36m";
COLOUR_WHITE_BLINK      = "\033[05;37m";

COLOUR_REVERSE       = "\033[7m";
COLOUR_RED_REVERSE_BLINK = COLOUR_RED_BLINK + COLOUR_REVERSE 

COLOUR_RESET      = "\033[0m"

SCREEN_CLEAR      = "\033[2J";
CURSOR_UP_LEFT    = "\033[0;0H";
CURSOR_PREV_LINE  = "\033[A";
CURSOR_BACK       = "\033[1D";
CURSOR_NEXT_LINE  = "\033[1E";
CURSOR_SAVE       = "\033[s";
CURSOR_RESTORE    = "\033[u";

EOL = "\n\r"
EOR = "\r"

def clear_screen (writer)
	writer.call(SCREEN_CLEAR + CURSOR_UP_LEFT)
end

def cursor_to(x,y)
	return "\033[#{x};#{y}H"
end

def cursor_clear_rows(amt)

	str=''

	i=0
	loop {
		for j in 0..69
			str += ' '
		end	

		str += "\n\r"
		
		i+=1

		break if (i>=amt)
	}


	return str

end
