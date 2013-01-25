def _filter(ratio, stat)
	return (stat*ratio).to_i
end

class Human < Character
	def initialize(*args)
		super(*args)
	end
end

class Elf < Character


	def initialize(*args)
		super(*args)

		@hp = _filter(0.6, @hp)
		@ob = _filter(1.1, @ob)
		@db = _filter(1.4, @db)
		@quickness = _filter(1.4, @quickness)

		heal_self_fully(true)
	end
end

class Dwarf < Character


	def initialize(*args)
		super(*args)

		@hp = _filter(1.5, @hp)
		@ob = _filter(1.2, @ob)
		@db = _filter(0.9, @db)
		@quickness = _filter(0.72, @quickness)

		heal_self_fully(true)
	end
end

class Orc < Character
	def initialize(*args)
		super(*args)

		@hp = _filter(1.2, @hp)
		@ob = _filter(0.9, @ob)
		@db = _filter(0.9, @db)
		@quickness = _filter(0.9, @quickness)

		heal_self_fully(true)
	end
end

class Troll < Character

	def initialize(*args)
		super(*args)

		@hp += 150
		@ob *= 2
		@quickness = _filter(0.7, @quickness)

		heal_self_fully(true)
	end
end

class Kobold < Character

	def initialize(*args)
		super(*args)

		ratio=0.75

		@ob = _filter(ratio ,@ob)
		@db = _filter(ratio ,@db)
		@hp = _filter(ratio ,@hp)

		@quickness =  _filter(1.2, @quickness)

		heal_self_fully(true)
	end
end
