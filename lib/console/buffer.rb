
CHAR_RIGHT = "\e[C"
CHAR_LEFT = "\e[D"
CHAR_UP = "\e[A"
CHAR_DOWN = "\e[B"

# Keeps track of content visible on the screen. 
class LineBuffer

  attr_reader :idx

	def initialize
		@chars = []
		@idx = 0
		@stack = []
	end

  # Returns the current contents of the current line in buffer
	def to_s
		@chars.join ""
	end

  # Clears the current line 
	def clear
		@chars.clear
		@idx = 0
	end

	def set(content, cursor_idx = 0)
		step_back = (CHAR_LEFT * @idx)
		difference = @chars.length - content.to_s.length
		difference = 0 if difference < 0
		padding = " " * difference
		rewind = CHAR_LEFT * (content.length + difference)
		position = CHAR_RIGHT * cursor_idx

		r = step_back + content + padding + rewind + position

		@idx = cursor_idx
		@chars = content.to_s.split ""

		return r
	end

	def type(c)
		@chars.insert(@idx, c)
		r = @chars[@idx..-1].join("") + (CHAR_LEFT * (@chars.length - @idx - 1))
		@idx += 1
		r
	end

	def print(text)
		text.to_s.split("").collect { |c| type c }.join ""
	end

	def delete_back(n = 1)
		if @idx > 0
			n = @chars.length if n > @chars.length
			(@idx - 1).downto(@idx - n).each { |i| @chars.delete_at(i) }
			@idx -= n
			r = (CHAR_LEFT * n) + @chars[@idx..-1].join("") + (" " * n) + (CHAR_LEFT * (@chars.length - @idx + n))
			return r
		else
			""
		end
	end

	def delete(n = 1)
		if @idx < @chars.length
			n = @chars.length - @idx if @idx + n > @chars.length
			(@idx..(@idx - 1 + n)).each { |i| @chars.delete_at(@idx) }
			r = @chars[@idx..-1].join("") + (" " * n) + (CHAR_LEFT * (@chars.length - @idx + 1))
			return r
		end
    ""
	end

	def cursor_up(n = 1)
	end

	def cursor_down(n = 1)
	end

  # Moves cursor to the left by n characters. If the requested position is past the beginning of the buffer then
  # it stops at the first (0) index
	def cursor_left(n = 1)
    cn = [ @idx, n ].min

		if cn > 0
			@idx -= cn
			return CHAR_LEFT * cn
		end
    ""
	end

  # Moves cursor to the right by n characters. If the requested position is past the end of the buffer then it stops at
  # the last index
	def cursor_right(n = 1)
    cn = [ @chars.length - @idx, n ].min

		if @idx < @chars.length
			@idx += cn
			return CHAR_RIGHT * cn
		end
    ""
	end

	def push_state
		@stack.push [ @chars, @idx ]
	end

	def pop_state
		chars, idx = @stack.pop
		set(chars.join(""), idx)
	end

	def complete(options)
		if options.length == 1
			self.print options[0] + " "
		elsif options.length > 1
			# TODO menu drawing	
		end
	end
end

# vim: ts=2:sw=2:nowrap:ft=ruby
