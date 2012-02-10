def rename_orcs(npcs)

	surname = ' the Orc'

	npcs.each_with_index { |npc , i |

		case npc
			when Orc
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
		end
	}	
end


def rename_humans(npcs)

	npcs.each_with_index { |npc , i |

		case npc
			when Human

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
		end
	}	
end


def rename_trolls(npcs)

	npcs.each_with_index { |npc , i |

		case npc
			when Troll

			if (npc.brains == 'artificial')
				case i
					when 0
						npc.name = 'Gargath the Troll'
					when 1
						npc.name = 'Bargunth the Troll'
					when 2
						npc.name = 'Harag the Troll'
					else
						npc.name = "Trollo the #{i}th"
				end
			end
		end
	}	
end



def rename_kobolds(npcs)

	npcs.each_with_index { |npc , i |

		case npc
			when Kobold

			if (npc.brains == 'artificial')

				case i
				
					when 0
						npc.name = 'Fiiu'
					when 1
						npc.name = 'Beuo'
					when 2
						npc.name = 'Ruuhuu'
					when 3
						npc.name = 'Banza'
					when 4
						npc.name = 'Leka'
					when 5
						npc.name = 'Teenee'
					when 6
						npc.name = 'Buhh'
					when 7
						npc.name = 'Jahda'
					when 8
						npc.name = 'Nee'
					else
						npc.name = "Kob the #{i}th"
				end
			end
		end
	}	
end

