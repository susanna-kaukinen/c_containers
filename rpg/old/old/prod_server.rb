#!/home/susanna/.rvm/rubies/ruby-1.9.3-p0/bin/ruby

#require 'io'
require 'socket'
require 'monitor'
require 'rubygems'
require 'json'
require 'yaml'
require 'securerandom'
#
# TODO: severed, crushed, bruised, miinukset: e.g. char at -10%, blind toteuttamatta (-100)
#


# HTC Desire Z AndroMud screen props: height: 13 lines, width: 72
# 1234567890123456789012345678901234567890123456789012345678901234567890
# ========================= Round: #2 (1/4) ============================

# ==<ANSI>===

=begin
https://en.wikipedia.org/wiki/ANSI_escape_code

0	1	2	3	4	5	6	7
Black	Red	Green	Yellow	Blue	Magenta	Cyan	White
=end

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

# ==</ANSI>===


$tight=true # h=13, w=72 screen

if($tight)
	$motd='motd_tight.txt'
else
	$motd='motd.txt'
end


def generate(what)

	case what
		when "hp", "ob"
			return 1+50+rand(100)
	else
		return 1+rand(100)
	end
end

class Critical
	attr_accessor :type, :level
end

class Wound
	attr_accessor :damage, :bleeding, :stun, :uparry, :downed, :prone, :unconscious, :dead	
	attr_accessor :target
	attr_accessor :text

	def initialize()
		@damage = 0
		@bleeding = 0 # how many hp:s per round
		@stun   = 0
		@uparry = 0
		@downed = 0
		@prone  = 0
		@unconscious = false
		@dead        = false

		@target = ''

		@text = ''
	end

	def to_s()

		str='Wound:'

		if(@damage>0)
			str += @damage.to_s
		end

		return str
	end

	def to_json(*a)
		{
			'class'       => self.class.name,
			'damage'      => "#{@damage}",
			'bleeding'    => "#{@bleeding}",
			'stun'        => "#{@stun}",
			'uparry'      => "#{@uparry}",
			'downed'      => "#{@downed}",
			'prone'       => "#{@prone}",
			'unconscious' => "#{@unconscious}",
			'dead'        => "#{@dead}",
			'target'      => "#{@target}",
			'text'        => "#{@text}",

		}.to_json(*a)
	end

	def self.json_create(o)
		new(*o['data'])
	end

	def apply(character, target)

		if(character == nil)
			throw :no_character
		end

		@text = character.name + " was hit in the " + target

		if(@damage)
			character.current_hp -= @damage
	
			@text += " and was dealt " + @damage.to_s() + " extra damage"
		end

		if(@stun > 0)
			character.stun += @stun
			@text += " and is stunned for " + @stun.to_s() + " rounds"
		end

		if(@bleeding > 0)
			character.bleeding += @bleeding
			@text += " and is bleeding " + @bleeding.to_s() + " hits worth each round"
		end
		
		if(@uparry > 0)
			character.uparry += @uparry
			@text += " and is unable to parry for " + @uparry.to_s() + " rounds"
		end

		if(@downed > 0)
			character.downed += @downed
			@text += " and is downed for " + @downed.to_s() + " rounds"
		end

		if(@prone > 0)
			character.prone += @prone
			@text += " and is prone for " + @prone.to_s() + " rounds"
		end

		if(@unconscious == true)
			character.unconscious = true
			@text += " and is unconscious "
		end

		if(@dead == true)
			character.dead = true
			@text += " and is dead"
		end

		character.add_wound(self)
		
		#p self
		
		print COLOUR_CYAN + "\t===> " + @text + "\n" + COLOUR_RESET

	end

end

class Weapon
	attr_accessor :name, :fumble, :criticalType1, :criticalType2, :deal_damage

	def to_s
		@name + ", fumble=" + @fumble.to_s()	
	end

	def initialize(name)
		@name   = name
		@fumble = 1 + rand(8)
	end

	def damage_table(result)

		if(result<80)
			return 0, nil
		end

		hp = 0
		crit = Critical.new()

		if(rand(2)==1)
			crit.type = "slash"
		else
			crit.type = "krush"
		end

		#print COLOUR_YELLOW + crit.type + COLOUR_RESET + "\n"

		case result
			when -9999 .. 100
				crit = nil
			when 100 .. 115
				crit.level = "A"
			when 116 .. 130
				crit.level = "B"
			when 131 .. 140
				crit.level = "C"
			when 141 .. 150
				crit.level = "D"
			when 151 .. 9999
				crit.level = "E"
		end

		hp = (result-80) / 2

		return hp, crit

	end

	def resolve_critical(critical, defender)

		#print '*** CRITICAL *** ' + "\n"
		#print '*** CRITICAL *** ' + "\n"
		#print '*** CRITICAL *** ' + "\n"

	
		_roll = roll(nil, nil, nil)[1] 


		crit_bonus = 0
		case critical.level
			when "B"
				crit_bonus += 5
			when "C"
				crit_bonus += 10
			when "D"
				crit_bonus += 15
			when "E"
				crit_bonus += 20
		end
	
		result = _roll + crit_bonus

		wound = Wound.new()

		target_bonus = 0
=begin
		# wounds should have severity, perhaps 1 to 3
		# 1 = bruised/cut, 2 = crushed/sliced, 3 = shattered/severed 4 = lethal direct
		# these need to be considered in combination w/wound targets


so eg

class knee

	@bruisable     = true
	@cuttable      = true
	@crushable     = true
	@slicable      = true
	@shatterable   = true
	@severable     = true # "leg severed from knee down"
	@lethal_direct = false
end

class head

	@bruisable     = true # "face bruised"
	@cuttable      = true # "face cut"
	@crushable     = true # "skull fracture"
	@slicable      = false 
	@shatterable   = true # "skull shattered" => lethal_direct
	@severable     = true # "head severed"
	@lethal_direct = true, shatterable, severable
