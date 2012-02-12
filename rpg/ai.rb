
def target_debug(*vargs)
	p *vargs
end


def ai_choose_target(targets, criteria)

	def ___choose_from_remaining(opps, choice)

		def ____stronger(opp1, opp2)

			if(opp1.strength > opp2.strength)
				return true
			end

			return false
		end

		def ____weaker(opp1, opp2)

			if(opp1.strength < opp2.strength)
				return true
			end

			return false

		end

		case choice
			when 'weakest'
				idx = opps.each_with_index.inject(0) { | min_i, (opp, i) |
					if (____weaker(opp, opps[min_i]))
						i
					else
						min_i
					end
				}
				return opps[idx]

			when 'strongest'

				idx = opps.each_with_index.inject(0) { | max_i, (opp, i) |
					if (____stronger(opp, opps[max_i]))
						i
					else
						max_i
					end
					
				}
				return opps[idx]
		end
	end

	p "ai_choose_target: #{criteria} #{targets.each {|target| target.name }}"

	target_debug "total targets: #{targets.length}"

	p targets.class

	opps, preference = prune_non_targets(criteria, targets)

	p opps.class

	target_debug "pruned targets: #{opps.length}"

	chosen_target = ___choose_from_remaining(opps, preference)

	targets.each { |o| target_debug "#{o.name}=#{o.strength.to_s} (str)" }

	if(criteria and chosen_target)
		print COLOUR_MAGENTA + "chose: #{chosen_target.name} w/criteria=#{criteria} and preference=#{preference}" + COLOUR_RESET + EOL
	end

	#tmp hack
	chosen_targets = Array.new
	chosen_targets.push(chosen_target)

	return chosen_targets

end


def prune_non_targets(criteria, targets)

	preference=''

	opps = Array.new

	if(criteria == 'evil')

		preference = 'weakest'

		targets.each { |opp|

			opp.check_hitpoints

			if (not opp.dead)
				target_debug "#{opp.name} not dead, good target"
				opps.push(opp)
			else
				target_debug "#{opp.name} is dead, not a target"
			end
		}
	else
		targets.each { |opp|

			opp.check_hitpoints

			if (opp.current_hp>0 and not opp.dead and not opp.unconscious)
				target_debug "#{opp.name} good target"
				opps.push(opp)
			else
				target_debug "#{opp.name} not hp>0+not dead+not unco, not a target"
			end
		}

		if(criteria == 'smart')
			preference = 'weakest'
		else
			preference = 'strongest'
		end

	end

	return opps, preference
end

