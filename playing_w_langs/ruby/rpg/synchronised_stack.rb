
#<def_SynchronisedStack>
class SynchronisedStack < Array

	include MonitorMixin

	def initialize(*args)
		super(*args)
	end

	alias :old_shift  :shift
	alias :old_pop    :pop
	alias :old_push   :push
	alias :old_length :length

	def shift()
		self.synchronize do
			self.old_shift()
		end
	end

	def pop()
		self.synchronize do
			self.old_pop()
		end
	end

	def push(item)
		self.synchronize do
			self.old_push(item)
		end
	end

	def length()
		self.synchronize do
			self.old_length		
		end
	end

end
# </def_SynchronisedStack>

