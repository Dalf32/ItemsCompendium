#ItemsCompendium.rb

require_relative 'ItemDB'
require_relative 'CommandProcessor'
require_relative 'CompendiumCommands'

class ItemsCompendium
	attr_reader :dbHash, :lastQuery, :selectedItems

	def initialize
		@dbHash = Hash.new
		@lastQuery = nil
		@selectedItems = nil
	end

	def add_db(dbName, db)
		@dbHash[dbName] = db
	end

	def count_items
		itemCount = 0

		@dbHash.each_value{|db|
			itemCount += db.numItems
		}

		itemCount
	end

	def search_all(searchTerms, field = nil)
		results = nil
		clear_selected

		searchTerms.each{|value|
			@dbHash.each_value{|db|
				if(results == nil)
					if(field != nil)
						results = db.query(field, value)
					else
						results = db.query(value)
					end
				else
					if(field != nil)
						results = results.merge(db.query(field, value))
					else
						results = results.merge(db.query(value))
					end
				end
			}
		}

		@lastQuery = results
	end

	def search_db(dbName, searchTerms, field = nil)
		results = nil
		clear_selected

		if(@dbHash.has_key?(dbName))
			searchTerms.each{|value|
				if(results == nil)
					if(field != nil)
						results = @dbHash[dbName].query(field, value)
					else
						results = @dbHash[dbName].query(value)
					end
				else
					if(field != nil)
						results = results.merge(@dbHash[dbName].query(field, value))
					else
						results = results.merge(@dbHash[dbName].query(value))
					end
				end
			}
		end

		@lastQuery = results
	end

	def search_last_query(searchTerms, field = nil)
		results = nil
		clear_selected

		searchTerms.each{|value|
			if(results == nil)
				if(field != nil)
					results = @lastQuery.query(field, value)
				else
					results = @lastQuery.query(value)
				end
			else
				if(field != nil)
					results = results.merge(@lastQuery.query(field, value))
				else
					results = results.merge(@lastQuery.query(value))
				end
			end
		}

		@lastQuery = results
	end

	def select(selectCount = 1)
		selectDB = nil
		@selectedItems = Array.new

		if(lastQuery != nil)
			selectDB = lastQuery
		else
			dbHash.each_value{|db|
				selectDB = db.merge(selectDB)
			}
		end
		
		selectCount.times{|count|
			@selectedItems[count] = selectDB.select
		}
	end

	def clear_selected
		@selectedItems = nil
	end

	def clear_last_query
		@lastQuery = nil
	end
end

def parseDBfile(dbfile)
	lineCount = 0
	db = nil

	File.open(dbfile){|fileIO|
		fileIO.each_line{|line|
			splitLine = line.strip.split(",")

			if(lineCount == 0)
				db = ItemDB.new(splitLine)
			else
				db.addItem(splitLine)
			end

			lineCount += 1
		}
	}

	db
end

def search(dbs, params)
	results = nil
	db = nil

	if(dbs.kind_of?(ItemDB))
		db = dbs
	end

	if(params.size >= 2)
		if(params.size == 3)
			dbName = params[0]
			params = params[1..-1]

			if(dbs.kind_of?(Hash) && dbs.has_key?(dbName))
				db = dbs[dbName]
			end
		end

		field = params[0]
		values = params[1].split(";")

		#Query the proper database(s) for matches
		if(db != nil)
			values.each{|value|
				if(results == nil)
					results = db.query(field, value)
				else
					results = results.merge(db.query(field, value))
				end
			}
		else
			values.each{|value|
				dbs.each_value{|idb|
					if(results == nil)
						results = idb.query(field, value)
					else
						results = results.merge(idb.query(field, value))
					end
				}
			}
		end
	elsif(params.size == 1)
		values = params[0].split(";")

		#Query every database for matches
		if(db != nil)
			values.each{|value|
				if(results == nil)
					results = db.query(value)
				else
					results = results.merge(db.query(value))
				end
			}
		else
			values.each{|value|
				dbs.each_value{|idb|
					if(results == nil)
						results = idb.query(value)
					else
						results = results.merge(idb.query(value))
					end
				}
			}
		end
	end

	results
