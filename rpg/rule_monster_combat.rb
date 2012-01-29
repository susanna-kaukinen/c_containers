#!/usr/bin/ruby

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
	attr_accessor :damage, :stun, :uparry, :downed, :prone, :unconscious, :dead	
	attr_accessor :target
	attr_accessor :text

	def initialize()
		@damage = 0
		@stun   = 0
		@uparry = 0
		@downed = 0
		@prone  = 0
		@unconscious = false
		@dead        = false

		@target = ''

		@text = ''
	end

	def apply(character, target)

		p self

		if(character == nil)
			throw :no_character
		end

		if(@damage)
			character.current_hp -= @damage
	
			@text += character.name + " was hit in the " + target + " and was dealt " + @damage.to_s() + " extra damage"
		end

		if(@stun > 0)
			character.stun += @stun
			@text += " and is stunned for " + @stun.to_s() + " rounds"
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
		
		print "\t===> " + @text + "\n"

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

		print '*** CRITICAL *** ' + "\n"
		print '*** CRITICAL *** ' + "\n"
		print '*** CRITICAL *** ' + "\n"

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

		_roll = roll(nil, nil)[1] 
		print "Crit roll=" + _roll.to_s() + "\n"
		result = _roll + crit_bonus

		wound = Wound.new()


		target_bonus = 0
		case result
			when 0 ... 10
				print 'Zip!'
			when 11 ... 20
				wound.damage = 1 + rand(10)	
			when 21 ... 40
				wound.damage = 1 + rand(10)	
				wound.stun   = 1
			when 41 ... 60
				wound.damage = 1 + rand(10) + 10
				wound.stun   = 2
				wound.uparry = 1
				target_bonus = 5
			when 61 ... 80
				wound.damage = 1 + rand(15) + 10
				wound.stun   = 3
				wound.uparry = 2
				target_bonus = 15
			when 80 ... 90
				wound.damage = 1 + rand(15) + 15	
				target_bonus = 25
			when 91 ... 95
				wound.damage = 1 + 30
				wound.prone = 3
				target_bonus = 35
			when 96 ... 99
				wound.damage = 1 + rand(30) + 30
				wound.unconscious = true
				target_bonus = 40
			when 100 ... 9999
				wound.dead   = true
				target_bonus = 60
		end

		wound.target = '<<<none>>>'
		target_result = 1 + rand(100) + target_bonus
		case target_result
			when -9999 ... 7
				wound.target = 'secondary arm'
			when 7 ... 14
				wound.target = 'weapon arm'
			when 14 ... 21
				wound.target = 'left leg'
			when 21 ... 28
				wound.target = 'right leg'
			when 28 ... 35 
				wound.target = 'stomach'
			when 35 ... 42
				wound.target = 'side'
			when 42 ... 48
				wound.target = 'back'
			when 48 ... 55
				wound.target = 'neck'
			when 55 ... 62
				wound.target = 'shoulder'
			when 62 ... 70
				wound.target = 'elbow'
			when 70 ... 77
				wound.target = 'knee'	
			when 77 ... 84
				wound.target = 'throat'
			when 84 ... 91
				wound.target = 'skull'
			when 91 ... 9999
				wound.target = 'groin'
		end

		if(wound.target=='<<<none>>>')
			print "target_result=" + target_result.to_s() + "\n"
		end

		wound.apply(defender, wound.target)
	end

	def deal_damage(result, defender)
		hp_damage, critical = damage_table(result)

		defender.current_hp -= hp_damage

		if(hp_damage>0)
			print "\t" + name + " deals " + hp_damage.to_s() + " hit points of damage.\n"
		else
			if(rand(2)==1)
				evade = "dodges"
			else
				evade = "blocks"
			end
			print defender.name + " " + evade + " the attack\n"
		end

		if(critical)
			print "\nCritical: " + critical.level + ' ' + critical.type + "es\n"
			resolve_critical(critical, defender)
		end

 		print defender.name + " has " + defender.current_hp.to_s() + " hit points left\n"

		if(defender.current_hp<0 and defender.dead == false)
			defender.unconscious = true
			print defender.name + " falls unconscious.\n"
		end

		if(defender.current_hp < -defender.hp or defender.dead == true)
			print defender.name + " is DEAD!\n"
			defender.dead = true
		end

	end

end

class Character

	# base, or so
	attr_accessor :name
	attr_accessor :ob, :db, :ac, :hp

	# current/active
	attr_accessor :stun, :uparry, :downed, :prone, :blind
	attr_accessor :unconscious, :dead
	attr_accessor :current_db, :active_weapon, :current_hp
	attr_accessor :wounds

	def initialize(name)
		@name	= name
		@ob	= count("ob")
		@db	= count("db")
		@ac	= count("ac")
		@hp	= count("hp")

		@stun = 0
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

		if (roll<96)
			return result, first_roll, fumble
		end


		print "OPEN-ENDED: " + roll.to_s() + "\n"
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

	print "Roll:" + _roll.to_s() + " => result:" + result.to_s() + "\n"

	attacker.active_weapon.deal_damage(result, defender)
end

def get_next(hash)
	if(hash.length<=0)
		return nil
	end

	i=0
	while true
		if(hash[i] != nil)
			return hash[i]
		end
		i += 1
	end
end

def consider_wounds(character)
=begin
	if(character.wounds.length()>0) 
		print 'considering wounds for ' + character.name + "\n"
		p character	
	end
=end
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
		attack(character, get_next(opponents))
	else
		print character.name + " cannot attack, reason: " + reason + "\n"
	end

	print "\n"
end

def print_combatants(combatants)
	combatants.each  { | index, character |  
		print character.name + " " + character.to_s() + "\n" 
		character.wounds.each { | wound |
			if(wound)
				p wound
			end
		}
	}
end

def check_dead_and_unco(pcs, npcs)

	pcs.each { | index, character |
		if(character !=nil) 
			if(character.unconscious or character.dead)
				pcs.delete(index)
			end
		end
	}

	npcs.each { | index, character |
		if(character !=nil) 
			if(character.unconscious or character.dead)
				npcs.delete(index)
			end
		end
	}
end

def main()

	print "version:\n"
	print "version: 2 pcs and 2 orcs can fight till end based on hitpoints\n"
	print "version:\n"

	pcs = Hash.new()
	pcs[0] = Character.new('Aragorn')
	pcs[1] = Character.new('Hargor')

	npcs = Hash.new()	
	npcs[0] = Character.new('orc1')
	npcs[1] = Character.new('orc2')

	combatants = Hash.new()

	i=0
	j=0
	while true
		if(pcs[i] != nil)
			combatants[j] = pcs[i]
			j += 1
		end
		if(npcs[i] != nil)
			combatants[j] = npcs[i]
			j += 1
		end
		i += 1

		if(i==(pcs.length() + npcs.length()))
			break
		end
	end

	print_combatants(combatants)

	i=0
	while true
		i=i+1
		print "======================= Round: #" + i.to_s() + "============================\n\n"

		pcs.each  { | name, character | 
			actions(character, npcs)
			check_dead_and_unco(pcs, npcs)
		}
		npcs.each { | name, character | 
			actions(character, pcs)
			check_dead_and_unco(pcs, npcs)
		}

		gets

		players_left = pcs.length()
		enemies_left = npcs.length()

		print "enemies left:" + enemies_left.to_s() + ", players left: " + players_left.to_s() + "\n"

		if(players_left<=0)
			print "NPCs won!\n"
			break
		end

		if(enemies_left<=0)
			print "PCs won!\n"
			break
		end
	end
	
	print_combatants(combatants)

end


main()
