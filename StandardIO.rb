require_relative 'UserIO'

module StandardIO
  def init
    #NOOP
  end

  def print(text)
    $stdout.print text
  end

  def puts(text)
    $stdout.puts text
  end

  def read_until(*flag_chars)
    ReadResult.new($stdin.readline, UserIO::ENTER)
  end
end