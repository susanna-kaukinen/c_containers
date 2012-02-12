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
		@active_xpc = active_xpc
		@actor_type = brains
		@actor_type = Array.new
		@targets    = Array.new
	end

	def choose_target(targets, criteria)

		#p "choose_target: #{criteria} => #{targets}"
		p "choose_target: #{criteria} => #{targets[0].name}, ..."

		if(@actor_type == 'human')
			choose_target_menu()
		else
			@targets = ai_choose_target(targets, criteria)
		end
		p '>>>' 
		p @targets
	end
	
	def draw(draw)

=begin
		p 'XXX'
		p @active_xpc
		p @targets
		p @mix_attack
		p @mix_damage
		p 'XXX'
=end

		p self.class

		if(self.is_a? Attack)
			draw.draw_attack(@active_xpc, @did_attack, @targets, @mix_attack, @mix_damage )
		elsif(self.is_a? Block)
			draw.draw_block
		elsif(self.is_a? Heal)
			draw.draw_heal
		end

		raise ArgumentError.new("self=#{self} not drawable?")
	end

	def choose_target_menu()

		text='' #TODO

		loop {
			draw_active_player(character, 'Choose target:')

			prompt = ' (a)=Auto target' + "\n "

			@targets.each_with_index { |target,i|
				prompt += "(#{i})" + target.name + " "
				if(i%2==1)
					prompt += EOL
				end
			}
			
			draw_active_player(character, prompt)

			cmd = ask_active_player(character, 'attack_option')

			if(cmd == 'a')
				_cls(character)
				return false, text
			else
				_cls(character)

				chosen_target = nil

				@targets.each_with_index { |target,i|
					if(cmd == i.to_s)
						chosen_target = target
						break
					end
				}

				@targets.push(chosen_target)
			end
		
			_cls(character)

		}
	end
end

