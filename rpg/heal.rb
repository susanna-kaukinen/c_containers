
class Heal < Action

	def draw(draw)
		raise Error.new("#{self}.draw NOT IMPLEMENTED")
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
				_cls(character)

				character.heal(friends)

				draw_active_player(character, "Healing all friends.")

				return true, text
			else
				_cls(character)

				friends.each_with_index { |healee,i|
					if(cmd == i.to_s)
						character.heal(healee)
						draw_active_player(character, "Healing " + healee.name)
					end
				}

				return true, text
			end
		
			_cls(character)

		}

	end

end