end

 => something like that, por ejemplo

=end		
		case result
			when 0 ... 10
				print 'Zip!' + "\n"
			when 10 ... 20
				wound.damage = 1 + rand(10)	
			when 20 ... 40
				wound.damage = 1 + rand(10)	
				wound.stun   = 1
			when 40 ... 60
				wound.damage = 1 + rand(10) + 10
				wound.stun   = 2
				wound.uparry = 1
				target_bonus = 5
			when 60 ... 80
				wound.damage = 1 + rand(15) + 10
				wound.stun   = 3
				wound.uparry = 2
				target_bonus = 15
			when 80 ... 90
				wound.damage = 1 + rand(15) + 15	
				target_bonus = 25
			when 90 ... 95
				wound.damage = 1 + 30
				wound.prone = 3
				target_bonus = 35
			when 95 ... 100
				wound.damage = 1 + rand(30) + 30
				wound.unconscious = true
				target_bonus = 40
			when 100 ... 9999
				wound.dead   = true
				target_bonus = 60
		end

		if(critical.type == 'slash')
			wound.bleeding = wound.stun
			wound.stun = 0

			wound.uparry /= 2
		end
		

		target_result = 1 + rand(100) + target_bonus
		case target_result
			when -9999 ... 7
				wound.target = 'secondary arm'
			when 7 ... 14
				wound.target = 'weapon arm'
			when 14 ... 21
				wound.target = 'left leg' # thigh, calf, foot, ankle, knee (is below)
			when 21 ... 28
				wound.target = 'right leg'
			when 28 ... 35 
				wound.target = 'stomach' # @see side below
			when 35 ... 42
				wound.target = 'side' # can be cut to organs, ribs can break
			when 42 ... 48
				wound.target = 'back'
			when 48 ... 55
				wound.target = 'neck' # compare: throat. neck breaks/throat is sliced
			when 55 ... 62
				wound.target = 'shoulder' # can break or shatter
			when 62 ... 70
				wound.target = 'elbow'   # can break or shatter
			when 70 ... 77
				wound.target = 'knee'	 # joints can be shattered or perhaps severed, these need to be object w/properties, perhaps - have
			when 77 ... 84                   # properties like severable and crushable and so forth
				wound.target = 'throat'  # can be crushed or slashed or punctured
			when 84 ... 91
				wound.target = 'skull'   # can be crushed, should be head if severed and head punctured
			when 91 ... 9999
				wound.target = 'groin'   # for slash wounds, can bleed profusely

		end

		wound.apply(defender, wound.target)
	end

	def deal_damage(attacker, defender, result)
		hp_damage, critical = damage_table(result)

		defender.current_hp -= hp_damage

		if(hp_damage>0)
			print "\t" + name + " deals " + COLOUR_RED + hp_damage.to_s() + COLOUR_RESET + " hit points of damage.\n"
		else
			if(defender.dead || defender.unconscious)
				print attacker.name + "misses"
			else
				if(rand(2)==1)
					evade = "dodges"
				else
					evade = "blocks"
				end
				print defender.name + " " + evade + " the attack\n"
			end
		end

		if(critical)
			print COLOUR_WHITE_BLINK + "\nCritical: " + critical.level + ' ' + critical.type + "es\n" + COLOUR_RESET
			resolve_critical(critical, defender)
		end

		colour = COLOUR_GREEN
		if(defender.current_hp <= 0) 
			colour = COLOUR_RED	
		end
		
 		#print defender.name + " has " + colour + defender.current_hp.to_s() + COLOUR_RESET + " hit points left\n"

		if(defender.current_hp<0 and defender.dead == false)
			if(defender.unconscious==false)
				print COLOUR_YELLOW_BLINK + defender.name + " falls unconscious.\n" + COLOUR_RESET
			else
				print COLOUR_YELLOW_BLINK + defender.name + " is unconscious.\n" + COLOUR_RESET
			end
			defender.unconscious = true
		end

		if(defender.current_hp < -defender.hp or defender.dead == true)
			defender.dead = true
			print COLOUR_RED_BLINK + defender.name + " is DEAD!\n" + COLOUR_RESET
		end

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
			File.open('character_' + @name + '.yaml', 'w+') {|f| f.write(data) }
			return true
		rescue
			return false
		end
	end

	def Character.load(name)

		char_as_yaml = ''

		begin
			File.open('character_' + name + '.yaml').each_line { |line_in_file|
				char_as_yaml += line_in_file
			}
		rescue
			return nil
		end

		p char_as_yaml

		return YAML::load(char_as_yaml)
	end


end

def roll(weapon, attacker, __do_attack)

	critical_roll = false
	if(weapon==nil and attacker==nil)
		critical_roll = true
	end

	first_roll=0
	result=0
	while true
		first_roll = roll = 1 + rand(100)

		if(not critical_roll and weapon and result==0 and roll<weapon.fumble) then
			print result.to_s() + " => FUMBLE\n"
			if(attacker != nil) then
				print attacker.name + " deals himself a blow:\n"
				__do_attack.call(attacker, attacker, 'fumblingly')
			end
			fumble=true
		end

		result += roll

		if(critical_roll)

			colour = ''	
			case roll
				when 80 ... 90
					colour = COLOUR_YELLOW
				when 90 ... 100
					colour = COLOUR_RED
			end

			print colour + "Crit roll=" + roll.to_s() + COLOUR_RESET + "\n"
		else

			if(roll>=96)
				print COLOUR_GREEN + "OPEN-ENDED: " + roll.to_s() + "\n" + COLOUR_RESET
			else
				if(result!=roll)
					print "Roll:" + roll.to_s + "/" + result.to_s + "(tot)"
				else
					print "Roll:" + roll.to_s
				end
			end
		end


		if (critical_roll or roll<96)
			return result, first_roll, fumble
		end


	end
end

