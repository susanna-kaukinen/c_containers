
class Character 
	# :race will be deduced from Class name

	# base, or so
	attr_accessor :full_name, :name, :party, :brains
	attr_accessor :personality
	attr_accessor :ob, :db, :ac, :hp
	attr_accessor :id

	# base stats
	attr_accessor :quickness

	# current/active
	attr_accessor :xp

	attr_accessor :current_player_id

	attr_accessor :stun, :bleeding, :uparry, :downed, :prone, :blind, :penalties
	attr_accessor :unconscious, :unconscious_why
	attr_accessor :dead, :dead_why

	attr_accessor :current_db, :active_weapon, :current_hp, :current_ob

	attr_accessor :can_attack
	attr_accessor :current_blocks

	attr_accessor :wounds
	attr_accessor :current_side

	def strength
		strength = @current_ob + @current_db + @current_hp + @ac + @quickness - @penalties
		return strength
	end

	def human?
		return true if(brains=='biological') 
		return false
	end

	def get_personality
		personality = rand(3)

		case personality
			when 0 ; return 'smart'
			when 1 ; return 'evil'
			when 2 ; return 'stupid'
			# vengeful could always hit back who hit them
		end
	end

	def get_profession
		profession = rand(3)

		case profession
			when 0 ; return 'fighter'
			when 1 ; return 'warrior monk'
			when 2 ; return 'healer'
		end
	end

	def do_clear_blocks
		@current_blocks = Hash.new
	end

	def heal_self_fully(clear_blocks)
		@stun = 0
		@bleeding = 0
		@uparry = 0
		@downed = 0
		@prone  = 0
		@blind  = 0
		@penalties = 0

		@unconscious     = false
		@unconscious_why = ''

		@dead	     = false
		@dead_why    = ''
		
		@current_hp    = @hp
		@active_weapon = Weapon.new("sword")
		@current_db    = @db # at this point
		@current_ob    = @ob
		@current_mana  = @mana

		@can_attack = true
		@cant_attack_text    = 'no reason'

		@wounds = []

		if(clear_blocks)
			do_clear_blocks
		end

		@current_side = nil

	end

	def can_heal?
		@current_mana>0 ? true : false
	end

	def _heal(healee, power_modifier)

		def _do_heal(healee, power)

			result = roll('heal')[0]

			if(healee.dead)
				result = power - 50 + result
				if(result>100)
					healee.dead        = false
					healee.unconscious = false
					@raised_dead +=1
				end
			elsif(healee.unconscious)
				result = power - 25 + result
				if(result>100)
					healee.unconscious = false
					@revived += 1
				end
			elsif(healee.prone>0 or healee.downed>0 or healee.stun>0 or healee.uparry>0)
				result = power - 12 + result

				healee.prone    -= 1 if(healee.prone>0)
				healee.downed   -= 1 if(healee.downed>0)
				healee.stun     -= 1 if(healee.stun>0)
				healee.uparry   -= 1 if(healee.uparry>0)
				healee.bleeding -= 1 if(healee.bleeding>0)

				@healed_injuries += 1
			end

			old_hp = healee.current_hp

			new_hitpoints = ((power + result) / 2.5).to_i
			healee.current_hp += new_hitpoints
			if(healee.current_hp > healee.hp)
				healee.current_hp = healee.hp
			end

			a = healee.hp - old_hp
			b = new_hitpoints

			c = (a<b) ? a : b

			@healed_hp += c if(c>0)

		end

		if(@profession == 'figher')
			throw :fighters_cant_heal
		elsif(@profession == 'warrior monk')
			_do_heal(healee, 50+power_modifier)
		elsif(@profession == 'healer')
			_do_heal(healee, 100+power_modifier)
		else
			throw :unknown_profession
		end

	end

	def heal(healees)

		p healees

		if(not can_heal?)
			throw :no_mana
		end

		if(healees.is_a? Character) # heal one char vs all
			power_modifier = 0  # no penalty for healing one char
			_heal(healees, power_modifier)
		else
			power_modifier = (healees.length*20)
			power_modifier *= -1

			healees.each { |healee|
				_heal(healee, power_modifier)
			}
		end

		@current_mana -= 1
	end

	def initialize(name, party, brains)
		@id = SecureRandom.uuid
		@full_name = name
		@name	= name[0..17] # andromud screen
		@party  = party
		@brains = brains
		@ob	= generate("ob")
		@db	= generate("db")
		@ac	= generate("ac")
		@hp	= generate("hp")

		@quickness   = generate("quickness")

		if(brains == 'artificial')
			@personality = get_personality
			@profession  = get_profession
		else
			@personality = get_personality # later, let choose alignment
			@profession  = get_profession
		end

		@mana = generate('mana')

		@current_player_id = nil

		heal_self_fully(true)

		@xp = XP.new
	end

	def roll_initiative
		@initiative_roll_this_round = roll('initiative')[0]
	end

	def initiative
		return @quickness - @penalties + @initiative_roll_this_round
	end

	def to_s
		to_str('none')
	end

	def to_str(fold)
		if(fold=='stats')
			      "\t cl:" + @profession.to_s() +
			      "\t ob:" + @ob.to_s()+ 
			EOL + "\t db:" + @db.to_s() + " current_db: " + @current_db.to_s() + 
			EOL + "\t hp:" + @hp.to_s() + " current_hp: " + @current_hp.to_s() +
			      "\t wp:" + @active_weapon.to_s() 
		elsif(fold=='wounds')
			      "\t st:" + @stun.to_s()+ 
			      "\t !p:" + @uparry.to_s()+ 
			EOL + "\t dw:" + @downed.to_s()+ 
			      "\t pr:" + @prone.to_s()+ 
			EOL + "\t bl:" + @blind.to_s()+
			      "\t wo:" + @wounds.length().to_s
		elsif(fold=='xp')
			return @xp.get_xp_stats
		else
			"name:" + @name + 
			EOL + "\t br: #{@brains}" +
			EOL + "\t cl:" + @profession.to_s() +
			EOL + "\t ob:" + @ob.to_s()+ 
			EOL + "\t db:" + @db.to_s() + " current_db: " + @current_db.to_s() + 
			EOL + "\t ac:" + @ac.to_s()+ 
			EOL + "\t hp:" + @hp.to_s() + " current_hp: " + @current_hp.to_s() +
			EOL + "\t wp:" + @active_weapon.to_s()+ 
			EOL + "\t st:" + @stun.to_s()+ 
			EOL + "\t !p:" + @uparry.to_s()+ 
			EOL + "\t dw:" + @downed.to_s()+ 
			EOL + "\t pr:" + @prone.to_s()+ 
			EOL + "\t bl:" + @blind.to_s()+
			EOL + "\t wo:" + @wounds.length().to_s
		end

	end


	def add_wound(wound)
		@wounds.push(wound)
	end

	def recover_from_wounds

		@prone  -= 1 and return if(@prone>0)
		@downed -= 1 and return if(@downed>0)

		@stun   -= 1 if(@stun>0)
		@uparry -= 1 if(@uparry > 0)

	end

	def do_bleed
		if(@bleeding > 0)
			@current_hp -= @bleeding
			CURSOR_PREV_LINE
			CURSOR_PREV_LINE
			return COLOUR_RED + COLOUR_REVERSE + @name + ' loses ' + @bleeding.to_s() + ' hits due to bleeding!' + COLOUR_RESET
		end
	end

	def check_hitpoints
		if(@current_hp<0)
			if((@hp + @current_hp) <0)
				@dead     = true
				@dead_why = 'hp'
			else
				@unconscious     = true
				@unconscious_why = 'hp'
			end
		end
	end

	def apply_wound_effects_after_attack

		@current_db = @db

	# FIXME: can char be downed and prone?
	# FIXME: if char suffers one prone and one downed, should they take a total of 1 or 2 rounds to recover from?
		if(@stun>0)
			@current_db -= 20
		end

		if(@downed>0)
			@current_db -= 30
		end

		if(@prone>0)
			@current_db -= 50
		end

		check_hitpoints

		if(@unconscious or @dead)
			@current_db -= 100
		end

	end


	def can_attack_now() # i.e. can this character attack now

		@can_attack = true

		check_hitpoints

		if(@dead)        then return false, "dead"        end
		if(@unconscious) then return false, "unconscious" end
		if(@prone>0)     then return false, "prone"       end
  		if(@downed>0)    then return false, "downed"      end

		if(@stun>0)
			str = 'stunned'
			
			if(@uparry > 0)
				 str += " and unable to parry"
			end

			return false, str
		end

		return @can_attack, 'no reason'

	end

	#
	# downed characters may parry, they are just on their knees
	# prone may not, they are face down in the dirt
	#
	def can_block_now()

		check_hitpoints

		if(@dead)
			return false, 'dead'
		end

		if(@unconscious)
			return false, 'unconscious'
		end
		
		if(@prone>0)       
			return false, 'prone'
		end
		
		if(@uparry>0)    
			return false, 'unable to parry'
		end

		return true, 'no reason'
	end

	def block(against, block_amount)

		if(@current_blocks[against] and @current_blocks[against] >0)
			@current_blocks[against] += block_amount
		else
			@current_blocks[against] = block_amount
		end
	
		@current_ob -= block_amount

		return
	end

	def blocks?(against)
		block_amt = @current_blocks[against]
		if(block_amt==nil)
			return 0
		end

		return block_amt
	end

	def save
		begin
			data = YAML::dump(self)
			File.open('saves/save_' + @name + '.yaml', 'w+') {|f| f.write(data) }
			return true
		rescue
			return false
		end
	end

	def Character.load(name)

		char_as_yaml = ''

		begin
			File.open('saves/save_' + name + '.yaml').each_line { |line_in_file|
				char_as_yaml += line_in_file
			}
		rescue
			return nil
		end

		p char_as_yaml

		return YAML::load(char_as_yaml)
	end


end


def generate(*vargs)

	case vargs[0]
		when "hp", "ob"
			return 1+50+rand(100)
		when "mana"
			case @profession
				when 'fighter'
					return 0
				when 'warrior monk'
					return rand(2)+1
				when 'healer'
					return 3
				else
					throw :unknown_profession
			end
		
	else
		return 1+rand(100)
	end
end

