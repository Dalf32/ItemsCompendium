#ItemsCompendium.rb

require_relative 'ItemDB'
require_relative 'CommandProcessor'
require_relative 'CompendiumCommands'

class ItemsCompendium
	attr_reader :db_hash, :last_query, :selected_items

	def initialize
		@db_hash = Hash.new
		@last_query = nil
		@selected_items = nil
	end

	def add_db(db_name, db)
		@db_hash[db_name] = db
	end

	def count_items
		item_count = 0

		@db_hash.each_value{|db|
			item_count += db.numItems
		}

		item_count
	end

	def search_all(search_terms, field = nil)
		results = nil
		clear_selected

		search_terms.each{|value|
			@db_hash.each_value{|db|
				if results == nil
					if field != nil
						results = db.query(field, value)
					else
						results = db.query(value)
					end
				else
					if field != nil
						results = results.merge(db.query(field, value))
					else
						results = results.merge(db.query(value))
					end
				end
			}
		}

		@last_query = results
	end

	def search_db(db_name, search_terms, field = nil)
		results = nil
		clear_selected

		if @db_hash.has_key?(db_name)
			search_terms.each{|value|
				if results == nil
					if field != nil
						results = @db_hash[db_name].query(field, value)
					else
						results = @db_hash[db_name].query(value)
					end
				else
					if field != nil
						results = results.merge(@db_hash[db_name].query(field, value))
					else
						results = results.merge(@db_hash[db_name].query(value))
					end
				end
			}
		end

		@last_query = results
	end

	def search_last_query(search_terms, field = nil)
		results = nil
		clear_selected

		search_terms.each{|value|
			if results == nil
				if field != nil
					results = @last_query.query(field, value)
				else
					results = @last_query.query(value)
				end
			else
				if field != nil
					results = results.merge(@last_query.query(field, value))
				else
					results = results.merge(@last_query.query(value))
				end
			end
		}

		@last_query = results
	end

	def select(select_count = 1)
		select_db = nil
		@selected_items = Array.new

		if last_query != nil
			select_db = last_query
		else
			db_hash.each_value{|db|
				select_db = db.merge(select_db)
			}
		end
		
		select_count.times{|count|
			@selected_items[count] = select_db.select
		}
	end

	def clear_selected
		@selected_items = nil
	end

	def clear_last_query
		@last_query = nil
	end
end

def parseDBfile(db_file)
	line_count = 0
	db = nil

	File.open(db_file){|fileIO|
		fileIO.each_line{|line|
			split_line = line.strip.split(',')

			if line_count == 0
				db = ItemDB.new(split_line)
			else
				db.addItem(split_line)
			end

			line_count += 1
		}
	}

	db
end

def search(dbs, params)
	results = nil
	db = nil

	if dbs.kind_of?(ItemDB)
		db = dbs
	end

	if params.size >= 2
		if params.size == 3
			db_name = params[0]
			params = params[1..-1]

			if dbs.kind_of?(Hash) && dbs.has_key?(db_name)
				db = dbs[db_name]
			end
		end

		field = params[0]
		values = params[1].split(';')

		#Query the proper database(s) for matches
		if db != nil
			values.each{|value|
				if results == nil
					results = db.query(field, value)
				else
					results = results.merge(db.query(field, value))
				end
			}
		else
			values.each{|value|
				dbs.each_value{|idb|
					if results == nil
						results = idb.query(field, value)
					else
						results = results.merge(idb.query(field, value))
					end
				}
			}
		end
	elsif params.size == 1
		values = params[0].split(';')

		#Query every database for matches
		if db != nil
			values.each{|value|
				if results == nil
					results = db.query(value)
				else
					results = results.merge(db.query(value))
				end
			}
		else
			values.each{|value|
				dbs.each_value{|idb|
					if results == nil
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
	out_str = ''

	case cmd
	when 'quit', 'close', 'exit'
		out_str<<'Terminates the ItemsCompendium.'
	when 'search'
		out_str<<"Search [Type] [Field] <Query>\n"
		out_str<<"Searches indexed Items for matches to the given Query. The search is limited to the given Type and Field if provided.\n"
		out_str<<'If Type is not provided then the entire Compendium is searched. If Field is not provided then the first field (usually a name) is searched. If Type is provided, then Field must also be provided.'
	when 'refine'
		out_str<<"Refine [Field] <Query>\n"
		out_str<<"Refines the previous query results by searching it for matches to the given Query. The search is limited to the given Field if provided.\n"
		out_str<<'If Field is not provided then the first field (usually a name) is searched.'
	when 'dump'
		out_str<<"Dump\n"
		out_str<<'Prints out all Items indexed by the Compendium.'
	when 'types'
		out_str<<"Types\n"
		out_str<<'Prints out a list of all the database types indexed by the Compendium.'
	when 'fields'
		out_str<<"Fields\n"
		out_str<<'Prints out the fields used in each of the datases indexed by the Compendium.'
	when 'select'
		out_str<<"Select [N]\n"
		out_str<<"Chooses N items at random from the last query results or from the entire Compendium if there are no previous results.\n"
		out_str<<'If N is not provided, then only 1 item is selected.'
	when 'save'
		out_str<<"Save [Name]\n"
		out_str<<'Saves previous query results to a file with the given Name or the current time (in milliseconds) if Name is not provided.'
	when 'saveselected'
		out_str<<"SaveSelected [Name]\n"
		out_str<<'Saves previous selections to a file with the given Name or the current time (in milliseconds) if Name is not provided.'
	when 'clear'
		out_str<<"Clear\n"
		out_str<<'Clears all previous query results and selections.'
	when 'showextended'
		out_str<<"ShowExtended\n"
		out_str<<'Displays extended fields for previous selections or last query results if there are no previous selections.'
	when 'help'
		out_str<<"Help [Command]\n"
		out_str<<'Prints the list of available commands or help for the given Command.'
	else
		out_str<<'Unrecognized command.'
	end

	out_str
end

#MAIN
query_prompt = "\n:>"
db_ext = '.db'

db_hash = Hash.new
last_query = nil
selected_items = nil
db_dir = '.'

if ARGV.length == 1
	db_dir = ARGV[0]
end

compendium = ItemsCompendium.new

Dir.new("#{Dir.pwd}/#{db_dir}").each{|filename|
	if filename.end_with?(db_ext)
		db_hash[File.basename(filename, db_ext).downcase] = parseDBfile("#{db_dir}/#{filename}")
		compendium.add_db(File.basename(filename, db_ext).downcase, parseDBfile("#{db_dir}/#{filename}"))
	end
}

com_proc = CommandProcessor.new(query_prompt, DefaultCommand.new)
com_proc.register_command(QuitCommand.new, 'quit', 'close', 'exit')
com_proc.register_command(SearchCommand.new, 'search')
com_proc.register_command(RefineCommand.new, 'refine')
com_proc.register_command(DumpCommand.new, 'dump')
com_proc.register_command(TypesCommand.new, 'types')
com_proc.register_command(FieldsCommand.new, 'fields')
com_proc.register_command(SelectCommand.new, 'select')
com_proc.register_command(SaveCommand.new, 'save')
com_proc.register_command(SaveSelectedCommand.new, 'saveselected')
com_proc.register_command(ClearCommand.new, 'clear')
com_proc.register_command(ShowExtendedCommand.new, 'showextended')
com_proc.register_command(CountCommand.new, 'count')
com_proc.register_command(HelpCommand.new(com_proc), 'help')

com_proc.loop(compendium)
