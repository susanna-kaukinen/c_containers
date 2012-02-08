
#<def_SynchronisedStack>
class SynchronisedStack < Array

	include MonitorMixin

	def initialize(*args)
		super(*args)
	end

	alias :old_pop :pop
	alias :old_push :push

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

end
# </def_SynchronisedStack>

