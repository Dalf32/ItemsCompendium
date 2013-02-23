#CompendiumCommands.rb

module ErrorRescue
	def rescue_error(error)
		puts "#{error}\nError occurred, retry operation."
	end
end

class DefaultCommand
	def execute(state, params)
		puts "Unrecognized command."
	end
end

class QuitCommand
	def execute(state, params)
		puts "Goodbye."
		CommandProcessor::QUIT
	end

	def get_help
		helpStr = ""
		helpStr<<"Quit, Close, Exit\n"
		helpStr<<"Terminates the ItemsCompendium."
	end
end

class SearchCommand
	include ErrorRescue

	def execute(state, params)
		if(params.empty? || params.size > 3)
			puts "Invalid query."
			return
		end

		if(params.size == 3)
			dbName = params[0]
			field = params[1]
			searchTerms = params[2].split(";")

			state.search_db(dbName, searchTerms, field)
		elsif(params.size == 2)
			field = params[0]
			searchTerms = params[1].split(";")

			state.search_all(searchTerms, field)
		elsif(params.size == 1)
			searchTerms = params[0].split(";")

			state.search_all(searchTerms)
		end

		if(state.lastQuery != nil)
			puts state.lastQuery
			puts "#{state.lastQuery.numItems} results."
		else
			puts "No results."
		end
	end

	def get_help
		helpStr = ""
		helpStr<<"Search [Type] [Field] <Query>\n"
		helpStr<<"Searches indexed Items for matches to the given Query. The search is limited to the given Type and Field if provided.\n"
		helpStr<<"If Type is not provided then the entire Compendium is searched. If Field is not provided then the first field (usually a name) is searched. If Type is provided, then Field must also be provided."
	end
end

class RefineCommand
	include ErrorRescue

	def execute(state, params)
		if(state.lastQuery == nil)
			puts "No previous query results."
			return
		elsif(params.empty? || params.size > 2)
			puts "Invalid query."
			return
		end

		if(params.size == 2)
			field = params[0]
			searchTerms = params[1].split(";")

			state.search_last_query(searchTerms, field)
		elsif(params.size == 1)
			searchTerms = params[0].split(";")

			state.search_last_query(searchTerms)
		end

		#Print the results of the query if successful
		if(state.lastQuery != nil)
			puts state.lastQuery
			puts "#{state.lastQuery.numItems} results."
		else
			puts "No results."
		end
	end

	def get_help
		helpStr = ""
		helpStr<<"Refine [Field] <Query>\n"
		helpStr<<"Refines the previous query results by searching it for matches to the given Query. The search is limited to the given Field if provided.\n"
		helpStr<<"If Field is not provided then the first field (usually a name) is searched."
	end
end

class DumpCommand
	def execute(state, params)
		itemTotal = 0

		if(params.empty?)
			state.dbHash.each_pair{|dbName, db|
				puts "#{dbName.pretty}:"
				puts db
				
				itemTotal += db.numItems
			}
		else
			db = state.dbHash[params[0]]

			puts "#{params[0]}:"
			puts db
			
			itemTotal = db.numItems
		end

		puts "#{itemTotal} items."
	end

	def get_help
		"Prints out all Items indexed by the Compendium."
	end
end

class TypesCommand
	def execute(state, params)
		puts "Item Types:"

		state.dbHash.each_pair{|dbName, db|
			puts "  #{dbName.pretty}: #{db.numItems}"
		}
	end

	def get_help
		"Prints out a list of all the database types indexed by the Compendium."
	end
end

class FieldsCommand
	def execute(state, params)
		puts "Fields by Type:"

		state.dbHash.each_pair{|dbName, db|
			puts "  #{dbName.pretty}: #{db.fields}"
		}
	end

	def get_help
		"Prints out the fields used in each of the datases indexed by the Compendium."
	end
end

class SelectCommand
	include ErrorRescue

	def execute(state, params)
		selectCount = 1
		fromCount = state.count_items

		if(params.empty?)
			state.select
		else
			selectCount = params[0].to_i
			state.select(selectCount)
		end

		if(state.lastQuery != nil)
			fromCount = state.lastQuery.numItems
		end

		puts "Selecting #{selectCount} from #{fromCount}:"

		state.selectedItems.map{|item|
			puts "#{item}\n"
		}
	end

	def get_help
		helpStr = ""
		helpStr<<"Select [N]\n"
		helpStr<<"Chooses N items at random from the last query results or from the entire Compendium if there are no previous results.\n"
		helpStr<<"If N is not provided, then only 1 item is selected."
	end
end

class SaveCommand
	include ErrorRescue

	def execute(state, params)
		if(state.lastQuery == nil)
			puts "No previous query results."
		end

		outfile = "Items-#{Time.now.to_i}.txt"

		if(!params.empty?)
			outfile = "#{params[0]}.txt"
		end

		File.open(outfile, "w"){|fileIO|
			fileIO<<state.lastQuery
		}
	end

	def get_help
		helpStr = ""
		helpStr<<"Save [Name]\n"
		helpStr<<"Saves previous query results to a file with the given Name or the current time (in milliseconds) if Name is not provided."
	end
end

class SaveSelectedCommand
	include ErrorRescue
	
	def execute(state, params)
		if(state.selected == nil)
			puts "No selected items."
			return
		end

		outfile = "Items-#{Time.now.to_i}.txt"

		if(!params.empty?)
			outfile = "#{params[0]}.txt"
		end

		File.open(outfile, "w"){|fileIO|
			state.selectedItems.map{|item|
				fileIO<<"#{item}\n"
			}
		}
	end

	def get_help
		helpStr = ""
		helpStr<<"SaveSelected [Name]\n"
		helpStr<<"Saves previous selections to a file with the given Name or the current time (in milliseconds) if Name is not provided."
	end
end

class ClearCommand
	def execute(state, params)
		state.clear_selected
		state.clear_last_query
	end

	def get_help
		"Clears all previous query results and selections."
	end
end

class ShowExtendedCommand
	def execute(state, params)
		if(state.selectedItems != nil)
			state.selectedItems.map{|item|
				puts "#{item.to_s(true)}\n"
			}

			puts "#{state.selectedItems.count} items."
		elsif(state.lastQuery != nil)
			puts state.lastQuery.to_s(true)
			puts "#{state.lastQuery.numItems} items."
		else
			puts "No previous query results."
		end
	end

	def get_help
		"Displays extended fields for previous selections or last query results if there are no previous selections."
	end
end

class CountCommand
	def execute(state, params)
		countStr = "Selected: "

		if(state.selectedItems != nil)
			countStr<<"#{state.selectedItems.length}\n"
		else
			countStr<<"0\n"
		end

		countStr<<"Last Query: "

		if(state.lastQuery != nil)
			countStr<<"#{state.lastQuery.numItems}\n"
		else
			countStr<<"0\n"
		end

		countStr<<"Total: #{state.count_items}"

		puts countStr
	end

	def get_help
		"Displays the number of Items selected, in the current query, and the total indexed by the Compendium."
	end
end

class HelpCommand
	:comProc

	def initialize(comProc)
		@comProc = comProc
	end

	def execute(state, params)
		@comProc.show_help(params)
	end

	def get_help
		helpStr = ""
		helpStr<<"Help [Command]\n"
		helpStr<<"Prints the list of available commands or help for the given Command."
	end
end
