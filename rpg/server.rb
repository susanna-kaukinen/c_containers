#!/home/susanna/.rvm/rubies/ruby-1.9.3-p0/bin/ruby

#require 'io'
require 'socket'
require 'monitor'
require 'rubygems'
require 'json'
require 'yaml'
#
# TODO: severed, crushed, bruised, miinukset: e.g. char at -10%, blind toteuttamatta (-100)
#


# HTC Desire Z AndroMud screen props: height: 13 lines, width: 72
# 1234567890123456789012345678901234567890123456789012345678901234567890
# ========================= Round: #2 (1/4) ============================

# ==<COLOURS>===

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
CURSOR_UP         = "\033[0;0H";
CURSOR_BACK       = "\033[1D";
CURSOR_NEXT_LINE  = "\033[1E";

def cprint(*vargs)
	vargs.each { |param| print param }
 	print COLOUR_RESET
end

# ==</COLOURS>===


$tight=true # h=13, w=72 screen

if($tight)
	$motd='motd_tight.txt'
else
	$motd='motd.txt'
end


def count(what)
	case
		when "hp"
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

	
		_roll = roll(nil, nil)[1] 


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

	def deal_damage(result, defender)
		hp_damage, critical = damage_table(result)

		defender.current_hp -= hp_damage

		if(hp_damage>0)
			print "\t" + name + " deals " + COLOUR_RED + hp_damage.to_s() + COLOUR_RESET + " hit points of damage.\n"
		else
			if(rand(2)==1)
				evade = "dodges"
			else
				evade = "blocks"
			end
			print defender.name + " " + evade + " the attack\n"
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
			defender.unconscious = true
			cprint COLOUR_YELLOW_BLINK + defender.name + " falls unconscious.\n"
		end

		if(defender.current_hp < -defender.hp or defender.dead == true)
			defender.dead = true
			cprint COLOUR_RED_BLINK + defender.name + " is DEAD!\n"
		end

	end

end

class Character

	# base, or so
	attr_accessor :full_name, :name, :party, :brains
	attr_accessor :ob, :db, :ac, :hp

	# current/active
	attr_accessor :stun, :bleeding, :uparry, :downed, :prone, :blind
	attr_accessor :unconscious, :unconscious_why
	attr_accessor :dead, :dead_why
	attr_accessor :current_db, :active_weapon, :current_hp
	attr_accessor :personality
	attr_accessor :can_attack, :cant_attack_text, :cant_attack_reasons
	attr_accessor :wounds

	def get_personality
		personality = rand(3)

		case personality
			when 0 ; return 'smart'
			when 1 ; return 'evil'
			when 2 ; return 'stupid'
		end
	end

	def heal
		@stun = 0
		@bleeding = 0
		@uparry = 0
		@downed = 0
		@prone  = 0
		@blind  = 0

		@unconscious     = false
		@unconscious_why = ''

		@dead	     = false
		@dead_why    = ''
		
		@current_hp    = @hp
		@active_weapon = Weapon.new("sword")
		@current_db    = @db # at this point

		@can_attack = true
		@cant_attack_text    = 'no reason'
		@cant_attack_reasons = Hash.new

		@wounds = []
	end

	def initialize(name, party, brains)
		@full_name = name
		@name	= name[0..17] # andromud screen
		@party  = party
		@brains = brains
		@ob	= count("ob")
		@db	= count("db")
		@ac	= count("ac")
		@hp	= count("hp")

		@personality = get_personality
		heal
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
			print "\n" + COLOUR_RED + COLOUR_REVERSE + @name + ' loses ' + @bleeding.to_s() + ' hits due to bleeding!' + "\n\n" + COLOUR_RESET
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

		def _add_reason (value, text)

			if(text.length>0)
				@cant_attack_text += " and " + text
			else
				@cant_attack_text = text
			end

			p text + value.to_s

			@cant_attack_reasons[text] = value

			p @cant_attack_reasons
		
			@can_attack = false
		end

		@can_attack = true
		@cant_attack_text = ''

		if(@stun > 0)
			_add_reason @stun, "stunned"
			
			if(@uparry > 0)
				 _add_reason @uparry, "unable to parry"
			end
		end

  		_add_reason @downed, "downed" if @downed>0
		_add_reason @prone,  "prone"  if @prone>0

		check_hitpoints

		_add_reason @unconscious ,"unconscious"  if (@unconscious == true)
		_add_reason @dead        ,"dead"         if (@dead        == true)

		return @can_attack, @cant_attack_reasons, @cant_attack_text

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

