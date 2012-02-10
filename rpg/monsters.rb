def _filter(ratio, stat)
	return (stat*ratio).to_i
end

class Human < Character
	def initialize(*args)
		super(*args)
	end
end


class Orc < Character
	def initialize(*args)
		super(*args)
	end
end

class Troll < Character

	def initialize(*args)
		super(*args)

		@hp += 150
		@ob *= 2

		heal_self_fully(true)
	end
end

class Kobold < Character

	def initialize(*args)
		super(*args)

		ratio=0.75

		@ob = _filter(ratio ,@ob)
		@db = _filter(ratio ,@db)
		@ac = _filter(ratio ,@ac)
		@hp = _filter(ratio ,@hp)


		heal_self_fully(true)
	end
end
