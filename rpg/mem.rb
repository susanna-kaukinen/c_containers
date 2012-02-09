
def mem_dump
	puts COLOUR_MAGENTA +  'RAM USAGE: ' + `pmap #{Process.pid} | tail -1`[10,40].strip + COLOUR_RESET
end
