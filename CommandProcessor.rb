#CommandProcessor.rb

require 'securerandom'

class CommandProcessor
	#This acts like an atom; the value doesn't matter, it just needs to be unique 
	QUIT = SecureRandom.uuid

	attr_accessor :promptStr
	:commandSet
	:continue

	def initialize(prompt, defaultCommand)
		@commandSet = Hash.new(defaultCommand)
		@promptStr = prompt
		@continue = true
	end

	def loop(state)
		print @promptStr

		$stdin.each_line{|input|
			input = input.downcase.strip
			command = input.split[0]
			params = input.split[1..-1]

			begin
				if(@commandSet[command].execute(state, params) == QUIT)
					break
				end
			rescue => error
				@commandSet[command].rescue_error(error)
			end

			print @promptStr
		}
	end

	def show_help(params)
		if(params.empty?)
			puts "Available commands:"

			@commandSet.each_key{|commandName|
				puts "  #{commandName}"
			}
		else
			if(@commandSet.has_key?(params[0]))
				puts params[0]
				puts @commandSet[params[0]].get_help
			else
				puts "Command not available."
			end
		end
	end

	def register_command(command, *commandNames)
		commandNames.each{|commandName|
			@commandSet[commandName.downcase] = command
		}
	end
end
