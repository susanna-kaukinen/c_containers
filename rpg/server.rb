#!/home/susanna/.rvm/rubies/ruby-1.9.3-p0/bin/ruby

require 'socket'                # Get sockets from stdlib
require 'monitor'
require 'rubygems'
require 'json'
#
# TODO: severed, crushed, bruised, miinukset: e.g. char at -10%, blind toteuttamatta (-100)
#


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

def cprint(*vargs)
	vargs.each { |param| print param }
 	print COLOUR_RESET
end

# ==</COLOURS>===


	

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
	attr_accessor :damage, :stun, :bleeding, :uparry, :downed, :prone, :unconscious, :dead	
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
		
 		print defender.name + " has " + colour + defender.current_hp.to_s() + COLOUR_RESET + " hit points left\n"

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
	attr_accessor :name
	attr_accessor :ob, :db, :ac, :hp

	# current/active
	attr_accessor :stun, :bleeding, :uparry, :downed, :prone, :blind
	attr_accessor :unconscious, :dead
	attr_accessor :current_db, :active_weapon, :current_hp
	attr_accessor :wounds
	attr_accessor :personality
	attr_accessor :cant_attack_reason

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

		@unconscious = false
		@dead	     = false
		
		@current_hp    = @hp
		@active_weapon = Weapon.new("sword")
		@current_db     = @db # at this point

		@wounds = []
	end

	def initialize(name)
		@name	= name
		@ob	= count("ob")
		@db	= count("db")
		@ac	= count("ac")
		@hp	= count("hp")

		@personality = get_personality
		@cant_attack_reason = 'no reason'

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

	def apply_wounds_effects_round_start

		if(@bleeding > 0)
			cprint COLOUR_RED + COLOUR_REVERSE + @name + ' loses ' + @bleeding.to_s() + ' hits due to bleeding!' + "\n\n" ### FIXME
			@current_hp -= @bleeding
		end
	end


	def apply_wound_effects_after_attack

		@current_db = @db

	# FIXME: can char be downed and prone?
	# FIXME: if char suffers one prone and one downed, should they take a total of 1 or 2 rounds to recover from?
		if(@stun>0)

			@stun -= 1
			@current_db -= 20
			
			if(@uparry > 0)
				@uparry -= 1
			end
		end

		if(@downed>0)
			@downed -= 1
			@current_db -= 30
		end

		if(@prone>0)
			@prone -= 1
			@current_db -= 50
		end

		if(@current_hp<0)
			if((@hp + @current_hp) <0)
				@dead = true
			else
				@unconscious = true
			end
		end

		if(@unconscious or @dead)
			@current_db -= 100
		end

	end


	def can_attack() # i.e. can this character attack now

		can_attack = true
		@cant_attack_reason = ''

		def _add_reason(reason)

			if(reason.length>0)
				@cant_attack_reason += " and " + reason
			else
				@cant_attack_reason = reason
			end
		
			can_attack = false
		end

		if(@stun > 0)
			_add_reason("stunned")
			
			if(@uparry > 0)
				 _add_reason "unable to parry"
			end
		end

  		_add_reason "downed"       if @downed>0
		_add_reason "prone"        if @prone>0
		_add_reason "unconscious"  if (@unconscious == true)
		_add_reason "dead"         if (@dead        == true)

		if(@current_hp<0)

			if((@hp + @current_hp) <0)
				_add_reason "dead due to excessive hp dmage"
			else
				_add_reason "unconscious due to excessive hp dmage"
			end
		end

		return can_attack, @cant_attack_reason

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

	print attacker.name + " ATTACKS " + opponent.name + " with " + attacker.active_weapon.name + " in a " + manner + " manner..\n"

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

	if(character.can_attack())
		opponent, manner = choose_opponent(character, opponents)
		attack(character, opponent, manner)
		opponent.apply_wound_effects_after_attack
	else
		print COLOUR_BLUE + character.name + " cannot attack, reason: " + character.cant_attack_reason + "\n" + COLOUR_RESET
	end

	print "\n"
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