def sub_round(character, opponents)

	def _attack(character, opponents)

		def __choose_opponent(attacker, opponents)

			def ___prune_non_targets(personality, opponents)

				choice=''
		
				opps = Array.new

				if(personality == 'evil')

					choice = 'weakest'

					opponents.each { |opp|

						opp.check_hitpoints

						if (not opp.dead)
							target_print COLOUR_GREEN + "#{opp.name} not dead, good target" + COLOUR_RESET
							opps.push(opp)
						else
							target_print COLOUR_RED + "#{opp.name} is dead, not a target" + COLOUR_RESET
						end
					}
				else
					opponents.each { |opp|

						opp.check_hitpoints

						if (opp.current_hp>0 and not opp.dead and not opp.unconscious)
							target_print COLOUR_GREEN + "#{opp.name} good target" + COLOUR_RESET
							opps.push(opp)
						else
							target_print COLOUR_RED + "#{opp.name} not hp>0+not dead+not unco, not a target" + COLOUR_RESET
						end
					}

					if(personality == 'smart')
						choice = 'weakest'
					else
						choice = 'strongest'
					end

				end

				return opps, choice
			end

			def ___choose_from_remaining(opps, choice)

				def ____stronger(opp1, opp2)
		
					if(opp1.strength > opp2.strength)
						return true
					end
		
					return false
				end

				def ____weaker(opp1, opp2)

					if(opp1.strength < opp2.strength)
						return true
					end
		
					return false

				end

				case choice
					when 'weakest'
						idx = opps.each_with_index.inject(0) { | min_i, (opp, i) |
							if (____weaker(opp, opps[min_i]))
								i
							else
								min_i
							end
						}
						return opps[idx]

					when 'strongest'

						idx = opps.each_with_index.inject(0) { | max_i, (opp, i) |
							if (____stronger(opp, opps[max_i]))
								i
							else
								max_i
							end
							
						}
						return opps[idx]
				end
			end

			# __choose_opponent
	
			target_print "total targets: #{opponents.length}"
			opps, choice = ___prune_non_targets(attacker.personality, opponents)
			target_print "pruned targets: #{opps.length}"
			chosen_opponent = ___choose_from_remaining(opps, choice)

			opponents.each { |o| p "#{o.name}=#{o.strength.to_s}," }

			return chosen_opponent, attacker.personality

		end

		def __do_attack(attacker, opponent, manner)

			if(opponent==nil)
				print "No-one to attack!"
				return
			end

			print COLOUR_GREEN + COLOUR_REVERSE + attacker.name + COLOUR_RESET + " ATTACKS " + COLOUR_RED + COLOUR_REVERSE + opponent.name + COLOUR_RESET +  " with " + attacker.active_weapon.name + " in a " + manner + " manner..\n"

			__roll  = roll(attacker.active_weapon, attacker, method(:__do_attack))
			_roll   = __roll[0]
			fumble  = __roll[2]

			if(fumble==true)
				return
			end 

			block = opponent.blocks?(attacker.name)

			if(block>0)
				print opponent.name + COLOUR_CYAN + ' blocks' + COLOUR_RESET + ' against ' + attacker.name + " w/#{block}"
			end

			result = attacker.current_ob - opponent.current_db - block + _roll

			print  " => result:" + result.to_s() + "\n"
			#print "ob-db-block+roll=result <=> #{attacker.current_ob}-#{opponent.current_db}-#{block}+#{_roll}=#{result}"

			attacker.active_weapon.deal_damage(attacker, opponent, result)
		end

		# _attack

		can_attack, why_cant = character.can_attack_now()

		if(can_attack)
			opponent, manner = __choose_opponent(character, opponents)
			__do_attack(character, opponent, manner)
			opponent.apply_wound_effects_after_attack
			return true
		end

		_explain_why_not(character, 'attack', why_cant)
		return false
	end


	def _explain_why_not(character, what, why_cant)

		def __puts(player, what, *vargs)
			if(what=='attack')
				print vargs
			else #if(what=='block')
				player.puts_me vargs
			end
		end

		player = $clients.get_player(character)

		str = COLOUR_WHITE + COLOUR_REVERSE + character.name + COLOUR_RESET + " cannot " + what + ", reason: "

		if (why_cant == 'dead')
			str += COLOUR_RED + COLOUR_REVERSE
		elsif (why_cant == 'unconscious')
			str += COLOUR_RED
		elsif (why_cant == 'prone')
			str += COLOUR_YELLOW + COLOUR_REVERSE
		elsif (why_cant == 'downed')
			str += COLOUR_YELLOW_BLINK
		else
			str += COLOUR_YELLOW
		end

		str += " " + why_cant + COLOUR_RESET

		__puts(player, what, str)

	end

	def _block(character, opponents)
	
		player = $clients.get_player(character)

		can_block, why_cant = character.can_block_now()

		if(can_block==false)
			_explain_why_not(character, 'block', why_cant)
			return false
		end

		loop {
			player.puts_me('Choose action:')

			prompt = ' (e)=all Equally' + "\n "

			opponents.each_with_index { |opponent,i|
				prompt += "(#{i})" + opponent.name + " "
				if(i%2==1)
					prompt += "\r\n "
				end
			}
			
			player.puts_me(prompt)

			cmd = player.gets

			if(cmd == 'e')
		
				how_much = character.current_ob / opponents.length
				
				opponents.each_with_index { |opponent,i|
					character.block(opponent.name, how_much)
				}

				player.puts_me("Blocking w/#{how_much} against all opponents.")

				return true
			else
				how_much = character.current_ob / 2

				opponents.each_with_index { |opponent,i|
					if(cmd == i.to_s)
						character.block(opponent.name, how_much)
						player.puts_me("Blocking w/#{how_much} against " + opponent.name)
					end
				}

				return true
			end
		

		}
	end

	def _prompt_pc_actions(character, opponents)


		def _cls(player)
			player.puts_me(CURSOR_RESTORE)
			player.puts_me(cursor_clear_rows(10))
			player.puts_me(CURSOR_RESTORE)
		end

		player = $clients.get_player(character)

		player.puts_others(character.name + ' ponders action, please wait...')

		can_attack, why_cant_attack = character.can_attack_now()
		can_block,  why_cant_block  = character.can_block_now()

		
		player.puts_me(CURSOR_SAVE)
		loop {

			if(can_attack == false and can_block == false)
				_explain_why_not(character, 'do anything', 'is incapacitated')
				player.gets
				return
			end

			if(character.current_ob<10)
				_explain_why_not(character, 'take more actions', 'all ob used up!')
				player.gets
				return
			end	

			player.puts_me('Choose action:')

			prompt = ' '
			prompt += "(a)=attack (#{character.current_ob}) " if(can_attack)
			prompt += '(b)=block  ' if(can_block)
			prompt += '( )=Auto   '
			prompt += '( )=run till damage'
			
			player.puts_me(prompt)

			cmd = player.gets

			case cmd
				when 'a'
					_cls(player)
					if(_attack(character, opponents))
						return
					end
				when 'b'
					_cls(player)
					_block(character, opponents)
				else
					player.puts_me 'Not implemented'	
			end
		
			sleep(1)

			_cls(player)
		}
	end


	def _npc_actions(character, opponents)

		_attack(character, opponents)

	end

	def _sub_round_init(character)
		character.do_bleed
		character.recover_from_wounds
		character.current_ob = character.ob
		character.current_blocks = Hash.new
	end

	# sub_round

	_sub_round_init(character)

	if(character.human?)
		_prompt_pc_actions(character, opponents)
	else
		_npc_actions(character, opponents)
	end

