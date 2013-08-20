#CursesIO.rb

require 'curses'

require_relative 'UserIO'

module CursesIO
  @c_win

  def init
    @c_win = Curses.stdscr
    Curses.init_screen
    Curses.noecho
    @c_win.scrollok(true)
  end

  def print(text)
    @c_win<<text
    @c_win.refresh
  end

  def puts(text)
    print(text.to_s + "\n")
  end

  def read_until(*flag_chars)
    read_text = ''
    last_char = nil

    begin
      char = @c_win.getch

      case(char)
        when 8 #Backspace
          unless read_text.empty?
            read_text = read_text[0..-2]
            move_cursor(-1, 0)
            @c_win.delch
          end
        when 9 #Tab
          if flag_chars.include?(UserIO::TAB)
            last_char = UserIO::TAB
            break
          end
        when 10 #Enter
          if flag_chars.include?(UserIO::ENTER)
            last_char = UserIO::ENTER
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

  private

  def move_cursor(x_offset, y_offset)
    @c_win.setpos(@c_win.cury + y_offset, @c_win.curx + x_offset)
  end
end
