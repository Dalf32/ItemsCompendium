#CommandProcessor.rb

require_relative 'RingBuffer'

class CommandProcessor
	QUIT = :quit
  EXCLUDE = :exclude

	attr_accessor :prompt_str
  attr_reader :command_history
  @command_set
  @continue

	def initialize(prompt, default_command, history_size = 10)
		@command_set = Hash.new(default_command)
		@prompt_str = prompt
		@continue = true
    @command_history = RingBuffer.new(history_size)
	end

	def loop(state)
		print @prompt_str

		$stdin.each_line{|input|
			input = input.downcase.strip
			command = input.split[0]
			params = input.split[1..-1]

      if execute_command(command, params, state) == QUIT
			  break
      end

      print @prompt_str
		}
  end

  def execute_command(command, params, state)
    retval = nil

    begin
      retval = @command_set[command].execute(state, params)
    rescue => error
      retval = @command_set[command].rescue_error(error)
    end

    if retval != EXCLUDE
      @command_history.push([command, params])
    end

    retval
  end

	def show_help(params)
		if params.empty?
			puts 'Available commands:'

			@command_set.each_key{|commandName|
				puts "  #{commandName}"
			}
		else
			if @command_set.has_key?(params[0])
				puts @command_set[params[0]].get_help
			else
				puts 'Command not available.'
			end
		end
	end

	def register_command(command, *command_names)
		command_names.each{|commandName|
			@command_set[commandName.downcase] = command
		}
  end
end
