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

#MAIN
query_prompt = "\n:>"
db_ext = '.db'

db_hash = Hash.new
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
com_proc.register_command(HistoryCommand.new(com_proc), 'history')
com_proc.register_command(HelpCommand.new(com_proc), 'help')

com_proc.loop(compendium)