end


def combatants_to_s (combatants)
	
	str = ''

	combatants.each_with_index  { | character, index |  
		str += character.name + " " + character.to_s() + "\n" 
		character.wounds.each { | wound |
			if(wound)
				str += "Wound as json =>" + wound.to_json + "\n"
			end
		}
	}

	return str

end

def sock_io(sock, op, *vargs, iter)

	if(sock==nil || sock.closed?)
		server_print 'dead socket, no more i/o'
		return
	end

	if(op=='str')

		if(iter=='1st')
			sock.putc("\r")
		end

		vargs.each { |param|

			if(param.is_a? Array)
				for item in param
					return sock_io(sock, op, item, 'recurse')
				end
			end

			if(param.is_a? String)
				sock.puts(param)
			else
				p param
				sock.puts(param.to_s)
			end
		}
	elsif(op=='c')
		sock.putc(vargs[0]) 
	elsif(op=='gets')
		data = sock.gets
		if(data != nil)
			data = data.strip!
			return data
		end
		return ''
	else
		throw :no_op
	end

end

def sock_putc(sock, c)
	sock_io(sock, 'c', c, '1st')
end

def sock_puts(sock, *vargs)
	sock_io(sock, 'str', vargs, '1st')
end

def sock_gets(sock)
	return sock_io(sock, 'gets', nil, '1st')
end

