#ItemsCompendium.rb

require 'optparse'

require_relative 'ItemDB'
require_relative 'Console/CommandProcessor'
require_relative 'Console/CompendiumCommands'

##
# This class holds all of the data and provides the ability to search and access said data in a number of ways.
##
class ItemsCompendium
	attr_reader :db_hash, :last_query, :selected_items

  ##
  # Creates a new, empty ItemsCompendium.
  ##
	def initialize
		@db_hash = Hash.new
		@last_query = nil
		@selected_items = nil
	end

  ##
  # Parses all files in the given directory which have the given extension and
  # builds a new ItemsCompendium holding each of them.
  ##
  def self.parse(db_dir, db_ext)
    compendium = ItemsCompendium.new

    # Iterate through all of the CSV files in the directory
    Dir.new(db_dir).each{|filename|
      if filename.end_with?(db_ext)
        compendium.add_db(File.basename(filename, db_ext).downcase, ItemDB.parseDBfile("#{db_dir}/#{filename}"))
      end
    }

    compendium
  end

  ##
  # Adds an ItemDB with the given name to the compendium, making it searchable.
  ##
	def add_db(db_name, db)
		@db_hash[db_name.downcase] = db
	end

  ##
  # Returns the total number of Items stored in this compendium.
  ##
	def count_items
		item_count = 0

		@db_hash.each_value{|db|
			item_count += db.numItems
		}

		item_count
	end

  ##
  # Searches the entire body of data for the provided search_terms. If the field parameter is provided, then the search
  # is restricted to that field, otherwise the first field is searched.
  ##
	def search_all(search_terms, field = nil)
		results = nil

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

  ##
  # Searches just one of the indexed databases for the given search_terms. Otherwise this is functionally equivalent to
  # the search_all function.
  ##
	def search_db(db_name, search_terms, field = nil)
    down_db_name = db_name.downcase
		results = nil
		clear_selected

		if @db_hash.has_key?(down_db_name)
			search_terms.each{|value|
				if results == nil
					if field != nil
						results = @db_hash[down_db_name].query(field, value)
					else
						results = @db_hash[down_db_name].query(value)
					end
				else
					if field != nil
						results = results.merge(@db_hash[down_db_name].query(field, value))
					else
						results = results.merge(@db_hash[down_db_name].query(value))
					end
				end
			}
		end

		@last_query = results
	end

  ##
  # Searches only the last set of query results, allowing the previous search to be refined. Otherwise this is
  # functionally equivalent to the search_all function.
  ##
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

  ##
  # Picks a random element select_count times and returns the resultant list. Items are selected from the last query
  # results, if any, or from the entire data set if not. The select_count parameter is clamped to the range 0..SIZE,
  # where SIZE is the number of items in either the last set of query results or in the entire data set.
  ##
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

    if select_count >= select_db.numItems
      @selected_items = select_db.to_a
    else
      select_count.times{|count|
        selected = select_db.select

        while @selected_items.include?(selected)
          selected = select_db.select
        end

        @selected_items[count] = selected
      }
    end
  end

  ##
  # Returns the Items at the given positions in the set of last query results. The indices parameter should be a list of
  # positions (even if only 1 position is specified).
  ##
  def choose(indices)
    @selected_items = Array.new

    indices.each{|index|
      if index.to_i.between?(0, @last_query.numItems - 1)
        @selected_items<<@last_query[index.to_i]
      end
    }
  end

  ##
  # Returns the Items at the positions included within the given range. Both range_start and range_end are clamped to
  # the bounds of the last set of query results.
  ##
  def choose_range(range_start, range_end)
    @selected_items = Array.new

    range_start = 0 unless range_start >= 0
    range_end = @last_query.numItems unless range_end < @last_query.numItems

    if last_query != nil
      @selected_items = @last_query[range_start..range_end]
    end
  end

  ##
  # Clears the currently selected Items.
  ##
	def clear_selected
		@selected_items = nil
	end

  ##
  # Resets the currently selected Items list such that it is empty.
  ##
  def empty_selected
    @selected_items = Array.new
  end

  ##
  # Clears the last set of query results.
  ##
	def clear_last_query
		@last_query = nil
  end

  ##
  # Returns a list of all unique values for the given field in one of the
  # indexed databases.
  ##
  def get_values(db_name, field)
    down_db_name = db_name.downcase

    if @db_hash.has_key?(down_db_name)
      @db_hash[down_db_name].values(field)
    else
      nil
    end
  end

  ##
  # Returns the string representation of the current set of selected Items. The numbered parameter turns Item numbering
  # in the returned string on or off, and the extended parameter turns hidden fields on or off in the returned string.
  ##
  def selected_to_s(numbered = false, extended = false)
    out_str = ''
    num_str = ''
    item_num = 1

    @selected_items.map{|item|
      if numbered
        num_str = "#{item_num}. "
      end

      out_str<<"#{num_str}#{item.to_s(extended)}\n"
      item_num += 1
    }

    out_str
  end
end

#MAIN
query_prompt = "\n:>"
db_ext = '.db'
db_dir = '.'
io_method = UserIO::CURSES

# Parse command line arguments
OptionParser.new{|opt|
  opt.on('-d', '--dirname=DIR', 'Specify the database directory'){|dir|
    db_dir = dir
  }

  opt.on('-c', '--[no-]curses', "Don't use Curses for I/O"){|c|
    io_method = c ? UserIO::CURSES : UserIO::STANDARD
  }
}.parse!

compendium = ItemsCompendium.parse(db_dir, db_ext)

# Add all of our Commands to the CommandProcessor
com_proc = CommandProcessor.new(query_prompt, DefaultCommand.new, io_method)
com_proc.register_command(EmptyCommand.new, '')
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
com_proc.register_command(HistoryCommand.new(com_proc), 'history', '!')
com_proc.register_command(ChooseCommand.new, 'choose')
com_proc.register_command(EnumerateCommand.new, 'enumerate')
com_proc.register_command(CreateSetCommand.new, 'createset')
com_proc.register_command(LoadSetCommand.new, 'loadset')
com_proc.register_command(AddToSetCommand.new, 'addtoset')
com_proc.register_command(ListSetsCommand.new, 'listsets')
com_proc.register_command(TrashSetCommand.new, 'trashset')
com_proc.register_command(HelpCommand.new(com_proc), 'help')

com_proc.loop(compendium)
