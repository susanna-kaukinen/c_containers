#!/usr/bin/ruby1.9.2

require 'socket'                # Get sockets from stdlib
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

COLOUR_RED_REVERSE      = "\033[7m";

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
			'text'        => "#{@dead}",

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
	attr_accessor :tactic

	def get_personality
		personality = rand(3)

		case personality
			when 0 return 'smart'
			when 1 return 'evil'
			when 2 return 'stupid'
	end

	def initialize(name)
		@name	= name
		@ob	= count("ob")
		@db	= count("db")
		@ac	= count("ac")
		@hp	= count("hp")

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

		@personality = get_personality
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
		"\n\t bl:" + @blind.to_s()
	end

	def add_wound(wound)
		@wounds.push(wound)
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
				attack(attacker, attacker)
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


		if (roll<96)
			return result, first_roll, fumble
		end


	end
end

def attack(attacker, defender)

	if(defender==nil)
		print "No-one to attack!"
		return
	end

	print attacker.name + " ATTACKS " + defender.name + " with " + attacker.active_weapon.name + "\n"

	__roll  = roll(attacker.active_weapon, attacker)
	_roll   = __roll[0]
	fumble  = __roll[2]

	if(fumble==true)
		return
	end 

	result = attacker.ob - defender.current_db + _roll

	print  " => result:" + result.to_s() + "\n"

	attacker.active_weapon.deal_damage(result, defender)
end

def choose_opponent(character, opponents)

	case character.personality
		when 'smart'
		when 'evil'
		when 'stupid'
	end



	opponents.each_with_index { | character, index |
		if(character !=nil) 
			if(character.unconscious or character.dead)

			end
		end
	}
end


end

def consider_wounds(character)

	can_attack = true
	reason     = "no reason"

	character.current_db = character.db

	if(character.stun > 0)

		can_attack = false

		character.stun -= 1
		character.current_db -= 20
		reason     = "stunned"
		
		if(character.uparry > 0)
			character.uparry -= 1
			reason += " and unable to parry"
		end
	end

	if(character.bleeding > 0)
		cprint COLOUR_RED_REVERSE + character.name + ' loses ' + character.bleeding.to_s() + ' hits due to bleeding!' + "\n\n"
		character.current_hp -= character.bleeding
	end

	if(character.downed>0)

		can_attack = false

		character.downed -= 1
		character.current_db -= 30
		reason += " and downed"
	end

	if(character.prone>0)
	
		can_attack = false

		character.prone -= 1
		character.current_db -= 50
		reason += " and prone"
	end

	return can_attack, reason
end

def actions(character, opponents)
	
	can_attack, reason = consider_wounds(character)

	if(can_attack)
		attack(character, choose_opponent(character, opponents))
	else
		print COLOUR_BLUE + character.name + " cannot attack, reason: " + reason + "\n" + COLOUR_RESET
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



def verify_handshake(hello)

	p hello

	if(hello != "helo\r\n")
		return false
	end
	return "ok"
end

server  = TCPServer.open(20016)


class Clients

	attr_accessor :lock, :clients

	def initialize
		@lock    = Mutex.new
		@clients = Hash.new
	end

	def addClient(player)
		@lock.synchronize {
			clients[player.thread_id] = player.socket
		}
	end

	def getSocket(key)
		sock = ''
		@lock.synchronize {
			sock = clients[key]
		}
		return sock
	end

	def print(key, vargs)
		sock = getSocket(key)
		sock.puts(vargs)
	end

	def print_all(vargs)
		@lock.synchronize {
			clients.each{ | thread_id, socket | 
				if(thread_id.alive?)
					socket.puts(vargs) 
				end
			}

		}
	end

	def gets_all()

		#print_all "==<Enter to contine, 'say: ...' to coment (broken currently)>=="

		someone_said = false

		lock.synchronize {
			clients.each{ | thread_id, socket | 

				msg = ''

				if(thread_id.alive?)
					msg = socket.gets
				end

				if(msg >= '\r\n') 

					someone_said = true

					server_print(msg)

					clients.each{ | _thread_id, _socket | 
						if(thread_id.alive?)
							#socket.puts("\t===>" + msg + "<===(" + "#{thread_id}" + "/" + "#{socket}" + ")=====>\n\n")
							if(thread_id==_thread_id)
								_socket.puts("\n")
							else
								_socket.puts(msg)
							end
								
						end
					}
				else
					server_print("no msg? =>", msg)
				end
			}
		}

		if(someone_said)
			return true
		else
			return false
		end

	end

	def gets(key)
		sock = getSocket(key)
		str = sock.gets
		return str
	end

	def length
		len=0
		@lock.synchronize {
			len = clients.length	
		}
		return len
	end
