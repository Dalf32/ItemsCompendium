require_relative 'CursesIO'
require_relative 'StandardIO'

class UserIO
  #IO method flags
  STANDARD = :standard
  CURSES = :curses

  #Character flags
  TAB = :tab
  ENTER = :enter

  def self.use(io_method)
    if io_method == STANDARD
      extend StandardIO
    elsif io_method == CURSES
      extend CursesIO
    end

    init
  end
end

class ReadResult
  attr_reader :text, :last_char

  def initialize(text, last_char)
    @text = text
    @last_char = last_char
  end
end
