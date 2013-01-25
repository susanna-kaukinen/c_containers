
class NoAction < Action

	attr_accessor :non_actor

	def initialize(non_actor, reason_text)
		super(non_actor, non_actor.brains)

		@non_actor   = non_actor
		@reason_text = reason_text
	end

	def resolve
		return Array.new
	end

	def draw(draw)
		draw.draw_no_action(@non_actor, @reason_text)
	end

end