end

def getHelp(cmd)
	outStr = ""

	case cmd
	when "quit", "close", "exit"
		outStr<<"Terminates the ItemsCompendium."
	when "search"
		outStr<<"Search [Type] [Field] <Query>\n"
		outStr<<"Searches indexed Items for matches to the given Query. The search is limited to the given Type and Field if provided.\n"
		outStr<<"If Type is not provided then the entire Compendium is searched. If Field is not provided then the first field (usually a name) is searched. If Type is provided, then Field must also be provided."
	when "refine"
		outStr<<"Refine [Field] <Query>\n"
		outStr<<"Refines the previous query results by searching it for matches to the given Query. The search is limited to the given Field if provided.\n"
		outStr<<"If Field is not provided then the first field (usually a name) is searched."
	when "dump"
		outStr<<"Dump\n"
		outStr<<"Prints out all Items indexed by the Compendium."
	when "types"
		outStr<<"Types\n"
		outStr<<"Prints out a list of all the database types indexed by the Compendium."
	when "fields"
		outStr<<"Fields\n"
		outStr<<"Prints out the fields used in each of the datases indexed by the Compendium."
	when "select"
		outStr<<"Select [N]\n"
		outStr<<"Chooses N items at random from the last query results or from the entire Compendium if there are no previous results.\n"
		outStr<<"If N is not provided, then only 1 item is selected."
	when "save"
		outStr<<"Save [Name]\n"
		outStr<<"Saves previous query results to a file with the given Name or the current time (in milliseconds) if Name is not provided."
	when "saveselected"
		outStr<<"SaveSelected [Name]\n"
		outStr<<"Saves previous selections to a file with the given Name or the current time (in milliseconds) if Name is not provided."
	when "clear"
		outStr<<"Clear\n"
		outStr<<"Clears all previous query results and selections."
	when "showextended"
		outStr<<"ShowExtended\n"
		outStr<<"Displays extended fields for previous selections or last query results if there are no previous selections."
	when "help"
		outStr<<"Help [Command]\n"
		outStr<<"Prints the list of available commands or help for the given Command."
	else
		outStr<<"Unrecognized command."
	end

	outStr
end

#MAIN
queryPrompt = "\n:>"
dbExt = ".db"

dbHash = Hash.new
lastQuery = nil
selectedItems = nil
dbDir = "."

if(ARGV.length == 1)
	dbDir = ARGV[0]
end

compendium = ItemsCompendium.new

Dir.new("#{Dir.pwd}/#{dbDir}").each{|filename|
	if(filename.end_with?(dbExt))
		dbHash[File.basename(filename, dbExt).downcase] = parseDBfile("#{dbDir}/#{filename}")
		compendium.add_db(File.basename(filename, dbExt).downcase, parseDBfile("#{dbDir}/#{filename}"))
	end
}

comProc = CommandProcessor.new(queryPrompt, DefaultCommand.new)
comProc.register_command(QuitCommand.new, "quit", "close", "exit")
comProc.register_command(SearchCommand.new, "search")
comProc.register_command(RefineCommand.new, "refine")
comProc.register_command(DumpCommand.new, "dump")
comProc.register_command(TypesCommand.new, "types")
comProc.register_command(FieldsCommand.new, "fields")
comProc.register_command(SelectCommand.new, "select")
comProc.register_command(SaveCommand.new, "save")
comProc.register_command(SaveSelectedCommand.new, "saveselected")
comProc.register_command(ClearCommand.new, "clear")
comProc.register_command(ShowExtendedCommand.new, "showextended")
comProc.register_command(CountCommand.new, "count")
comProc.register_command(HelpCommand.new(comProc), "help")

comProc.loop(compendium)
exit(true)

print "#{queryPrompt}"

