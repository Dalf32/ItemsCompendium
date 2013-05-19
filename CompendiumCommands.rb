#CompendiumCommands.rb

##
# Mixin to perform default error recovery for commands by simply printing the error.
##
module ErrorRescue
	def rescue_error(error)
		UserIO::puts "#{error}\nError occurred, retry operation."
	end
end

##
# The default command used whenever the user inputs an unrecognized command. This is excluded from the command history.
##
class DefaultCommand
	def execute(_state, _params)
		UserIO::puts 'Unrecognized command.'

    CommandProcessor::EXCLUDE
	end
end

##
# Command used when the user inputs nothing
##
class EmptyCommand
  def execute(_state, _params)
    CommandProcessor::EXCLUDE
  end
end

##
# Exits the CommandProcessor loop.
##
class QuitCommand
	def execute(_state, _params)
		UserIO::puts 'Goodbye.'
		CommandProcessor::QUIT
	end

	def get_help
		help_str = ''
		help_str<<"Quit, Close, Exit\n"
		help_str<<'Terminates the ItemsCompendium.'
	end
end

##
# Searches the ItemsCompendium for matches to the input query.
##
class SearchCommand
	include ErrorRescue

	def execute(state, params)
		if params.empty? || params.size > 3
			UserIO::puts 'Invalid query.'
			return
		end

		if params.size == 3
			db_name = params[0]
			field = params[1]
			search_terms = params[2].split(';')

			state.search_db(db_name, search_terms, field)
		elsif params.size == 2
			field = params[0]
			search_terms = params[1].split(';')

			state.search_all(search_terms, field)
		elsif params.size == 1
			search_terms = params[0].split(';')

			state.search_all(search_terms)
		end

		if state.last_query != nil
			UserIO::puts state.last_query.to_s(true)
			UserIO::puts "#{state.last_query.numItems} results."
		else
			UserIO::puts 'No results.'
		end
	end

	def get_help
		help_str = ''
		help_str<<"Search [Type] [Field] <Query>\n"
		help_str<<"Searches indexed Items for matches to the given Query. The search is limited to the given Type and Field if provided.\n"
		help_str<<'If Type is not provided then the entire Compendium is searched. If Field is not provided then the first field (usually a name) is searched. If Type is provided, then Field must also be provided.'
	end
end

##
# Refines the last search of the ItemsCompendium with a new query input by the user.
##
class RefineCommand
	include ErrorRescue

	def execute(state, params)
		if state.last_query == nil
			UserIO::puts 'No previous query results.'
			return
		elsif params.empty? || params.size > 2
			UserIO::puts 'Invalid query.'
			return
		end

		if params.size == 2
			field = params[0]
			search_terms = params[1].split(';')

			state.search_last_query(search_terms, field)
		elsif params.size == 1
			search_terms = params[0].split(';')

			state.search_last_query(search_terms)
		end

		#Print the results of the query if successful
		if state.last_query != nil
			UserIO::puts state.last_query.to_s(true)
      UserIO::puts "#{state.last_query.numItems} results."
		else
      UserIO::puts 'No results.'
		end
	end

	def get_help
      help_str = ''
		help_str<<"Refine [Field] <Query>\n"
		help_str<<"Refines the previous query results by searching it for matches to the given Query. The search is limited to the given Field if provided.\n"
		help_str<<'If Field is not provided then the first field (usually a name) is searched.'
	end
end

##
# Prints the entire set of indexed Items or the Items in one of the ItemDBs.
##
class DumpCommand
	def execute(state, params)
		item_total = 0

		if params.empty?
			state.db_hash.each_pair{|dbName, db|
        UserIO::puts "#{dbName.pretty}:"
        UserIO::puts db
				
				item_total += db.numItems
			}
		else
			db = state.db_hash[params[0]]

      UserIO::puts "#{params[0]}:"
      UserIO::puts db
			
			item_total = db.numItems
		end

    UserIO::puts "#{item_total} items."
	end

	def get_help
    'Prints out all Items indexed by the Compendium.'
	end
end

##
# Prints out the list of ItemDBs as 'Types' of Items.
##
class TypesCommand
	def execute(state, _params)
    UserIO::puts 'Item Types:'

		state.db_hash.each_pair{|dbName, db|
      UserIO::puts "  #{dbName.pretty}: #{db.numItems}"
		}
	end

	def get_help
    'Prints out a list of all the database types indexed by the Compendium.'
	end
end

##
# Prints out the list of fields used by each Item Type.
##
class FieldsCommand
	def execute(state, _params)
    UserIO::puts 'Fields by Type:'

		state.db_hash.each_pair{|dbName, db|
      UserIO::puts "  #{dbName.pretty}: #{db.fields}"
		}
	end

	def get_help
    'Prints out the fields used in each of the datases indexed by the Compendium.'
	end
end

##
# Randomly picks Items from the last set of query results or the entire Compendium.
##
class SelectCommand
	include ErrorRescue

	def execute(state, params)
		select_count = 1
		from_count = state.count_items

		if params.empty?
			state.select
		else
			select_count = params[0].to_i
			state.select(select_count)
		end

		if state.last_query != nil
			from_count = state.last_query.numItems
		end

    UserIO::puts "Selecting #{select_count} from #{from_count}:"
    UserIO::puts state.selected_to_s
	end

	def get_help
		help_str = ''
		help_str<<"Select [N]\n"
		help_str<<"Picks N items at random from the last query results or from the entire Compendium if there are no previous results.\n"
		help_str<<'If N is not provided, then only 1 item is selected.'
	end
end

