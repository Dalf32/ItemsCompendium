#ItemDB.rb

require_relative 'Item'

##
# This class is an aggregation of Items and provides the ability to query it for matches and merge it with other ItemDBs
# that have the same fields.
##
class ItemDB
	@items
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
  # Creates and adds a new Item with the given values iff an Item with the same value for the first field does not
  # already exist in this ItemDB.
  ##
	def addItem(vals)
		key = vals[0]

    unless @items.has_key?(key)
      @items[key] = Item.new(@fields, key, @hidden_fields)
    end

		@items[key].addData(vals[1..-1])
	end

  def [](offset)
    @items.values[offset]
  end

	def query(field = @fields[0], value)
		query_results = Array.new

		@items.each_value{|item|
			if item.matches?(field, value)
				query_results<<item
			end
		}

		buildSubsetDB(query_results)
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
			buildSubsetDB(@items.values.concat(other_db.items.values))
		end
	end

  ##
  # Picks a random Item from those stored in this ItemDB and returns it.
  ##
	def select
		selected_index = Random.new.rand(numItems)

		@items.values[selected_index]
	end

  ##
  # Returns the total number of Items indexed by this ItemDB.
  ##
	def numItems
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

  ##
  # Provides access to another ItemDB's set of Items.
  ##
	def items
		@items
	end

  ##
  # Builds a new ItemDB out of the given set of Items and returns it.
  ##
	def buildSubsetDB(subset_items)
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