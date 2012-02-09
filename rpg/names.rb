def rename_orcs(npcs)

	surname = ' the Orc'

	npcs.each_with_index { |npc , i |

		if (npc.brains == 'artificial')
			case i
			
				when 0
					npc.name = 'Gurlar'   + surname
				when 1
					npc.name = 'Bronthor' + surname
				when 2
					npc.name = 'Visnasch' + surname
				when 3
					npc.name = 'Hugnarl'  +  surname
				else
					npc.name = 'Unknown'  + i.to_s + surname
			end
		end
	}	
end


def rename_humans(npcs)

	npcs.each_with_index { |npc , i |

		if (npc.brains == 'artificial')
			case i
			
				when 0
					npc.name = 'Aramir the Invincible'
				when 1
					npc.name = 'Drendon the Old'
				when 2
					npc.name = 'Ezmu the Small'
				when 3
					npc.name = 'Bereth the Strong'
				else
					npc.name = "Beanel the #{i}th"
			end
		end
	}	
end