class Clients

	include MonitorMixin

	def initialize(*args)
		super(*args)
 
		@pcs         = Array.new
		@npcs        = Array.new
		@combatants  = Array.new
		$threads     = Hash.new

		@sockets = Hash.new
		@players = Hash.new
	end

	def add_client(player)
		self.synchronize do
			@sockets[player.thread_id] = player.socket
			@players[player.thread_id] = player
		end
	end


	def dump_sockets
		self.synchronize do
			@sockets.each_key { |thread_id|
				p get_socket(thread_id)
			}
		end
	end
	def fight_cleanup
		self.synchronize do
			@pcs        = Array.new
			@npcs       = Array.new
			@combatants = Array.new
		end
	end

	def kick_player_threads(what)

		self.synchronize do

			p "kicker, existing threads: #{Thread.list}"

			if(what == 'all')

				@sockets.keys { |thread_id| 

					if(thread_id.alive?)
						thread_id.run
					else
						server_print 'Thread was dead - removed player' # or should? FIXME
					end
				}


			elsif (what == 'broken')
				

				kick_list = Array.new
				
				@sockets.each { |thr,soc|
				
					begin
						soc.puts(' ')
					rescue
						p "#{thr} on kick_list"
						kick_list.push(thr)
					end
				}


				p "threads w/broken sockets: #{kick_list}"

				kick_list.each { |thread_id| 
					if(thread_id.alive?)
						thread_id.run
					else
						server_print 'Thread was dead - removed player' # or should? FIXME
					end
				}

			else
				throw ':bad params'
			end

		end
	end


	def get_pcs
		self.synchronize do
			return @pcs
		end
	end

	def pcs_push(character)
		self.synchronize do
			@pcs.push(character)
		end
	end

	def get_npcs
		self.synchronize do
			return @npcs
		end	
	end

	def get_combatants
		self.synchronize do
			return @combatants
		end
	end

	def get_players(thread_id)
		self.synchronize do
			return @players[thread_id]
		end
	end

	def del_client(player)
		self.synchronize do
			p "del_client: sockets=#{@sockets.length}, players=#{@players.length}"
			@sockets.delete(player.thread_id)
			@players.delete(player.thread_id)
			p "/del_client: sockets=#{@sockets.length}, players=#{@players.length}"
			server_print "Client #{player.thread_id} left, still have #{@sockets.length} sockets."
		end
	end



	def get_socket(thread)
		sock = ''
		synchronize {
			sock = @sockets[thread]
		}
		return sock
	end

	def get_player2(sock)
		
		synchronize {
			thread = nil

			@sockets.each { |thread_id, socket|
				if(sock==socket)
					thread = thread_id
				end
			}

			@players.each { |thread_id, player| 
				if(thread==thread_id)
					return player, thread
				end
			}
		}
		return nil, nil
	end

	def prune_gone_humans(combatants)
		synchronize {
		p "prune start: combatants=#{combatants.length}, sockets=#{@sockets.length}, players=#{@players.length}"

			combatants.each_with_index { |comb, i|

				catch (:exists) do
					if(comb.human?)

						@players.each { |thread,player|
							if(player!=nil and player.character != nil and player.character.id == comb.id)
								p "still have #{comb.name} #{comb.id}"
								throw :exists
							end
						}

						p "deleting #{comb.name} =?= #{combatants[i].name}"
						combatants.delete_at(i)
					end
				end
			}
		p "/prune: combatants=#{combatants.length}, sockets=#{@sockets.length}, players=#{@players.length}"
		}
	end

	def players_left?
		self.synchronize do
			if(@players.length ==0) 
				return false
			end
			return true	
		end
	end

	def get_player(character)
		synchronize {
			@players.each_value { |player| 
				if(player.character == character)
					return player;
				end
			}
		}
		return nil
	end

	def print(key, vargs)
		synchronize {
			sock = get_socket(key)
			sock_puts(sock, vargs)
		}
	end

	def print_all(vargs)
		print_all_but(nil, vargs)
	end

	def print_all_but(player, vargs)

		exclude_socket = nil
		if(player and player.socket)
			exclude_socket = player.socket
		end

		synchronize {
			@sockets.each { | thread_id, socket | 

				if(socket != exclude_socket)
					if(thread_id.alive?)
						sock_puts(socket,vargs)
					end
				end
			}
		}
	end

	def mark_players(in_game)
		synchronize {
			@players.each_value { |player| player.in_game = in_game }
		}
	end

	def player_in_game?(thread_id)
	
		synchronize {
			if(thread_id==nil)
				server_print "player_in_game?: no thread"
				return false
			end

			player=nil

			@players.each { | _thread_id, _player |
				if(thread_id==_thread_id)
					player = _player
				end
			}

			if(player==nil)
				server_print "player_in_game?: no player for socket #{socket} with thread_id #{thread_id}"
				return false
			end

			if(player.in_game)
				server_print "player_in_game?: #{player} in game"
				return true
			end

			server_print "player_in_game?: player for socket #{socket} with thread_id #{thread_id}"
			server_print "player_in_game?: NOT #{player} in game"
			return false
		}
	end

	def gets_all_in_game()
		synchronize {
			@sockets.each{ | thread_id, socket | 

				if(thread_id.alive? and player_in_game?(thread_id))
					sock_gets(socket)
				end
			}
		}
	end

	def gets(key)
		synchronize {
			sock = get_socket(key)
			str = sock.gets
			return str
		}
	end

	def gets_any_in_game

		synchronize {
			socks = Array.new

			@sockets.each{ | thread_id, socket | 
				if(player_in_game?(thread_id))
					socks.push(socket) 
				end
			}

			if(socks.length<=0)
				server_print 'NO WRITERS'
				return
			else
				server_print "WRITERS = #{socks.length}"
			end

			loop {
				begin
					server_print 'SELECT'
					results = select ( socks ) # FIXME, can except?

					for sock in results[0]
						if results[0].include? sock
							sock_gets sock
							return
						end
					end
	
				rescue IOError => err
					p err
					server_print err
				end
			}
		}
	end


	def length
		len=0
		synchronize {
			return @sockets.length	
		}
	end
end


def server_cmd (*vargs)

	putc 'c'
	putc 'm'
	putc 'd'
	putc ':'
	putc ' '

	puts(vargs)
end

def server_print(*vargs)

	putc 's'
	putc 'e'
	putc 'r'
	putc 'v'
	putc 'e'
	putc 'r'
	putc '>'
	putc ' '

	puts(vargs)
end

def target_print(*vargs)
	#print(vargs)
end


def clear_screens (sock)

	clear = SCREEN_CLEAR + CURSOR_UP_LEFT

	if(sock==nil)
		$clients.print_all(clear)
	else
		sock_puts(sock, clear) # FIXME, no synch
	end

end

def print(*vargs)
	$clients.print_all(vargs)
	server_print(vargs) # server window
end


def server_get_cmd
	begin
		system("stty raw -echo")
		str = STDIN.getc

		if(str == 'q') then
		exit
		end


	ensure
		system("stty -raw echo")
	end
		p str.chr
end

#server_get_cmd

Thread.abort_on_exception = true


class Player
	attr_accessor :thread_id, :socket
	attr_accessor :character
	attr_accessor :in_game

	def initialize(thread_id, socket)
		@thread_id   = thread_id
		@socket      = socket
		@character   = nil
	end
	
	def remove()

		begin
			if(not @socket.closed?)
				sock_puts @socket, "bye"
				@socket.close
			end

			@socket = nil

		rescue Exception => e
			server_print 'Exception:' + e.to_s

			server_print e.message  
			server_print e.backtrace.inspect
		end

		$clients.del_client(self)

		return self

	end	

	def gets()
		return sock_gets(socket)
	end

	def puts_me(*vargs)
		sock_puts(socket, vargs)
	end

	def puts_others(*vargs)
		$clients.print_all_but(self, vargs)
	end

end
	
def prompt(sock, str)

	sock_putc(sock, "\r")

	str.each_byte do |c|
		sock_putc(sock,c)
	end

	sock_putc(sock, ' ')
	sock_putc(sock, '>')
	sock_putc(sock, ' ')

	response = sock_gets(sock)

	return response
end