def roll(weapon, attacker)

	critical_roll = false
	if(weapon==nil and attacker==nil)
		critical_roll = true
	end

	first_roll=0
	result=0
	while true
		first_roll = roll = 1 + rand(100)

		if(weapon and result==0 and roll<weapon.fumble) then
			print result.to_s() + " => FUMBLE\n"
			if(attacker != nil) then
				print attacker.name + " deals himself a blow:\n"
				attack(attacker, attacker, 'fumblingly')
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

def attack(attacker, opponent, manner)

	if(opponent==nil)
		print "No-one to attack!"
		return
	end

	print COLOUR_GREEN + COLOUR_REVERSE + attacker.name + COLOUR_RESET + " ATTACKS " + COLOUR_RED + COLOUR_REVERSE + opponent.name + COLOUR_RESET +  " with " + attacker.active_weapon.name + " in a " + manner + " manner..\n"

	__roll  = roll(attacker.active_weapon, attacker)
	_roll   = __roll[0]
	fumble  = __roll[2]

	if(fumble==true)
		return
	end 

	result = attacker.ob - opponent.current_db + _roll

	print  " => result:" + result.to_s() + "\n"

	attacker.active_weapon.deal_damage(result, opponent)
end

def choose_opponent(att, opponents)

	opps = opponents.clone
	choice=''

	if(att.personality == 'evil')

		choice = 'weakest'

		opps.each_with_index { |opp,i|
			if (opp.dead)
				#p opps[i]
				opps.delete_at(i)
			end
		}
	else
		opps.each_with_index { |opp,i|
			if (opp.current_hp<=0 or opp.dead or opp.unconscious)
				#p opps[i]
				opps.delete_at(i)
			end
		}

		if(att.personality == 'smart')
			choice = 'weakest'
		else
			choice = 'strongest'
		end

	end

	case choice
		when 'weakest'
			idx_weakest_opp = opps.each_with_index.inject(0) { |min_i, (opp, idx) |
				if (opp.current_hp < opps[min_i].current_hp)
					idx
				else
					min_i
				end
			}
			opp = opps[idx_weakest_opp]

		when 'strongest'
			idx_weakest_opp = opps.each_with_index.inject(0) { |max_i, (opp, idx) |
				if (opp.current_hp > opps[max_i].current_hp)
					idx
				else
					max_i
				end
				
			}
			opp = opps[idx_weakest_opp]


	end

	return opp, att.personality

end




