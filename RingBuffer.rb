#RingBuffer.rb

##
# This class turns Array into a generic, fixed-size ring buffer.
# This implementation is based on the RingBuffer class found here: http://www.sourcepole.com/2007/9/24/a-ringbuffer-in-ruby
##
class RingBuffer < Array

  attr_reader :buffer_size

  alias_method :array_push, :push
  alias_method :array_element, :[]

  ##
  # Creates a new RingBuffer of the given size.
  ##
  def initialize(buf_size)
    @buffer_size = buf_size
    super(buf_size)
  end

  ##
  # Allows for bracket indexing of the RingBuffer.
  ##
  def [](offset = 0)
    array_element(-1 - offset)
  end

  ##
  # Pushes the given element onto the end of the buffer, removing an old element if necessary.
  ##
  def push(element)
    if length == @buffer_size
      shift
    end

    array_push(element)
  end

  ##
  # Returns a stringified version of the RingBuffer's elements.
  ##
  def to_s
    out_str = '['

    length.times{|n|
      out_str<<"#{self[n]},"
    }

    "#{out_str[0..-2]}]"
  end
end