def menu(player, ask_play_again)

	def _exit(player)

		_player = player.remove
		_player = nil

		Thread.current.exit
	end

	def _print_motd_1(player, ask_play_again)

		sock      = player.socket

		clear_screens sock
	
		i=0	
		File.open($motd).each_line{ |line_in_file|

			strMONSTER = COLOUR_RED_BLINK + 'MONSTER' + COLOUR_RESET

			line_in_file = line_in_file.gsub('MONSTER', strMONSTER)

			sock_puts sock, line_in_file 

			i+=1
		}

		sock_puts sock, COLOUR_YELLOW_BLINK + ' N' + COLOUR_RESET + ' = New character ' + COLOUR_BLUE_BLINK   + ' L' + COLOUR_RESET + ' = Load character'
		sock_puts sock, COLOUR_WHITE_BLINK  + ' S' + COLOUR_RESET + ' = Save character' + COLOUR_CYAN_BLINK   + ' T' + COLOUR_RESET + ' = Toggle screen'
		sock_puts sock, COLOUR_YELLOW_BLINK + ' V' + COLOUR_RESET + ' = View character' + COLOUR_GREEN_BLINK  + ' H' + COLOUR_RESET + ' = Heal character'
		sock_puts sock, COLOUR_RED_BLINK    + " Q" + COLOUR_RESET + ' = Quit          ' + COLOUR_GREEN_BLINK  + ' P' + COLOUR_RESET + ' = Play (start)'
		sock_puts sock, ' '
	end

	def _print_motd_2(player)

		sock      = player.socket

		clear_screens (sock)
	
		File.open($motd).each_line{ |line_in_file|

			strMONSTER = COLOUR_RED_BLINK + 'MONSTER' + COLOUR_RESET

			sock_puts sock, line_in_file 
		}

		sock_puts sock, COLOUR_YELLOW_BLINK + ' W' + COLOUR_RESET + ' = Wait for other players'
		sock_puts sock, COLOUR_RED_BLINK    + " F" + COLOUR_RESET + ' = Force start'
		sock_puts sock, COLOUR_BLUE_BLINK   + ' M' + COLOUR_RESET + ' = back to main Menu'

	end

	def _screen(size) # set(size), get(nil)
		if(size == nil)
			return 'large' if ($motd == 'motd.txt')
			return '72x13'
	 	elsif (size == 'large')
			$motd='motd.txt' 
		else
			$motd='motd_tight.txt'
		end
	end

	def _handle_cmd(player, ask_play_again)	

		sock = player.socket

		cmd = prompt(sock, 'cmd')


			case cmd[0]
				when 'n'
					name = prompt(sock, 'name')
					player.character= Character.new(name, 'pc', 'biological')
					return false, false
									
				when 'q'
					_exit(player)
				when 'l'
					name = prompt(sock, 'name')
					player.character = Character::load(name)
					if(player.character == nil)
						sock_puts sock, '?load error'
					else
						sock_puts sock, 'loaded.'
					end
					sleep(1)
					return false, false
				when 't'
					if(_screen(nil) == 'large')
						_screen('72x13')
					else
						_screen('large')
					end
					
					return false, false
				when 's'
					if(player.character and player.character.save)
						sock_puts sock, 'saved.'
					else
						sock_puts sock, '?save error'
					end
					sleep(1)
					return false, false
				when 'p'
					if(player.character == nil)
						sock_puts sock, '?no character'
						sleep(1)
						return false, false
					else
						return true, false
					end
				when 'v'
					return false, true
				when ''
					return false, false
				when 'h'
					player.character.heal(true)
					return false, false
				else
					sock_puts sock, 'Not implemented'
					return false, false
			end
	end

	def _handle_2nd_cmd(player)

		sock = player.socket

		cmd = prompt(sock, 'cmd')

		case cmd[0]
			when 'w'
				return true, true
			when 'f'
				$forced_start_fight = true
				return true, true
			when 'm'
				return false, false				
			else
				sock_puts sock, 'Not implemented'
				sleep(1)
				return false
		end
	end

	def _ready_to_break(bool)
			if(bool) 
				return true
			end 
	end

	show_player = false

	while true

		_print_motd_1(player, ask_play_again)

		if(show_player)
			player.socket.puts player.character.to_s
		end

		ready, show_player = _handle_cmd(player, ask_play_again)

		if(ready)
			_print_motd_2(player)
			bool, back_to_menu = _handle_2nd_cmd(player)
			
			if(back_to_menu)
				ready = false
			end
		end

		if(_ready_to_break(bool))
			break
		end
	end
end


def rename_pcs(pcs)

	pcs.each_with_index { |pc , i |

		if (pc.brains == 'artificial')
			case i
			
				when 0
					pc.name = 'Aramir the Invincible'
				when 1
					pc.name = 'Drendon the Old'
				when 2
					pc.name = 'Ezmu the Small'
				when 3
					pc.name = 'Bereth the Strong'
				else
					pc.name = "Beanel the #{i}th"
			end
		end
	}	
end

def rename_npcs(npcs)

	surname = ' the Orc'

	npcs.each_with_index { |npc , i |


		case i
		
			when 0
				npc.name = 'Gurlar'   + surname
			when 1
				npc.name = 'Bronthor' + surname
			when 2
				npc.name = 'Visnasch' + surname
			when 3
				npc.name = 'Hugnarl'  +  surname
			else
				npc.name = 'Unknown'  + i.to_s + surname
		end
	}	
end


def init_round(pcs, npcs, combatants)

	while (pcs.length<5) 
		pcs.push(Character.new('dummy', 'pc', 'artificial'))
	end

	rename_pcs(pcs)

	pcs.each { |pc| npcs.push(Character.new('dummy', 'npc', 'artificial')) }
	
	rename_npcs(npcs)

	pcs.each  { |pc|  combatants.push(pc)  }
	npcs.each { |npc| combatants.push(npc) }

	clear_screens(nil)
	print "NEW FIGHT!"
	print "\nHIT ENTER TO BEGIN"
	$clients.gets_all_in_game
	clear_screens(nil)
end

