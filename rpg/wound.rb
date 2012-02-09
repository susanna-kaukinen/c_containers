class Wound
	attr_accessor :damage, :bleeding, :stun, :uparry, :downed, :prone, :unconscious, :dead	
	attr_accessor :target
	attr_accessor :text

	def initialize()
		@damage = 0
		@bleeding = 0 # how many hp:s per round
		@stun   = 0
		@uparry = 0
		@downed = 0
		@prone  = 0
		@unconscious = false
		@dead        = false

		@target = ''

		@text = ''
	end

	def to_s()

		str='Wound:'

		if(@damage>0)
			str += @damage.to_s
		end

		return str
	end

	def to_json(*a)
		{
			'class'       => self.class.name,
			'damage'      => "#{@damage}",
			'bleeding'    => "#{@bleeding}",
			'stun'        => "#{@stun}",
			'uparry'      => "#{@uparry}",
			'downed'      => "#{@downed}",
			'prone'       => "#{@prone}",
			'unconscious' => "#{@unconscious}",
			'dead'        => "#{@dead}",
			'target'      => "#{@target}",
			'text'        => "#{@text}",

		}.to_json(*a)
	end

	def self.json_create(o)
		new(*o['data'])
	end

	def apply(character, target)

		if(character == nil)
			throw :no_character
		end

		@text = character.name + " was hit in the " + target

		if(@damage)
			character.current_hp -= @damage
	
			@text += " and was dealt " + @damage.to_s() + " extra damage"
		end

		if(@stun > 0)
			character.stun += @stun
			@text += " and is stunned for " + @stun.to_s() + " rounds"
		end

		if(@bleeding > 0)
			character.bleeding += @bleeding
			@text += " and is bleeding " + @bleeding.to_s() + " hits worth each round"
		end
		
		if(@uparry > 0)
			character.uparry += @uparry
			@text += " and is unable to parry for " + @uparry.to_s() + " rounds"
		end

		if(@downed > 0)
			character.downed += @downed
			@text += " and is downed for " + @downed.to_s() + " rounds"
		end

		if(@prone > 0)
			character.prone += @prone
			@text += " and is prone for " + @prone.to_s() + " rounds"
		end

		if(@unconscious == true)
			character.unconscious = true
			@text += " and is unconscious "
		end

		if(@dead == true)
			character.dead = true
			@text += " and is dead"
		end

		character.add_wound(self)
		
		#p self
		
		return COLOUR_CYAN + "\t===> " + @text + "\n" + COLOUR_RESET

	end

end

