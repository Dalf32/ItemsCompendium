class RingBuffer < Array

  attr_reader :buffer_size

  alias_method :array_push, :push
  alias_method :array_element, :[]

  def initialize(buf_size)
    @buffer_size = buf_size
    super(buf_size)
  end

  def [](offset = 0)
    array_element(-1 - offset)
  end

  def push(element)
    if length == @buffer_size
      shift
    end

    array_push(element)
  end

  def to_s
    out_str = '['

    length.times{|n|
      out_str<<"#{self[n]},"
    }

    "#{out_str[0..-2]}]"
  end
end

#MAIN
ring_buf = RingBuffer.new(5)

12.times{|n|
  ring_buf.push(n)
  puts ring_buf.to_s
}