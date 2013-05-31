#Item.rb

require_relative 'Extensions'

##
# This class holds all the data for a single Item in the compendium and allows checking the Item for a match with some
# search term.
##
class Item
	@fields
	@hidden_fields
	attr_reader :name, :data

  ##
  # Creates a new Item with no data and the given fields. The first_field_val specifies the field to be used as the
  # Item's name, and the hidden parameter enumerates the fields which should be hidden from printouts by default.
  ##
	def initialize(fields, first_field_val, hidden)
		@fields = fields.map{|field| field.downcase}
		@hidden_fields = hidden.map{|hiddenField| hiddenField.downcase}
		@name = first_field_val.downcase
		@data = Hash.new

		@fields[1..-1].each{|field|
			@data[field] = Array.new
		}
	end

  ##
  # Adds data to the Item by matching the passed values one-to-one with the field list.
  ##
	def addData(vals)
		vals.each_index{|index|
			value = vals[index].downcase.strip

      unless value.eql?('')
        if value.include?(';')
          @data[@fields[index + 1]].concat(value.split(';'))
        else
          @data[@fields[index + 1]]<<value
        end

        @data[@fields[index + 1]].uniq!
      end
		}
	end

  ##
  # Checks if this Item matches the given field-value pair, performing a more robust match if the given field is this
  # Item's name field.
  ##
	def matches?(field, value)
		down_field = field.downcase
		down_val = value.downcase
    approx = false

    if down_val.start_with?('~')
      approx = true
      down_val = down_val[1..-1]
    end

		if @fields[0].eql?(down_field)
			@name.eql?(down_val) || @name.start_with?(down_val) || @name.include?(down_val)
		elsif @data.has_key?(down_field)
			@data[down_field].include?(down_val) || approx ? @data[down_field].include_similar?(down_val) : false
		else
			false
		end
	end

  ##
  # Compares two Items by name, ignoring case.
  ##
	def eql?(item)
		@name.eql?(item.downcase)
	end

  ##
  # Returns a stringified version of this Item. The extended parameter turns the inclusion of hidden fields on or off.
  ##
	def to_s(extended = false)
		out_str = "#{@fields[0].pretty}: #{@name.pretty}\n"

		@data.each_pair{|key, value|
			if !@hidden_fields.include?(key) || extended
				out_str<<"  #{key.pretty}: #{value.map{|val| val.pretty}}\n"
			end
		}

		out_str
	end
end