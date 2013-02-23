#ItemDB.rb

require_relative 'Item'

class ItemDB
	:items
	attr_reader :fields, :hiddenFields

	def initialize(fields)
		@fields = Array.new
		@hiddenFields = Array.new
		@items = Hash.new

		fields.each{|field|
			if(field.start_with?("-"))
				@hiddenFields<<field[1..-1]
				@fields<<field[1..-1]
			else
				@fields<<field
			end
		}
	end

	def addItem(vals)
		key = vals[0]

		if(!@items.has_key?(key))
			@items[key] = Item.new(@fields, key, @hiddenFields)
		end

		@items[key].addData(vals[1..-1])
	end

	def query(field = @fields[0], value)
		queryResults = Array.new

		@items.each_value{|item|
			if(item.matches?(field, value))
				queryResults<<item
			end
		}

		buildSubsetDB(queryResults)
	end

	def merge(otherDB)
		if(otherDB == nil)
			self
		elsif(!@fields.eql?(otherDB.fields))
			nil
		else
			buildSubsetDB(@items.values.concat(otherDB.items.values))
		end
	end

	def select()
		selectedIndex = Random.new.rand(numItems)

		@items.values[selectedIndex]
	end

	def numItems
		@items.size
	end

	def to_s(extended = false)
		outStr = ""

		@items.each_value{|item|
			outStr<<"#{item.to_s(extended)}\n"
		}

		outStr
	end

	protected

	def items
		@items
	end

	def buildSubsetDB(subsetItems)
		if(subsetItems.empty?)
			nil
		else
			subsetDB = ItemDB.new(@fields)

			subsetItems.each{|item|
				subsetDB.items[item.name] = item
			}

			subsetDB
		end
	end
end