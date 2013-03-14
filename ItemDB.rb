#ItemDB.rb

require_relative 'Item'

class ItemDB
	@items
	attr_reader :fields, :hidden_fields

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

	def merge(other_db)
		if other_db == nil
			self
		elsif !@fields.eql?(other_db.fields)
			nil
		else
			buildSubsetDB(@items.values.concat(other_db.items.values))
		end
	end

	def select
		selected_index = Random.new.rand(numItems)

		@items.values[selected_index]
	end

	def numItems
		@items.size
	end

  def to_a
    @items.values
  end

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

	def items
		@items
	end

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