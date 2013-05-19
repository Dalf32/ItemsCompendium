require 'curses'

class CursesWin
  TAB = :tab
  ENTER = :enter

  @c_win

  def self.init
    @c_win = Curses.stdscr
    Curses.init_screen
    Curses.noecho
    @c_win.scrollok(true)
  end

  def self.print(text)
    @c_win<<text
    @c_win.refresh
  end

  def self.puts(text)
    self.print(text.to_s + "\n")
  end

  def self.read_until(*flag_chars)
    read_text = ''
    last_char = nil

    begin
      char = @c_win.getch

      case(char)
        when 8 #Backspace
          unless read_text.empty?
            read_text = read_text[0..-2]
            self.move_cursor(-1, 0)
            @c_win.delch
          end
        when 9 #Tab
          if flag_chars.include?(TAB)
            last_char = TAB
            break
          end
        when 10 #Enter
          if flag_chars.include?(ENTER)
            last_char = ENTER
            @c_win<<"\n"
            break
          end
        else
          #Normal operation
          read_text<<char
          @c_win<<char
      end
    end while(true)

    ReadResult.new(read_text, last_char)
  end

  def self.move_cursor(x_offset, y_offset)
    @c_win.setpos(@c_win.cury + y_offset, @c_win.curx + x_offset)
  end
end

class ReadResult
  attr_reader :text, :last_char

  def initialize(text, last_char)
    @text = text
    @last_char = last_char
  end
end