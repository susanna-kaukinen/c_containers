class Block < Action

	def draw(draw)
		raise Error.new("#{self}.draw NOT IMPLEMENTED")
	end

	def _block(character, opponents)
	
		can_block, why_cant = character.can_block_now()

		if(can_block==false)
			text = _explain_why_not(character, 'block', why_cant)
			draw_active_player(character, text)
			return false
		end

		loop {
			draw_active_player(character, 'Choose action:')

			prompt = ' (e)=all Equally' + "\n "

			opponents.each_with_index { |opponent,i|
				prompt += "(#{i})" + opponent.name + " "
				if(i%2==1)
					prompt += "\r\n "
				end
			}
			
			draw_active_player(character, prompt)

			cmd = ask_active_player(character, 'block_action')

			if(cmd == 'e')
		
				how_much = character.current_ob / opponents.length
				
				opponents.each_with_index { |opponent,i|
					character.block(opponent.name, how_much)
				}

				draw_active_player(character, "Blocking w/#{how_much} against all opponents.")

				return true
			else
				how_much = character.current_ob / 2

				opponents.each_with_index { |opponent,i|
					if(cmd == i.to_s)
						character.block(opponent.name, how_much)
						draw_active_player(character, "Blocking w/#{how_much} against " + opponent.name)
					end
				}

				return true
			end
		

		}
	end
end

