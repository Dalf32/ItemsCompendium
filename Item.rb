#Item.rb

class String
	def titlecase
		gsub(/\w+/){|word| word.capitalize}
	end

	def pretty
		gsub('_', ' ').titlecase
	end
end

class Item
	@fields
	@hidden_fields
	attr_reader :name
	attr_reader :data

	def initialize(fields, first_field_val, hidden)
		@fields = fields.map{|field| field.downcase}
		@hidden_fields = hidden.map{|hiddenField| hiddenField.downcase}
		@name = first_field_val.downcase
		@data = Hash.new

		@fields[1..-1].each{|field|
			@data[field] = Array.new
		}
	end

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

	def matches?(field, value)
		down_field = field.downcase
		down_val = value.downcase

		if @fields[0].eql?(down_field)
			@name.eql?(down_val) || @name.start_with?(down_val)
		elsif @data.has_key?(down_field)
			@data[down_field].include?(down_val)
		else
			false
		end
	end

	def eql?(item)
		@name.eql?(item.downcase)
	end

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