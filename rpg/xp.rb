
module XP

	#experience
	attr_accessor :kills
		attr_accessor :kill_list
	attr_accessor :knock_outs_inflicted
		attr_accessor :ko_list
	attr_accessor :damage_inflicted
	attr_accessor :wounds_inflicted

	attr_accessor :deaths # if own team loses and unco, that should count
		attr_accessor :death_list
	attr_accessor :knock_outs_sustained
		attr_accessor :sleep_list
	attr_accessor :damage_sustained
	attr_accessor :wounds_sustained

	attr_accessor :raised_dead
		attr_accessor :raised_list
	attr_accessor :revived
		attr_accessor :revived_list
	attr_accessor :healed_injuries
	attr_accessor :healed_hp

	def init_xp
		@kills                 = 0
		@knock_outs_inflicted  = 0
		@damage_inflicted      = 0
		@wounds_inflicted      = 0

		@deaths                = 0
		@knock_outs_sustained  = 0
		@damage_sustained      = 0
		@wounds_sustained      = 0

		@raised_dead           = 0
		@revived               = 0
		@healed_injuries       = 0
		@healed_hp             = 0
	end

	def xp_s
		COLOUR_RED +
		"kills: #{@kills}" +
		"\nknock outs inflicted:  #{@knock_outs_inflicted}" +
		"\ndamage inflicted: #{@damage_inflicted}"  +
		"\nwounds inflicted: #{@wounds_inflicted}"  +
		COLOUR_GREEN +
		"\ndeaths: #{@deaths}" +
		"\nknock outs sustained: #{@knock_outs_sustained}" +
		"\ndamage sustained: #{@damage_sustained}" +
		"\nwounds sustained: #{@wounds_sustained}" +
		COLOUR_CYAN +
		"\nraised dead:     #{@raised_dead}"  +
		"\nrevived:         #{@revived}" +
		"\nhealed injuries: #{@healed_injuries}" +
		"\nhealed hp:       #{@healed_hp}" +
		COLOUR_RESET
	end

	def try_leveling
		return '?not implemented'
	end

end
