
def level_table(current_level)
	lvl = current_level
	needed_xp = 1000+1000*(lvl+0)*(lvl+0)
end

def _can_level?(current_level, current_level_xp)
	needed_xp = level_table(current_level)

	p "_can_level: needed_xp=#{needed_xp}, current_level_xp=${current_level_xp}"

	if(current_level_xp >= needed_xp)
		return true
	end

	return false
end


# </leveling>

class ArmsLevel

	def give_level_ups(character)

		old_ob = character.ob
	
		ob_inc = _1d3()
		ob_inc += _1d3()
		ob_inc += _1d3()

		character.ob += ob_inc

		#

		old_qu = character.quickness

		qu_inc = _1d3()

		character.quickness += qu_inc


		return true, old_ob, character.ob, old_qu, character.quickness
			

	end

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
		attr_accessor :damage_sustained
		attr_accessor :wounds_sustained
		attr_accessor :wounds_sustained_list
		attr_accessor :critical_kos_sustained
		attr_accessor :critical_kos_sustained_list
		attr_accessor :critical_kills_sustained
		attr_accessor :critical_kills_sustained_list
		attr_accessor :ko_sustained

	def initialize
		@damage_sustained                  = 0
		@wounds_sustained                  = 0
		@wounds_sustained_list             = Array.new
		@critical_kos_sustained_list       = Array.new
		@critical_kills_sustained_list     = Array.new
		@ko_sustained_list                 = Array.new
		@kill_sustained_list               = Array.new
	end

	def get_xp_all
		xp = 0
		xp += get_xp('damage_sustained')
		xp += get_xp('wounds_sustained')
		xp += get_xp('critical_kos_sustained_list')
		xp += get_xp('critical_kills_sustained_list')
		xp += get_xp('ko_sustained_list')
		xp += get_xp('kill_sustained_list')
		return xp.to_i
	end

	def get_xp(what)

		xp = 0

		case what
			when 'damage_sustained'
				xp = (damage_sustained*2).to_i
				p damage_sustained
				p xp
				return xp
			when 'wounds_sustained'
				xp = (wounds_sustained*300).to_i
				p wounds_sustained
				p xp
				return xp

			when 'critical_kos_sustained_list'
				@critical_kos_sustained_list.each { |x| xp += (x*0.75)   }
				p xp
				return xp
			when 'critical_kills_sustained_list'
				@critical_kills_sustained_list.each { |x| xp += x   }
				p xp
				return xp
			when 'ko_sustained_list'
				@ko_sustained_list.each { |x| xp += (x/4)   }
				p xp
				return xp
			when 'kill_sustained_list'
				@kill_sustained_list.each { |x| xp += (x/2)   }
				p xp
				return xp
		end

		raise ArgumentError("(body) get_xp : what='#{what}'")

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
	attr_accessor :total_arms_lvl

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

	## body:


	def add_damage_sustained(hp)
		@total_body_lvl.damage_sustained += hp
	end

	def add_wound_sustained(wound)
		@total_body_lvl.wounds_sustained += 1
		@total_body_lvl.wounds_sustained_list.push(wound)
	end

	def add_critical_ko_sustained(str)
		@total_body_lvl.critical_kos_sustained_list.push(str)
	end

	def add_critical_kill_sustained(str)
		@total_body_lvl.critical_kills_sustained_list.push(str)
	end

	def add_ko_sustained(str)
		@total_body_lvl.ko_sustained_list.push(str)
	end

	def add_kill_sustained(str)
		@total_body_lvl.kill_sustained_list.push(str)
	end

	def get_total_body_xp
		@total_body_lvl.get_xp_all
	end


	## alles:

	def get_xp_stats
		p self
		EOL + "\tarms: #{@arms_level} (#{get_total_arms_xp})" + 
		EOL + "\tbody: #{@body_level} (#{get_total_body_xp})"
		#EOL + "\theal: #{@heal_level} (not yet)"
	end



# leveling:

	def can_level?

		p 'foo'

	#	if(_can_level(@arms_level, get_current_arms_xp))
			return true
	#	end

	#	return false
	end

	def inc_level(level_of_char, level_data, character)

		try_lvl = level_of_char+1
		needed_xp = level_table(try_lvl)

		current_xp = level_data.get_xp_all

		if(current_xp>needed_xp)
			@arms_level += 1 # hack for arms for now
			return level_data.give_level_ups(character)
		end

		return false, needed_xp
	end

	def level_arms(character)
		p "old level=#{@arms_level}"
		return inc_level(@arms_level, @total_arms_lvl, character)
		p "new level=#{@arms_level}"
	end

end