def actions(character, opponents)

	character.do_bleed
	character.recover_from_wounds

	can_attack, why, text = character.can_attack_now()

	if(can_attack)
		opponent, manner = choose_opponent(character, opponents)
		attack(character, opponent, manner)
		opponent.apply_wound_effects_after_attack
	else
		str = COLOUR_WHITE + COLOUR_REVERSE + character.name + COLOUR_RESET + " cannot attack, reason: "

		if (why.has_key?('dead') and why['dead'])
			str += COLOUR_RED + COLOUR_REVERSE + "DEAD" + COLOUR_RESET
			print str
			p str
			return
		end

		if (why.has_key?('unconscious') and why['unconscious']) 
			str += COLOUR_RED + "unconscious" + COLOUR_RESET
			print str
			p str
			return
		end

		if (why.has_key?('prone') and why['prone'] > 0) 
			str += COLOUR_YELLOW + COLOUR_REVERSE + "prone" + COLOUR_RESET
			print str
			p str
			return
		end

		if (why.has_key?('downed') and why['downed'] > 0)
			str += COLOUR_YELLOW_BLINK + "downed" + COLOUR_RESET
			print str
			p str
			return
		end

		if (why.has_key?('stunned') and why['stunned'] > 0)
			str += COLOUR_YELLOW + "stunned" + COLOUR_RESET
			print str
			p str
			return
		end
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
	begin
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
			return data.strip!
		else
			throw :no_op
		end
	rescue Exception => e

		server_print 'Exception:' + e.to_s

		server_print e.message  
		server_print e.backtrace.inspect
		
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

	attr_accessor :clients

	def initialize(*args)
		super(*args)

		@clients = Hash.new
	end

	def add_client(player)
		self.synchronize do
			clients[player.thread_id] = player.socket
		end
	end

	def del_client(player)
		self.synchronize do
			clients.delete(player.thread_id)
		end
	end

	def getSocket(key)
		sock = ''
		synchronize {
			sock = clients[key]
		}
		return sock
	end

	def print(key, vargs)
		synchronize {
			sock = getSocket(key)
			sock_puts(sock, vargs)
		}
	end

	def print_all(vargs)
		synchronize {
			clients.each{ | thread_id, socket | 
				if(thread_id.alive?)
					sock_puts(socket,vargs)

				end
			}
		}
	end

	def gets_all()
		synchronize {
			clients.each{ | thread_id, socket | 

				msg = ''

				if(thread_id.alive?)
					msg = socket.gets
				end
			}
		}
	end

	def gets(key)
		synchronize {
			sock = getSocket(key)
			str = sock.gets
			return str
		}
	end

	def gets_any

		synchronize {
			sockets = Array.new
			clients.each{ | thread_id, socket | sockets.push(socket) }

			loop {
				begin
					results = select ( sockets ) # FIXME, can except?

					for sock in results[0]
						if results[0].include? sock
							sock.gets
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
			len = clients.length	
		}
		return len
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
	attr_accessor :character
	attr_accessor :thread_id, :socket
	attr_accessor :character
	attr_accessor :players

	def initialize(players, thread_id, socket)
		@thread_id   = thread_id
		@socket      = socket
		@character   = nil

		players.push(self)
		@players = players
	end
	
	def remove()

		self.socket.puts 'bye'
		self.socket.close

		players.each_with_index { |player,i|
			if(player.thread_id = @thread_id)
				players.delete_at(i)
			end
		}

		$clients.del_client(self)

		return self

	end	

	def write(*vargs)
		vargs.each { |param|
			if(vargs.is_a? String)
				socket.puts(param)
			else
				socket.puts(param.to_s)
			end
		}
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

def menu(monitor, player, ask_play_again)

	def _exit(player)

		_player = player.remove
		_player = nil

		Thread.current.exit
	end

	def _print_motd_1(player, ask_play_again)

		sock      = player.socket

		sock_puts sock,(SCREEN_CLEAR + CURSOR_UP)
	
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

		sock_puts sock,(SCREEN_CLEAR + CURSOR_UP)
	
		File.open($motd).each_line{ |line_in_file|

			strMONSTER = COLOUR_RED_BLINK + 'MONSTER' + COLOUR_RESET

			sock_puts sock, line_in_file 
		}

		sock_puts sock, COLOUR_YELLOW_BLINK + ' W' + COLOUR_RESET + ' = Wait for other players'
		sock_puts sock, COLOUR_RED_BLINK + " F" + COLOUR_RESET + ' = Force start'

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

	def _handle_cmd(monitor, player, ask_play_again)	

		sock = player.socket

		cmd = prompt(sock, 'cmd')

		monitor.synchronize {

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
					return true, false
				when 'v'
					return false, true
				when ''
					return false, false
				when 'h'
					player.character.heal
					return false, false
				else
					sock_puts sock, 'Not implemented'
					sleep(1)
					return false, false
			end
		}
	end

	def _handle_2nd_cmd(monitor, player)

		sock = player.socket

		cmd = prompt(sock, 'cmd')

		monitor.synchronize {

			case cmd[0]
				when 'w'
					return true
				when 'f'
					$forced_start_fight = true
					return true
				else
					sock_puts sock, 'Not implemented'
					sleep(1)
					return false, false
			end
		}
	end

	def _ready_to_break(monitor, bool)
		monitor.synchronize { 
			if(bool) 
				return true
			end 
		}
	end

	show_player = false

	while true

		monitor.synchronize {
			_print_motd_1(player, ask_play_again)

			if(show_player)
				player.socket.puts player.character.to_s
			end
		}

		ready, show_player = _handle_cmd(monitor, player, ask_play_again)

		if(ready)
			monitor.synchronize { _print_motd_2(player) }
			bool = _handle_2nd_cmd(monitor, player)
		end

		if(_ready_to_break(monitor, bool))
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
					pc.name = 'Unknown'  + i.to_s + surname
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

def pcs_left(pcs)

	pcs.each { |pc|
		if(pc.current_hp>0 and pc.dead==false and pc.unconscious==false)
			return true
		end
	}
	return false
end

def npcs_left(npcs)

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

def init_round(pcs, npcs, combatants)

	while (pcs.length<2) 
		pcs.push(Character.new('dummy', 'pc', 'artificial'))
	end

	rename_pcs(pcs)

	pcs.each { |pc| npcs.push(Character.new('dummy', 'npc', 'artificial')) }
	
	rename_npcs(npcs)

	pcs.each  { |pc|  combatants.push(pc)  }
	npcs.each { |npc| combatants.push(npc) }

	print(SCREEN_CLEAR + CURSOR_UP + "NEW FIGHT!")
	print(combatants_to_s(combatants) + "\nHIT ENTER TO BEGIN" )
	$clients.gets_all
	print(SCREEN_CLEAR + CURSOR_UP)
end

def fight_all_rounds(monitor, pcs,npcs,combatants)

	def _draw_subround(active_xpc, rnd, combatants, sub_round)

		print SCREEN_CLEAR + CURSOR_UP
		top_bar = "==================---/--- Round: #" + rnd.to_s + " (" + sub_round.to_s + "/" + combatants.length.to_s + ") ===========================\n"
		#top_bar = "123456789_123456789_123456789_123456789_123456789_123456789_123456789_\n"
		print top_bar

		idx_longest_name = combatants.each_with_index.inject(0) { | max_i, (combatant, idx) | combatant.name.length > combatants[max_i].name.length ? idx : max_i }

		names_width = combatants[idx_longest_name].name.length

		combatants.each_with_index { | xpc,i |

			str = ''

			if(i >= (combatants.length/2)) # print npc:s in 2nd column
				set_pos_x_y = "\033[" + (3+i-(combatants.length/2)).to_s + ';' + '36' + 'H'
				str += set_pos_x_y
			end


			name = xpc.name

			if(name == active_xpc.name)
				if(xpc.can_attack_now[0])
					name = COLOUR_GREEN_BLINK + name + COLOUR_RESET
				else
					name = COLOUR_RED_BLINK   + name + COLOUR_RESET
				end
			end

			str += name

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
			str += '/'

			hp = xpc.hp.to_s
			while(hp.length<3)
				hp += ' '
			end

			str += hp.to_s

			#set_pos_x = "\033[" + (10).to_s + 'C'
			#str += set_pos_x

			str += ' '
			str += 'u' if (xpc.unconscious)
			str += 'D' if (xpc.dead)
			str += 's' + xpc.stun.to_s       if (xpc.stun>0)
			str += 'd' + xpc.downed.to_s  	  if (xpc.downed>0)
			str += 'p' + xpc.prone.to_s      if (xpc.prone>0)
			str += 'b' + xpc.bleeding.to_s   if (xpc.bleeding>0)

			print str
		}

		print "\n\n"

	end

	def _act(actor, round, combatants, opponents, sub_round)
		_draw_subround(actor, round, combatants, sub_round)

		if(npcs_left(opponents))
			actions(actor, opponents)
		end

		$clients.gets_any

	end

	i=0
	catch (:done) do
		while true
			monitor.synchronize {
				i=i+1

				players_left = false
				enemies_left = false

				sub_round=1

				pcs.each  { | actor | 
					_act(actor, i, combatants, npcs, sub_round)
					sub_round += 1
				}

				npcs.each { | actor |
					_act(actor, i, combatants, pcs, sub_round)
					sub_round += 1
				}

				#print "enemies left:" + enemies_left.to_s() + ", players left: " + players_left.to_s() + "\n"

				if(not pcs_left(pcs))
					print "NPCs won!\n"
					throw :done
				end

				if(not npcs_left(npcs))
					print "PCs won!\n"
					throw :done
				end

				#$clients.gets_all
				#sleep(0.5)

				print SCREEN_CLEAR + CURSOR_UP
			}
		end
	end

	monitor.synchronize {
		$clients.gets_all
		print SCREEN_CLEAR + CURSOR_UP
		print(combatants_to_s(combatants))
		$clients.gets_all
	}

end

$forced_start_fight = false
$clients            = Clients.new

def server_loop(server)

	def _handle_server_commands(players, pcs, npcs, combatants, monitor, server)

		def _cmd_threads
			p Thread.list
		end
	
		def _cmd_sockets(players)
			for player in players
				p player.socket
			end
		end

		cmd = "\n"
		while cmd == "\n"
			cmd = gets
		end
	
		server_cmd cmd

			case cmd[0]
				when 'P'
					p players
				when 'p'
					for pc  in pcs  do p pc  end
				when 'n'
					for npc in npcs do p npc end
				when 'l'
					server_print \
						"\n\tplayers="    + "#{players.length}"    + 
						"\n\tpcs="        + "#{pcs.length}"        +
						"\n\tnpcs="       + "#{npcs.length}"       +
						"\n\tcombatants=" + "#{combatants.length}"
				when 't'
					_cmd_threads
				when 's'
					_cmd_sockets(players)
				when 'Q'
					shutdown(server, 'operator manual shutdown from server console')
			end
	end

	players     = Array.new
	pcs         = Array.new
	npcs        = Array.new
	combatants  = Array.new
	monitor     = Monitor.new


	fight_thread = ''

	Thread.start() do
		loop {
			_handle_server_commands(players, pcs, npcs, combatants, monitor, server)
		}
	end

	Thread.start() do

		fight_thread = Thread.current

		loop { # one iteration is one fight

			Thread.stop

			if($forced_start_fight and players.length>0)

				monitor.synchronize {
					$forced_start_fight = false
					init_round(pcs, npcs, combatants)
				}

				fight_all_rounds(monitor, pcs,npcs,combatants)

				monitor.synchronize { # cleanup
					pcs        = Array.new
					npcs       = Array.new
					combatants = Array.new
				}
			end

			monitor.synchronize {
				players.each { |p| 
					if(p.thread_id.alive?)
						p.thread_id.run
					else
						server_warn 'Emergency cleaunp, thread was dead - removed player'
						p.remove
						p = nil
					end
				}
			}

		}
	end

	loop { # accept new players                       

		Thread.start(server.accept) do | sock |

			player = ''
			ask_play_again = false

			monitor.synchronize {

				player = Player.new(players, Thread.current, sock)

				$clients.add_client(player)

				server_print $clients.getSocket(player.thread_id)


			}

			loop {

				menu(monitor, player, ask_play_again)

				monitor.synchronize {
					pcs.push(player.character)

					player.write('Waiting for fight to start..')
	
					ask_play_again = true
				}
				fight_thread.run

				Thread.stop
			}
		end
	}

	

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

				print 'IOError:' + e.to_s

				puts e.message  
				puts e.backtrace.inspect

			rescue Exception => e  
		
				print 'Exception:' + e.to_s

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

	server      = TCPServer.open(20025)

	Signal.trap("INT") do
		shutdown(server, "manual shutdown")
	end

	_exception_handler(server)
end

main