class Clients

	include MonitorMixin

	attr_accessor :clients

	def initialize(*args)
		super(*args)

		@clients = Hash.new
	end

	def addClient(player)
		self.synchronize do
			clients[player.thread_id] = player.socket
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
			sock.puts(vargs)
		}
	end

	def print_all(vargs)
		synchronize {
			clients.each{ | thread_id, socket | 
				if(thread_id.alive?)
					socket.puts(vargs) 
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

	def length
		len=0
		synchronize {
			len = clients.length	
		}
		return len
	end
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

		players.each_with_index { |player,i|
			if(player.thread_id = @thread_id)
				players.delete_at(i)
			end
		}

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

	str.each_byte do |c|
		sock.putc c
	end

	sock.putc ' '
	sock.putc '>'
	sock.putc ' '

	response = sock.gets

	return response.strip!
end

def pre_menu(sock)

	i=0
	File.open('motd.txt').each_line{ |line_in_file|

		if(i>=15)
			sock.puts line_in_file 
		end
	}
end

def menu(monitor, player, ask_play_again)

	def _exit(player)
		begin
			player.socket.puts 'bye'
			player.socket.close
		rescue
		end

		_player = player.remove
		_player = nil

		Thread.current.exit
	end

	def _print_motd_1(player, ask_play_again)

		sock      = player.socket

		sock.puts(SCREEN_CLEAR + CURSOR_UP)
	
		i=0	
		File.open('motd.txt').each_line{ |line_in_file|

			strMONSTER = COLOUR_RED_BLINK + 'MONSTER' + COLOUR_RESET

			line_in_file = line_in_file.gsub('MONSTER', strMONSTER)

			sock.puts line_in_file 

			i+=1
		}

		sock.puts COLOUR_YELLOW_BLINK + ' N' + COLOUR_RESET + ' = New character'
		sock.puts COLOUR_RED_BLINK + " Q" + COLOUR_RESET + ' = Quit'

		if(ask_play_again)
			sock.puts COLOUR_YELLOW_BLINK + ' S' + COLOUR_RESET + ' = Show character'
			sock.puts COLOUR_GREEN_BLINK + ' H' + COLOUR_RESET + ' = Heal character'
			sock.puts "\n " + COLOUR_GREEN_BLINK + 'P' + COLOUR_RESET + 'lay again? (same character)'
		end
	end

	def _print_motd_2(player)

		sock      = player.socket

		sock.puts(SCREEN_CLEAR + CURSOR_UP)
	
		File.open('motd.txt').each_line{ |line_in_file|

			strMONSTER = COLOUR_RED_BLINK + 'MONSTER' + COLOUR_RESET

			sock.puts line_in_file 
		}

		sock.puts COLOUR_YELLOW_BLINK + ' W' + COLOUR_RESET + ' = Wait for other players'
		sock.puts COLOUR_RED_BLINK + " F" + COLOUR_RESET + ' = Force start'

	end

	def _handle_cmd(monitor, player, ask_play_again)	

		sock = player.socket

		cmd = prompt(sock, 'cmd')

		monitor.synchronize {

			case cmd[0]
				when 'n'
					name = prompt(sock, 'name')
					player.character= Character.new(name)
					return true, false
									
				when 'q'
					_exit(player)
				when 'n'
					_exit(player)
				when 'p'
					return true, false if ask_play_again
				when 's'
					return false, true
				when ''
					return false, false
				when 'h'
					player.character.heal
					return false, false
				else
					sock.puts 'Not implemented'
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
					sock.puts 'Not implemented'
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

	skip = pcs.length

	pcs.each_with_index { |pc , i |

		unless(i<skip)

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
		#print print npc.name + ' ' + npc.current_hp.to_s + ' ' + npc.dead.to_s + ' ' + npc.unconscious.to_s + ' '
		if(npc.current_hp>0 and npc.dead==false and npc.unconscious==false)
			res = true
		end
	}

	#print res.to_s
	
	return res

end

def init_round(pcs, npcs, combatants)

	while (pcs.length<2) 
		pcs.push(Character.new('dummy'))
	end

	rename_pcs(pcs)

	pcs.each { |pc| npcs.push(Character.new('dummy')) }
	
	rename_npcs(npcs)

	pcs.each  { |pc|  combatants.push(pc)  }
	npcs.each { |npc| combatants.push(npc) }

	print(SCREEN_CLEAR + CURSOR_UP + "NEW FIGHT!")
	print(combatants_to_s(combatants) + "\nHIT ENTER TO BEGIN" )
	$clients.gets_all
	print(SCREEN_CLEAR + CURSOR_UP)
end

def fight_all_rounds(pcs,npcs,combatants)

	i=0
	while true
		i=i+1
		print "========================= Round: #" + i.to_s() + " ==============================\n\n"

		players_left = false
		enemies_left = false

		combatants.each { |character|
			character.apply_wounds_effects_round_start
		}

		pcs.each  { | character | 

			if(npcs_left(npcs))
				actions(character, npcs)
			end

			print "\n----------------------------------------------------------------\n\n"
		}

		npcs.each { | character | 

			if(pcs_left(pcs))
				actions(character, pcs)
			end

			print "\n----------------------------------------------------------------\n\n"
		}

		#print "enemies left:" + enemies_left.to_s() + ", players left: " + players_left.to_s() + "\n"

		if(not pcs_left(pcs))
			print "NPCs won!\n"
			break
		end

		if(not npcs_left(npcs))
			print "PCs won!\n"
			break
		end

		#$clients.gets_all
		sleep(0.5)

		print SCREEN_CLEAR + CURSOR_UP
		
	end

	$clients.gets_all
	print SCREEN_CLEAR + CURSOR_UP
	print(combatants_to_s(combatants))
	$clients.gets_all

end

$forced_start_fight = false
$clients            = Clients.new

def main()


	server      = TCPServer.open(20015)
	players     = Array.new
	pcs         = Array.new
	npcs        = Array.new
	combatants  = Array.new
	monitor     = Monitor.new

	fight_thread = ''

	Thread.start() do 

		fight_thread = Thread.current

		loop { # one iteration is one fight

			Thread.stop

			monitor.synchronize {

				if($forced_start_fight and players.length>0)
					$forced_start_fight = false

					init_round(pcs, npcs, combatants)

					fight_all_rounds(pcs,npcs,combatants)

					# <cleanup>
					pcs        = Array.new
					npcs       = Array.new
					combatants = Array.new

					# </cleanup>
				end

				players.each { |p| p.thread_id.run }
			}

		}
	end

	loop { # accept new players                       

		Thread.start(server.accept) do | sock |

			player = ''
			ask_play_again = false

			pre_menu(sock)

			monitor.synchronize {

				player = Player.new(players, Thread.current, sock)

				$clients.addClient(player)

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

main
