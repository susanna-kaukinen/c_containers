
class Heal < Action

	def initialize(healer)
		super(healer, healer.brains)

		@healer = healer

		@draw_data  = Array.new
		@num_healed = 0
	end

	def resolve
		
		print COLOUR_CYAN +  "heal: #{@healer.name} =+=> #{@targets[0].name}..." + COLOUR_RESET + EOL

		if(not @healer.can_heal?)

			p 'CANNOT HEAL'
			p 'CANNOT HEAL'
			p 'CANNOT HEAL'

			text = 'no mana'
			@draw_data = Array.new
			@draw_data << text
			
			nop = NoAction.new(@healer, text)
			_nop = Array.new
			_nop.push(nop)
			return _nop
		end

		@num_healed, @draw_data = @healer.heal(@targets)

		print COLOUR_CYAN +  "heal: #{@healer.name} =+=> #{@targets[0].name}..." + COLOUR_RESET + EOL

		return Array.new
	end

	def _heal(character, friends)

		if(not character.can_heal?)
			text = _explain_why_not(character, 'heal', 'not enough mana?')
			draw_active_player(character, text)
			return false
		end

		text='' #TODO

		loop {
			draw_active_player(character, 'Choose action:')

			prompt = ' (e)=all Equally' + "\n "

			friends.each_with_index { |opponent,i|
				prompt += "(#{i})" + opponent.name + " "
				if(i%2==1)
					prompt += "\r\n "
				end
			}
			
			draw_active_player(character, prompt)

			cmd = ask_active_player(character, 'heal_action')

			if(cmd == 'e')
				draw._cls(character)

				character.heal(friends)

				draw_active_player(character, "Healing all friends.")

				return true, text
			else
				draw._cls(character)

				friends.each_with_index { |healee,i|
					if(cmd == i.to_s)
						character.heal(healee)
						draw_active_player(character, "Healing " + healee.name)
					end
				}

				return true, text
			end
		
			draw._cls(character)

		}

	end


	def draw(draw)
		print COLOUR_CYAN +  "draw: #{@healer.name} =X=> #{@targets[0].name}..." + COLOUR_RESET + EOL
		draw.draw_heal(@healer, @targets, @num_healed, @draw_data)
	end

end


