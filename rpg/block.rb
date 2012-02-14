class Block < Action

	attr_accessor :blocker

	def initialize(blocker)
		super(blocker, blocker.brains)

		@blocker   = blocker

		@draw_data  = Array.new
	end


	def resolve

		can_block, why_cant = @blocker.can_block_now()

		if(not can_block)
			text = _explain_why_not(@blocker, 'block', why_cant)
			@draw_data = Array.new
			@draw_data << text
			
			nop = NoAction.new(@blocker, text)
			_nop = Array.new
			_nop.push(nop)
			return _nop
		end

		if(@blocker.brains == 'artificial')
			@blocker.block(@targets[0].name, @blocker.current_ob)
		end

		print COLOUR_CYAN +  "block: #{@blocker.name} =X=> #{@targets[0].name}..." + COLOUR_RESET + EOL
		return Array.new
	end

	def choose_target_menu(draw, targets)

		can_block, why_cant = @blocker.can_block_now()

		if(can_block==false)
			text = _explain_why_not(@blocker, 'block', why_cant)
			draw.draw_active_player(@blocker, text)
			return false
		end

		loop {
			draw.draw_active_player(@blocker, 'Choose action:')

			prompt = ' (e)=all Equally' + "\n "

			targets.each_with_index { |opponent,i|
				prompt += "(#{i})" + opponent.name + " "
				if(i%2==1)
					prompt += "\r\n "
				end
			}
			
			draw.draw_active_player(@blocker, prompt)

			cmd = draw.ask_active_player(@blocker, 'block_action')

			case cmd

				when 'e', 'b'
		
				how_much = @blocker.current_ob / targets.length
				
				targets.each_with_index { |opponent,i|
					@blocker.block(opponent.name, how_much)
				}

				#draw.draw_active_player(@blocker, "Blocking w/#{how_much} against all targets.")

				return targets
			else
				how_much = @blocker.current_ob / 2

				targets.each_with_index { |opponent,i|
					if(cmd == i.to_s)
						@blocker.block(opponent.name, how_much)
						#draw.draw_active_player(@blocker, "Blocking w/#{how_much} against " + opponent.name)
						_targets = Array.new
						_targets.push(opponent)
						return _targets
					end
				}

			end
		

		}
	end

	def draw(draw)
		print COLOUR_CYAN +  "draw: #{@blocker.name} =X=> #{@targets[0].name}..." + COLOUR_RESET + EOL
		draw.draw_block(@blocker, @targets)
	end

end

