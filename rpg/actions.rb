class Action

	attr_accessor :actor_type

	attr_accessor :actions
	attr_accessor :targets

	attr_accessor :round
	attr_accessor :sub_round

	attr_accessor :combatants
	attr_accessor :side1
	attr_accessor :side2

	def initialize(active_xpc, brains)

		p "Action/initialize: caller => #{caller()}"

		@active_xpc = active_xpc
		@actor_type = brains
		@targets    = Array.new
	end

	def choose_target(draw, action, targets, criteria)

		p "choose_target: #{targets[0].name}"

		if(targets != nil)
			p "choose_target: #{criteria} => #{targets[0].name}, n=(#{targets.length})..."
		else
			raise Error.new("choose_target: #{criteria}, targets=nil!")
		end

		if(@actor_type == 'biological')
			@targets = choose_target_menu(draw, targets)
		else
			@targets = ai_choose_target(targets, criteria)
		end
		#p '>>>' 
		#p @targets
	end



	def first_draw(actor, targets)
		str = draw_subround(1, actor, targets, 'none')
		draw_all(str)
	end

end