end

$clients    = Clients.new
pcs         = Array.new()
npcs        = Array.new()	
combatants  = Array.new()

def sockprint(socket, *vargs)
	socket.puts(vargs)
end

def server_print(*vargs)
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

	def initialize(thread_id, socket)
		@thread_id = thread_id
		@socket    = socket
	end

	def write(*vargs)
		socket.gets(vargs)
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

def menu(player)

	thread_id = player.thread_id
	sock      = player.socket

	Mutex.new.synchronize {

		sock.puts(SCREEN_CLEAR + CURSOR_UP)
	
		i=0	
		File.open('motd.txt').each_line{ |s|

			strC = COLOUR_GREEN_BLINK      + 'C' + COLOUR_RESET
			strW = COLOUR_YELLOW_BLINK     + 'W' + COLOUR_RESET
			strN = COLOUR_GREEN_BLINK      + 'N' + COLOUR_RESET
			strQ = COLOUR_RED_BLINK        + 'Q' + COLOUR_RESET

			if(i>=20)
				s = s.gsub('C', strC)
				s = s.gsub('W', strW)
				s = s.gsub('N', strN)
				s = s.gsub('Q', strQ)
			end

			sock.puts s

			i+=1
		}

		cmd = prompt(sock, 'cmd')
		
		case cmd[0]
			when 'n'
				name = prompt(sock, 'name')
				return Character.new(name)
								
			when 'q'
				sock.puts 'bye'
				sock.close
				Thread.current.exit
			else
				sock.puts 'Not implemented'
				sleep(2)
				redo
		end
	}
end

def play_again(thread_id, sock)

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
				npc.name = 'Unknown'  + i + surname
		end
	}	
end

loop {                        
	sleep(1)

	Thread.start(server.accept) do | sock |

		player = Player.new(Thread.current, sock)

		$clients.addClient(player)

		server_print $clients.getSocket(player.thread_id)

		character = menu(player)
		pcs.push(character)

		if(pcs.length<2) 
			pcs.push(Character.new('Hargor'))
		end

		pcs.each { |pc| npcs.push(Character.new('dummy')) }
		
		rename_npcs(npcs)

		pcs.each  { |pc|  combatants.push(pc)  }
		npcs.each { |npc| combatants.push(npc) }

		print(SCREEN_CLEAR + CURSOR_UP + "NEW FIGHT!")
		print(combatants_to_s(combatants) + "\nHIT ENTER TO BEGIN" )
		$clients.gets_all
		print(SCREEN_CLEAR + CURSOR_UP)

		i=0
		while true
			i=i+1
			print "========================= Round: #" + i.to_s() + " ==============================\n\n"

			pcs.each  { | character | 
				actions(character, npcs)
				print "\n----------------------------------------------------------------\n\n"
			}
			npcs.each { | character | 
				actions(character, pcs)
				print "\n----------------------------------------------------------------\n\n"
			}

			someone_talked = true
			while someone_talked
				someone_talked = $clients.gets_all()	
			end

			players_left = false
			pcs.each { | pc |
				if(not pc.unconscious and not pc.dead)
					players_left = true
					break
				end
			}

			enemies_left = false
			pcs.each { | pc |
				if(not pc.unconscious and not pc.dead)
					enemies_left = true
					break
				end
			}

			print "enemies left:" + enemies_left.to_s() + ", players left: " + players_left.to_s() + "\n"

			if(players_left<=0)
				print "NPCs won!\n"
				break
			end

			if(enemies_left<=0)
				print "PCs won!\n"
				break
			end

			print SCREEN_CLEAR + CURSOR_UP
			
		end

		$clients.gets_all
		print SCREEN_CLEAR + CURSOR_UP
		print(combatants_to_s(combatants))

	end

}

