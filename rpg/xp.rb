
def level_table(current_level)
	needed_xp = current_level * 1000
end

def can_level?(current_level, current_level_xp)
	needed_xp = level_table(current_level)

	if(current_level_xp >= needed_xp)
		return true
	end

	return false
end

class ArmsLevel

	def initialize

		@critical_kills              = 0
		@critical_kills_list         = Array.new

		@critical_kos_inflicted      = 0
		@critical_kos_inflicted_list = Array.new

		@wounds_inflicted      = 0
		@wounds_inflicted_list = Array.new

		@kills                 = 0
		@kills_list            = Array.new

		@kos_inflicted         = 0
		@kos_inflicted_list    = Array.new

		@damage_inflicted      = 0

	end

	attr_accessor :critical_kills
	attr_accessor :critical_kills_list

	attr_accessor :critical_kos_inflicted
	attr_accessor :critical_kos_inflicted_list

	attr_accessor :wounds_inflicted
	attr_accessor :wounds_inflicted_list

	attr_accessor :kills
	attr_accessor :kills_list

	attr_accessor :kos_inflicted
	attr_accessor :kos_inflicted_list

	attr_accessor :damage_inflicted

	def to_s
		"critical_kills         #{COLOUR_RED+COLOUR_REVERSE}#{@critical_kills}#{COLOUR_RESET} (#{COLOUR_RED+COLOUR_REVERSE}#{get_xp('critical_kills')}#{COLOUR_RESET})}" +
		"critical_kos_inflicted #{COLOUR_RED}#{@critical_kos_inflicted}#{COLOUR_RESET} (#{COLOUR_RED}#{get_xp('critical_kos_inflicted')}#{COLOUR_RESET})}" +

		"kills #{COLOUR_MAGENTA+COLOUR_REVERSE}#{@kills}#{COLOUR_RESET} (#{COLOUR_MAGENTA+COLOUR_REVERSE}#{get_xp('kills')}#{COLOUR_RESET})}" +
		"kos_inflicted #{COLOUR_MAGENTA}#{@kos_inflicted}#{COLOUR_RESET} (#{COLOUR_MAGENTA}#{get_xp('kos_inflicted')}#{COLOUR_RESET})}" +

		"wounds_inflicted #{COLOUR_YELLOW+COLOUR_REVERSE}#{@wounds_inflicted}#{COLOUR_RESET} (#{COLOUR_YELLOW+COLOUR_REVERSE}#{get_xp('wounds_inflicted')}#{COLOUR_RESET})}" +

		"damage_inflicted #{COLOUR_CYAN+COLOUR_REVERSE}#{@damage_inflicted}#{COLOUR_RESET} (#{COLOUR_CYAN+COLOUR_REVERSE}#{get_xp('damage_inflicted')}#{COLOUR_RESET})}"
	end

	def get_xp_all
		xp = 0
		xp += get_xp('critical_kills')
		xp += get_xp('critical_kos_inflicted')
		xp += get_xp('kills')
		xp += get_xp('kos_inflicted')
		xp += get_xp('wounds_inflicted')
		xp += get_xp('damage_inflicted')
		return xp.to_i
	end
	
	def get_xp(what)
		xp=0

		case what

			when 'critical_kills'
				@critical_kills_list.each         { |scalp| xp += (scalp.strength*1.5) }
				return xp.to_i
			when 'critical_kos_inflicted'
				@critical_kos_inflicted_list.each { |scalp| xp += scalp.strength       }
				return xp.to_i

			when 'kills'
				@kills_list.each                  { |scalp| xp += scalp.strength       }
				return xp.to_i

			when 'kos_inflicted'
				@kos_inflicted_list.each          { |scalp| xp += (scalp.strength/2)   }
				return xp.to_i

			when 'wounds_inflicted'
				@wounds_inflicted_list.each       { |slash| xp += 100 }
				return xp.to_i
	
			when 'damage_inflicted'	
				xp += @damage_inflicted
				return xp.to_i
		end

		raise ArgumentError("get_xp : what='#{what}'")

	end 

end


