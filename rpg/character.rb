
def generate(what)

	case what
		when "hp", "ob"
			return 1+50+rand(100)
	else
		return 1+rand(100)
	end
end

class Character

	# base, or so
	attr_accessor :full_name, :name, :party, :brains
	attr_accessor :personality
	attr_accessor :ob, :db, :ac, :hp
	attr_accessor :id

	# base stats
	attr_accessor :quickness

	# current/active

	attr_accessor :stun, :bleeding, :uparry, :downed, :prone, :blind, :penalties
	attr_accessor :unconscious, :unconscious_why
	attr_accessor :dead, :dead_why

	attr_accessor :current_db, :active_weapon, :current_hp, :current_ob

	attr_accessor :can_attack
	attr_accessor :current_blocks

	attr_accessor :wounds

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
		end
	end

	def do_clear_blocks
		@current_blocks = Hash.new
	end

	def heal(clear_blocks)
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

		@can_attack = true
		@cant_attack_text    = 'no reason'

		@wounds = []

		if(clear_blocks)
			do_clear_blocks
		end
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

		@quickness = generate("quickness")

		@personality = get_personality
		
		heal(true)
	end

	def initiative
		return @quickness - @penalties
	end

	def to_s
		"name:" + @name + 
		"\n\t ob:" + @ob.to_s()+ 
		"\n\t db:" + @db.to_s() + " current_db: " + @current_db.to_s() + 
		"\n\t ac:" + @ac.to_s()+ 
		"\n\t hp:" + @hp.to_s() + " current_hp: " + @current_hp.to_s() +
		"\n\t wp:" + @active_weapon.to_s()+ 
		"\n\t st:" + @stun.to_s()+ 
		"\n\t !p:" + @uparry.to_s()+ 
		"\n\t dw:" + @downed.to_s()+ 
		"\n\t pr:" + @prone.to_s()+ 
		"\n\t bl:" + @blind.to_s()+
		"\n\t wo:" + @wounds.to_json()
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
			print COLOUR_RED + COLOUR_REVERSE + @name + ' loses ' + @bleeding.to_s() + ' hits due to bleeding!' + COLOUR_RESET
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
	
		@current_blocks[against] = block_amount
	
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

