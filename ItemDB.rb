#ItemDB.rb

require 'set'

require_relative 'Item'

##
# This class is an aggregation of Items and provides the ability to query it for matches and merge it with other ItemDBs
# that have the same fields.
##
class ItemDB
	attr_reader :fields, :hidden_fields

  ##
  # Creates a new ItemDB with the given list of fields. All Items added will share this list of fields and hidden fields,
  # where any fields beginning with '-' are considered to be initially hidden (the '-' will be stripped off).
  ##
	def initialize(fields)
		@fields = Array.new
		@hidden_fields = Array.new
		@items = Hash.new

		fields.each{|field|
			if field.start_with?('-')
				@hidden_fields<<field[1..-1]
				@fields<<field[1..-1]
			else
				@fields<<field
			end
		}
	end

  ##
  # Parses the given CSV file into an ItemDB object and returns it.
  ##
  def self.parse_db_file(db_file)
    line_count = 0
    db = nil

    File.open(db_file){|fileIO|
      fileIO.each_line{|line|
        split_line = line.strip.split(',')

        if line_count == 0
          db = ItemDB.new(split_line)
        else
          db.add_item(split_line)
        end

        line_count += 1
      }
    }

    db
  end

  ##
  # Creates and adds a new Item with the given values iff an Item with the same value for the first field does not
  # already exist in this ItemDB.
  ##
	def add_item(vals)
		key = vals[0]

    unless @items.has_key?(key)
      @items[key] = Item.new(@fields, key, @hidden_fields)
    end

		@items[key].add_data(vals[1..-1])
	end

  ##
  # Allows indexing of an ItemDB like an Array (read-only).
  ##
  def [](offset)
    @items.values[offset]
  end

  ##
  # Returns a subset of this ItemDB containing only Items which match the given
  # criteria for field (optional) and value.
  ##
	def query(field = @fields[0], value)
		query_results = Array.new

		@items.each_value{|item|
			if item.matches?(field, value)
				query_results<<item
			end
		}

		build_subset_db(query_results)
	end

  ##
  # Merges this ItemDB with the given other_db, if they both have the same list of fields, and returns the resulting
  # ItemDB.
  ##
	def merge(other_db)
		if other_db == nil
			self
		elsif !@fields.eql?(other_db.fields)
			nil
		else
			build_subset_db(@items.values.concat(other_db.items.values))
		end
	end

  ##
  # Picks a random Item from those stored in this ItemDB and returns it.
  ##
	def select
		selected_index = Random.new.rand(num_items)

		@items.values[selected_index]
	end

  ##
  # Returns the set of unique values in this ItemDB for the given field as a
  # list in no particular order.
  ##
  def values(field)
    vals = Set.new

    @items.each_value{|item|
      item.data[field.downcase].each{|item_val|
        vals<<item_val
      }
    }

    vals
  end

  ##
  # Returns the total number of Items indexed by this ItemDB.
  ##
	def num_items
		@items.size
	end

  ##
  # Returns this ItemDB's contents as an Array.
  ##
  def to_a
    @items.values
  end

  ##
  # Returns a stringified version of this ItemDB's Item set. The numbered parameter turns Item numbering on or off, and
  # the extended parameter turns hidden fields on or off in the returned string.
  ##
	def to_s(numbered = false, extended = false)
		out_str = ''
    num_str = ''
    item_num = 1

		@items.each_value{|item|
      if numbered
        num_str = "#{item_num}. "
      end

      out_str<<"#{num_str}#{item.to_s(extended)}\n"
      item_num += 1
		}

		out_str
	end

	protected

  attr_accessor :items

  ##
  # Builds a new ItemDB out of the given set of Items and returns it.
  ##
	def build_subset_db(subset_items)
		if subset_items.empty?
			nil
		else
			subset_db = ItemDB.new(@fields)

			subset_items.each{|item|
				subset_db.items[item.name] = item
			}

			subset_db
		end
	end
end