$stdin.each{|input|
	input = input.downcase.strip
	command = input.split[0]
	params = input.split[1..-1]

	if(["quit", "close", "exit"].include?(input))
		puts "Goodbye."
		break

	elsif(command.eql?("search"))
		if(params.empty? || params.size > 3)
			puts "Invalid query."
		end

		selectedItems = nil
		lastQuery = search(dbHash, params)

		#Print the results of the query if successful
		if(lastQuery != nil)
			puts lastQuery
			puts "#{lastQuery.numItems} results."
		else
			puts "No results."
		end

	elsif(command.eql?("refine"))
		if(lastQuery == nil)
			puts "No previous query results."
		elsif(params.empty? || params.size > 2)
			puts "Invalid query."
		else
			selectedItems = nil
			lastQuery = search(lastQuery, params)

			#Print the results of the query if successful
			if(lastQuery != nil)
				puts lastQuery
				puts "#{lastQuery.numItems} results."
			else
				puts "No results."
			end
		end

	elsif(command.eql?("dump"))
		itemTotal = 0

		if(params.empty?)
			dbHash.each_pair{|dbName, db|
				puts "#{dbName.pretty}:"
				puts db
				
				itemTotal += db.numItems
			}
		else
			db = dbHash[params[0]]

			puts "#{params[0]}:"
			puts db
			
			itemTotal = db.numItems
		end

		puts "#{itemTotal} items."

	elsif(command.eql?("types"))
		puts "Item Types:"

		dbHash.each_key{|dbName|
			puts "  #{dbName.pretty}"
		}

	elsif(command.eql?("fields"))
		puts "Fields by Type:"

		dbHash.each_pair{|dbName, db|
			puts "  #{dbName.pretty}: #{db.fields}"
		}

	elsif(command.eql?("select"))
		itemCount = 0
		selectCount = 1
		selectDB = nil
		selectedItems = Array.new

		if(!params.empty?)
			selectCount = params[0].to_i
		end

		if(lastQuery != nil)
			selectDB = lastQuery
		else
			dbHash.each_value{|db|
				selectDB = db.merge(selectDB)
			}
		end

		itemCount = selectDB.numItems
		
		selectCount.times{|count|
			selectedItems[count] = selectDB.select
		}

		puts "Selecting #{selectCount} from #{itemCount}:"

		selectedItems.map{|item|
			puts "#{item}\n"
		}

	elsif(command.start_with?("save"))
		if(lastQuery == nil)
			puts "No previous query results."
		else
			outfile = "Items-#{Time.now.to_i}.txt"

			if(!params.empty?)
				outfile = "#{params[0]}.txt"
			end

			if(command.eql?("saveselected"))
				if(selectedItems == nil)
					puts "No selected items."
				else
					File.open(outfile, "w"){|fileIO|
						selectedItems.map{|item|
							fileIO<<"#{item}\n"
						}
					}
				end
			else
				File.open(outfile, "w"){|fileIO|
					fileIO<<lastQuery
				}
			end
		end

	elsif(command.eql?("clear"))
		selectedItems = nil
		lastQuery = nil

	elsif(command.eql?("showextended"))
		if(selectedItems != nil)
			selectedItems.map{|item|
				puts "#{item.to_s(true)}\n"
			}

			puts "#{selectedItems.count} items."
		elsif(lastQuery != nil)
			puts lastQuery.to_s(true)
			puts "#{lastQuery.numItems} items."
		else
			puts "No previous query results."
		end

	elsif(command.eql?("help"))
		if(params.empty?)
			puts "Available Commands:\n"

			["Quit", "Close", "Exit", "Search", "Refine", "Dump", "Types", "Fields",
				"Select", "Save", "SaveSelected", "Clear", "ShowExtended", "Help"].map{|cmd|
				puts "  #{cmd}"
			}
		else
			puts getHelp(params[0])
		end
	else
		puts "Invalid Command."
	end

	print queryPrompt
}
