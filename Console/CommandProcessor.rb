#CommandProcessor.rb

require 'curses'

require_relative 'UserIO'
require_relative '../Utilities/RingBuffer'

##
# This class is a simple, generic way to add a command-based terminal prompt to an application. To use, register
# one or more command objects implementing a few required functions, give the objects one or more names, and execute the
# loop function.
#
# The following functions should be implemented by commands:
#   execute(state, params)
#   rescue_error(error)
#   get_help
##
class CommandProcessor
  # Flag which should be returned by a command's execute function if the CommandProcessor should cease looping
	QUIT = :quit

  # Flag which should be returned by a command's execute function if it should not be included in the command history
  EXCLUDE = :exclude

	attr_accessor :prompt_str
  attr_reader :command_history, :command_set

  ##
  # Creates a new CommandProcessor with only a default command which will be executed when the user inputs an invalid
  # command name.
  ##
	def initialize(prompt, default_command, io_method = UserIO::CURSES, history_size = 10)
		@command_set = Hash.new(default_command)
		@prompt_str = prompt
    @command_history = RingBuffer.new(history_size)

    UserIO.use(io_method)
	end

  ##
  # Starts the input loop and will not return until one of the commands returns the QUIT flag from its execute function.
  # The loop state is passed to the commands upon execution and should provide them with all they need to operate.
  ##
	def loop(state)
    new_prompt = true
    result = nil
    input_text = ''

    begin
      if new_prompt
        UserIO::print @prompt_str
      end

      new_prompt = true
      input = UserIO.read_until(UserIO::TAB, UserIO::ENTER)
      input_text<<input.text

      if input.last_char == UserIO::TAB
        #Tab completion
        completed = complete_command_name(input.text)
        input_text<<completed
        UserIO::print completed

        new_prompt = false
      elsif input.last_char == UserIO::ENTER
        #Normal operation
        command = input_text.downcase.split[0]
        params = input_text.split[1..-1]
        input_text = ''

        if command == nil
          command = ''
        end

        result = execute_command(command, params, state)
      end
    end while(result != QUIT)
  end

  ##
  # Executes the command with the given name and passes it the given parameters and loop state. This function also adds
  # the executed command to the command history unless it returned EXCLUDE from its execute function.
  ##
  def execute_command(command, params, state)
    retval = nil

    begin
      retval = @command_set[command.strip].execute(state, params)
    rescue => error
      retval = @command_set[command.strip].rescue_error(error)
    end

    @command_history.push([command, params]) unless retval == EXCLUDE

    retval
  end

  ##
  # Registers the given command object with the given name or names. The command may now be executed by entering any one
  # of the provided names at the CommandProcessor prompt.
  ##
	def register_command(command, *command_names)
		command_names.each{|commandName|
			@command_set[commandName.downcase] = command
		}
  end

  private

  def complete_command_name(input)
    completed_name = ''

    @command_set.each_key{|commandName|
      if commandName.start_with?(input)
        completed_name = commandName[input.length..-1]
        break
      end
    }

    completed_name
  end
end
