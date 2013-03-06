#CommandProcessor.rb

class CommandProcessor
	QUIT = :quit

	attr_accessor :prompt_str
	@command_set
	@continue
  @command_history

	def initialize(prompt, default_command, history_size)
		@command_set = Hash.new(default_command)
		@prompt_str = prompt
		@continue = true
    @command_history = Array.new(history_size)
	end

	def loop(state)
		print @prompt_str

		$stdin.each_line{|input|
			input = input.downcase.strip
			command = input.split[0]
			params = input.split[1..-1]

			begin
				if @command_set[command].execute(state, params) == QUIT
					break
				end
			rescue => error
				@command_set[command].rescue_error(error)
			end

			print @prompt_str
		}
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