class BodyLevel

	def initialize
		@deaths                = 0
		@knock_outs_sustained  = 0
		@damage_sustained      = 0
		@wounds_sustained      = 0
	end

	#
	attr_accessor :deaths # if own team loses and unco, that should count
		attr_accessor :death_list
	attr_accessor :knock_outs_sustained
		attr_accessor :sleep_list
	attr_accessor :damage_sustained
	attr_accessor :wounds_sustained

	def to_s
		COLOUR_GREEN +
		"\ndeaths: #{@deaths}" +
		"\nknock outs sustained: #{@knock_outs_sustained}" +
		"\ndamage sustained: #{@damage_sustained}" +
		"\nwounds sustained: #{@wounds_sustained}" +
		COLOUR_RESET
	end

end


class HealLevel

	def initialize
		@raised_dead           = 0
		@revived               = 0
		@healed_injuries       = 0
		@healed_hp             = 0
	end
	
	attr_accessor :raised_dead
		attr_accessor :raised_list
	attr_accessor :revived
		attr_accessor :revived_list
	attr_accessor :healed_injuries
	attr_accessor :healed_hp

	def to_s
		COLOUR_CYAN +
		"\nraised dead:     #{@raised_dead}"  +
		"\nrevived:         #{@revived}" +
		"\nhealed injuries: #{@healed_injuries}" +
		"\nhealed hp:       #{@healed_hp}" +
		COLOUR_RESET
	end
end

class XP 

	attr_accessor :arms_level
	attr_accessor :body_level
	attr_accessor :heal_level

	def initialize
		@arms_level            = 1
		@body_level            = 1
		@heal_level            = 1

		@total_arms_lvl = ArmsLevel.new
		@total_body_lvl = BodyLevel.new
		@total_heal_lvl = HealLevel.new

		@current_arms_lvl = ArmsLevel.new
		@current_body_lvl = BodyLevel.new
		@current_heal_lvl = HealLevel.new
	end


	def can_level?
		false #TODO
	end

	def add_critical_kill(opponent)
		@total_arms_lvl.critical_kills   += 1
		@total_arms_lvl.critical_kills_list.push(opponent)
	
		@current_arms_lvl.critical_kills += 1
		@current_arms_lvl.critical_kills_list.push(opponent)
	end

	def add_kill(opponent)
		@total_arms_lvl.kills   += 1
		@total_arms_lvl.kills_list.push(opponent)
	
		@current_arms_lvl.kills += 1
		@current_arms_lvl.kills_list.push(opponent)
	end

	def add_critical_ko_inflicted(opponent)
		@total_arms_lvl.critical_kos_inflicted   += 1
		@total_arms_lvl.critical_kos_inflicted_list.push(opponent)
	
		@current_arms_lvl.critical_kos_inflicted += 1
		@current_arms_lvl.critical_kos_inflicted_list.push(opponent)
	end


	def add_ko_inflicted(opponent)
		@total_arms_lvl.kos_inflicted   += 1
		@total_arms_lvl.kos_inflicted_list.push(opponent)
	
		@current_arms_lvl.kos_inflicted += 1
		@current_arms_lvl.kos_inflicted_list.push(opponent)
	end

	def add_damage_inflicted(hp)
		@total_arms_lvl.damage_inflicted   += hp
		@current_arms_lvl.damage_inflicted += hp
	end


	def add_wound_inflicted(wound)
		@total_arms_lvl.wounds_inflicted   += 1
		@total_arms_lvl.wounds_inflicted_list.push(wound)
	
		@current_arms_lvl.wounds_inflicted += 1
		@current_arms_lvl.wounds_inflicted_list.push(wound)
	end

	def get_total_arms_xp
		@total_arms_lvl.get_xp_all
	end

	def get_current_arms_xp
		@current_arms_lvl.get_xp_all
	end

	def get_xp_stats
		p self
		"\tarms: #{@arms_level} (#{get_current_arms_xp})/(#{get_total_arms_xp})" #+
		#EOL + "\tbody: #{@body_level} (not yet)" +
		#EOL + "\theal: #{@heal_level} (not yet)"
	end

end