##
# Saves the last set of query results to a file.
##
class SaveCommand
	include ErrorRescue

	def execute(state, params)
		if state.last_query == nil
      UserIO::puts 'No previous query results.'
		end

		outfile = "Items-#{Time.now.to_i}.txt"

    unless params.empty?
      outfile = "#{params[0]}.txt"
    end

		File.open(outfile, 'w'){|fileIO|
			fileIO<<state.last_query.to_s(false, true)
		}
	end

	def get_help
		help_str = ''
		help_str<<"Save [Name]\n"
		help_str<<'Saves previous query results to a file with the given Name or the current time (in milliseconds) if Name is not provided.'
	end
end

##
# Saves the subset of the last query results currently selected to a file.
##
class SaveSelectedCommand
	include ErrorRescue
	
	def execute(state, params)
		if state.selected_items == nil
      UserIO::puts 'No selected items.'
			return
		end

		outfile = "Items-#{Time.now.to_i}.txt"

    unless params.empty?
      outfile = "#{params[0]}.txt"
    end

		File.open(outfile, 'w'){|fileIO|
			fileIO<<state.selected_to_s(false, true)
		}
	end

	def get_help
		help_str = ''
		help_str<<"SaveSelected [Name]\n"
		help_str<<'Saves previous selections to a file with the given Name or the current time (in milliseconds) if Name is not provided.'
	end
end

##
# Clears both the last query results and the specifically selected results.
##
class ClearCommand
	def execute(state, _params)
		state.clear_selected
		state.clear_last_query
	end

	def get_help
    'Clears all previous query results and selections.'
	end
end

##
# Shows either the selected Items or the last query results with hidden fields shown.
##
class ShowExtendedCommand
	def execute(state, _params)
		if state.selected_items != nil
      UserIO::puts state.selected_to_s(false, true)
      UserIO::puts "#{state.selected_items.count} items."
		elsif state.last_query != nil
      UserIO::puts state.last_query.to_s(true, true)
      UserIO::puts "#{state.last_query.numItems} items."
		else
      UserIO::puts 'No previous query results.'
		end
	end

	def get_help
    'Displays extended fields for previous selections or last query results if there are no previous selections.'
	end
end

##
# Counts the total number of Items in the Compendium as well as the Items in the set of previous query results and the
# Items specifically selected by the user.
##
class CountCommand
	def execute(state, _params)
		count_str = 'Selected: '

		if state.selected_items != nil
			count_str<<"#{state.selected_items.length}\n"
		else
			count_str<<"0\n"
		end

		count_str<<'Last Query: '

		if state.last_query != nil
			count_str<<"#{state.last_query.numItems}\n"
		else
			count_str<<"0\n"
		end

		count_str<<"Total: #{state.count_items}"

    UserIO::puts count_str
	end

	def get_help
    'Displays the number of Items selected, in the current query, and the total indexed by the Compendium.'
	end
end

##
# Prints the command history and allows the user to re-execute a previously entered command.
##
class HistoryCommand
  @command_proc

  def initialize(com_proc)
    @command_proc = com_proc
  end

  def execute(state, params)
    com_history = @command_proc.command_history

    if params.empty?
      com_history.length.times{|command_index|
        UserIO::puts "#{command_index + 1}. #{com_history[command_index]}"
      }
    else
      command_index = params[0].to_i

      if (1..com_history.length).include?(command_index)
        com_pair = com_history[command_index - 1]

        @command_proc.execute_command(com_pair[0], com_pair[1], state)
      else
        UserIO::puts 'Selected command number out of range.'
      end
    end

    CommandProcessor::EXCLUDE
  end

  def get_help
    help_str = ''
    help_str<<"History [I]\n"
    help_str<<"Displays the last 10 commands executed.\n"
    help_str<<'If I is provided, then the command with the given index is re-executed.'
  end
end

##
# Picks Items from the set of last query results by index (not randomly).
##
class ChooseCommand
  include ErrorRescue

  def execute(state, params)
    if params.empty?
      UserIO::puts 'Must provide the index of an item.'
      return
    elsif state.last_query == nil
      UserIO::puts 'No previous query results to choose from.'
      return
    end

    if params.length == 1
      chosen_indices = params[0].split(';').map{|index| index.to_i - 1}
      state.choose(chosen_indices)
    elsif params.length == 2
      range_start = params[0].to_i - 1
      range_end = params[1].to_i - 1

      state.choose_range(range_start, range_end)
    else
      UserIO::puts 'Invalid parameters.'
      return
    end

    if state.selected_items.empty?
      UserIO::puts 'No results.'
    else
      UserIO::puts "Chose #{state.selected_items.length} items:\n"
      UserIO::puts state.selected_to_s
    end
  end

  def get_help
    help_str = ''
    help_str<<"Choose <Query> [Range_End]\n"
    help_str<<"Selects the items from the previous query results with the index (or indices) provided.\n"
    help_str<<'If Range_End is provided, then Query is treated as Range_Start and all items with an index between Range_Start and Range_End in the previous query results are chosen.'
  end
end

##
# Displays the list of commands or displays help for a specific command.
##
class HelpCommand
	@command_proc

	def initialize(com_proc)
		@command_proc = com_proc
	end

	def execute(_state, params)
    commands = @command_proc.command_set

    if params.empty?
      UserIO::puts 'Available commands:'

      commands.each_key{|commandName|
        UserIO::puts "  #{commandName}"
      }
    else
      if commands.has_key?(params[0])
        UserIO::puts commands[params[0]].get_help
      else
        UserIO::puts 'Command not available.'
      end
    end
	end

	def get_help
		help_str = ''
		help_str<<"Help [Command]\n"
		help_str<<'Prints the list of available commands or help for the given Command.'
	end
end