def fight_all_rounds(pcs,npcs,combatants)


	def _draw_subround(active_xpc, rnd, combatants, sub_round_number)

		clear_screens(nil)
		top_bar = "==================---/--- Round: #" + rnd.to_s + " (" + sub_round_number.to_s + "/" + combatants.length.to_s + ") ===========================\n"
		#top_bar = "123456789_123456789_123456789_123456789_123456789_123456789_123456789_\n"
		print top_bar

		idx_longest_name = combatants.each_with_index.inject(0) { | max_i, (combatant, idx) | combatant.name.length > combatants[max_i].name.length ? idx : max_i }

		names_width = combatants[idx_longest_name].name.length

		 combatants.sort! do |a,b|
			 result = b.party      <=> a.party
			 result = a.initiative <=> b.initiative if result == 0 
			 result
		 end

		combatants.each_with_index { | xpc,i |

			str = ''
			server_str = ''

			if(i >= (combatants.length/2)) # print npc:s in 2nd column
				set_pos_x_y = "\033[" + (3+i-(combatants.length/2)).to_s + ';' + '36' + 'H'
				str += set_pos_x_y
			end


			name = xpc.name

			if(name == active_xpc.name)
				if(xpc.can_attack_now[0])
					name = COLOUR_GREEN + COLOUR_REVERSE + name + COLOUR_RESET
				else
					name = COLOUR_RED   + COLOUR_REVERSE + name + COLOUR_RESET
				end
			else
				if(xpc.dead)
					name = COLOUR_RED    + name + COLOUR_RESET
				elsif(xpc.unconscious)	
					name = COLOUR_BLUE   + name + COLOUR_RESET
				elsif(xpc.prone>0 or xpc.downed>0 or xpc.stun>0)
					name = COLOUR_YELLOW + name + COLOUR_RESET
				elsif(xpc.current_hp/2 > xpc.hp)
					name = COLOUR_GREEN  + name + COLOUR_RESET
				end
			end

			str        += name
			server_str += name

			if(i < (combatants.length/2))
				set_pos_y = "\033[" + '20' + 'G'
				str += set_pos_y
			else
				set_pos_y = "\033[" + (36+20).to_s + 'G'
				str += set_pos_y
			end

			curr_hp = xpc.current_hp.to_s
			while(curr_hp.length<3)
				curr_hp = ' ' + curr_hp
			end

			str += curr_hp.to_s
			server_str += curr_hp.to_s
			str += '/'
			server_str += '/'

			hp = xpc.hp.to_s
			while(hp.length<3)
				hp += ' '
			end

			str += hp.to_s
			server_str += hp.to_s

			#set_pos_x = "\033[" + (10).to_s + 'C'
			#str += set_pos_x

			str += ' '
			str += 'u' if (xpc.unconscious)
			str += 'D' if (xpc.dead)
			str += 's' + xpc.stun.to_s       if (xpc.stun>0)
			str += 'd' + xpc.downed.to_s  	  if (xpc.downed>0)
			str += 'p' + xpc.prone.to_s      if (xpc.prone>0)
			str += 'b' + xpc.bleeding.to_s   if (xpc.bleeding>0)

			server_str += ' '
			server_str += 'u' if (xpc.unconscious)
			server_str += 'D' if (xpc.dead)
			server_str += 's' + xpc.stun.to_s       if (xpc.stun>0)
			server_str += 'd' + xpc.downed.to_s  	  if (xpc.downed>0)
			server_str += 'p' + xpc.prone.to_s      if (xpc.prone>0)
			server_str += 'b' + xpc.bleeding.to_s   if (xpc.bleeding>0)

			$clients.print_all str

			server_print server_str
		}

		print "\n"

	end

	def _pcs_left(pcs)

		pcs.each { |pc|
			if(pc.current_hp>0 and pc.dead==false and pc.unconscious==false)
				return true
			end
		}
		return false
	end

	def _npcs_left(npcs)

		res = false

		npcs.each { |npc|
			#p npc.name + ' ' + npc.current_hp.to_s + ' ' + npc.dead.to_s + ' ' + npc.unconscious.to_s + ' '
			if(npc.current_hp>0 and npc.dead==false and npc.unconscious==false)
				res = true
			end
		}

		#p res.to_s
		
		return res

	end

	def _opponents_left(xpc, opponents)
		if(xpc.human?)
			return _npcs_left(opponents)
		else
			return _pcs_left(opponents)
		end

	end

	def _sub_round(actor, round, combatants, friends, enemies, sub_round_number)

		_draw_subround(actor, round, combatants, sub_round_number)

		if(_opponents_left(actor, enemies))
			sub_round(actor, enemies)
		end
	end

	# fight_all_rounds

	i=0
	catch (:done) do
		while true
				server_print '<<<NEW ROUND>>>'
				server_print '<<<NEW ROUND>>>'
				server_print '<<<NEW ROUND>>>'
				i=i+1

				sub_round_number=1

				combatants_in_action_order = combatants.sort { |a,b| a.initiative <=> b.initiative }

				combatants_in_action_order.each { |actor|
					enemies = actor.party == 'pc' ? npcs : pcs
					friends = actor.party == 'pc' ? pcs : npcs

					begin
						server_print '<<<NEW SUB ROUND>>>'
						server_print '<<<NEW SUB ROUND>>>'
						server_print '<<<NEW SUB ROUND>>>'
						_sub_round(actor, i, combatants, friends, enemies, sub_round_number)
					rescue Exception => e
			
						server_print '<<<SUB ROUND ERR HANDLER>>>'
						server_print '<<<SUB ROUND ERR HANDLER>>>'
						server_print '<<<SUB ROUND ERR HANDLER>>>'
						server_print "#{e}"
						server_print e.message  
						server_print e.backtrace.inspect

						$clients.kick_player_threads('broken')
						Thread.stop

						$clients.prune_gone_humans(combatants)
						$clients.prune_gone_humans(combatants_in_action_order)
					end

					$clients.gets_any_in_game

					sub_round_number += 1

					if(not $clients.players_left?)
						print "All players have left the game!\n"
						throw :done
					end

					if(not _pcs_left(pcs))
						print "NPCs won!\n"
						throw :done
					end

					if(not _npcs_left(npcs))
						print "PCs won!\n"
						throw :done
					end
				}

				clear_screens(nil)
		end
	end

	$clients.gets_all_in_game
	clear_screens(nil)
	print(combatants_to_s(combatants))
	$clients.gets_all_in_game

