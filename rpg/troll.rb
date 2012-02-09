
class Troll < Character

	def initialize(*args)
		super(*args)

		@hp += 150
		@ob *= 2

		heal_self_fully(true)
	end

end