end

$forced_start_fight = false
$clients            = Clients.new

def cmd_threads
	p Thread.list

	names = Array.new
	ids   = Array.new

	Thread.list.each { |thread_id|
		$threads.each { |name, _thread_id|
			if(thread_id==_thread_id)
				names.push(name)
				ids.push(thread_id)
			end
		}
	}

	p names
	p ids


end

def cmd_sockets
	$clients.dump_sockets

end

def dump
	cmd_threads
	cmd_sockets
	
end
def handle_server_commands(clients, pcs, npcs, combatants, server)


	cmd = "\n"
	while cmd == "\n"
		cmd = gets
	end

	server_cmd cmd

		case cmd[0]
			when 'P'
				p $clients
			when 'p'
				for pc  in pcs  do p pc  end
			when 'n'
				for npc in npcs do p npc end
			when 'l'
				server_print \
					"\n\tclients="    + "#{clients.length}"    + 
					"\n\tpcs="        + "#{pcs.length}"        +
					"\n\tnpcs="       + "#{npcs.length}"       +
					"\n\tcombatants=" + "#{combatants.length}"
			when 't'
				cmd_threads
			when 's'
				cmd_sockets
			when 'Z'
				dump

			when 'Q'
				shutdown(server, 'operator manual shutdown from server console')
		end
end

def shutdown(server, cause)
	print 'Server exiting, cause = ' + cause.to_s 
	server = nil
	exit
end


def main

	def _exception_handler(server)

		loop {
			begin
				server_loop(server)

			rescue IOError => e

				puts 'IOError:' + e.to_s

				puts e.message  
				puts e.backtrace.inspect

			rescue Exception => e  
		
				puts 'Exception:' + e.to_s

				puts e.message  
				puts e.backtrace.inspect

				if(e.to_s == 'exit') 
					print '<<<exit>>>'
					exit
				end

			rescue
				print 'catch all rescue'	

			end

		}

	end

	server      = TCPServer.open(20015)

	Signal.trap("INT") do
		shutdown(server, "manual shutdown")
	end

	_exception_handler(server)
end


def server_loop(server)


	Thread.start() do
		$threads['server_cmd_thread'] = Thread.current
		loop {
			handle_server_commands($clients, $clients.get_pcs, $clients.get_npcs, $clients.get_combatants, server)
		}
	end

	def _fight_cleanup

		server_print '_fight_cleanup !'

		$clients.fight_cleanup

		$clients.kick_player_threads('all')
	end

	Thread.start() do

		$threads['fight_thread'] = Thread.current

		loop { # one iteration is one fight

			if($forced_start_fight and $clients.length>0)

				server_print "<<<FIGHT THREAD IN GAME >>>"
				server_print "<<<FIGHT THREAD IN GAME >>>"
				server_print "<<<FIGHT THREAD IN GAME >>>"


				$forced_start_fight = false

				$clients.mark_players(true)

				init_round($clients.get_pcs, $clients.get_npcs, $clients.get_combatants)

				begin
					fight_all_rounds($clients.get_pcs ,$clients.get_npcs, $clients.get_combatants)
				rescue Exception => e
						server_print "<<<FIGHT THREAD ERR HANDLER >>>\nException: #{e}\n"
						server_print "<<<FIGHT THREAD ERR HANDLER >>>\nException: #{e}\n"
						server_print "<<<FIGHT THREAD ERR HANDLER >>>\nException: #{e}\n"

						server_print e.message  
						server_print e.backtrace.inspect
				ensure
					_fight_cleanup
					$clients.mark_players(false)
				end

				server_print "<<<FIGHT THREAD GAME OVER >>>"
				server_print "<<<FIGHT THREAD GAME OVER >>>"
				server_print "<<<FIGHT THREAD GAME OVER >>>"
			end

			Thread.stop
			server_print(',')

		}
	end

	ii=-1
	player_lock = Monitor.new 
	loop { # accept new players                       

		ii+=1
		Thread.start(server.accept, player_lock ) do | sock, player_lock |


			begin


					$threads["player#{ii}"] = Thread.current
					player = ''
					ask_play_again = false

					player = Player.new(Thread.current, sock)

					$clients.add_client(player)

					server_print $clients.get_socket(Thread.current)


					loop {

						menu(player, ask_play_again)

						$clients.pcs_push(player.character)

						player.puts_me('Waiting for fight to start..')
			
						ask_play_again = true

						server_print "<<<PLAYER #{ii} THREAD STOP >>>"

						$threads['fight_thread'].run

						Thread.stop

					}


			rescue Exception => e


					server_print "<<<PLAYER #{ii} THREAD ERR HANDLER >>>\nException: #{e}\n"
					server_print "<<<PLAYER THREAD ERR HANDLER >>>\nException: #{e}\n"
					server_print "<<<PLAYER THREAD ERR HANDLER >>>\nException: #{e}\n"

					server_print e.message  
					server_print e.backtrace.inspect

					$clients.print_all_but(player, "#{player.character.name} bids you farewall...")

					player = $clients.get_players(Thread.current)
					_player = player.remove
					_player = nil

					$threads['fight_thread'].run

					server_print "<<<PLAYER #{ii} THREAD EXIT >>>"
					server_print "<<<PLAYER THREAD EXIT >>>"
					server_print "<<<PLAYER THREAD EXIT >>>"
				end

			end

			server_print "Thread #{Thread.current} ran out!"

		server_print('.')

	}

	

end

main



