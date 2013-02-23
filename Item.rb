#Item.rb

class String
	def titlecase
		gsub(/\w+/){|word| word.capitalize}
	end

	def pretty
		gsub("_", " ").titlecase
	end
end

class Item
	:fields
	:hiddenFields
	attr_reader :name
	attr_reader :data

	def initialize(fields, firstFieldVal, hiddenFields)
		@fields = fields.map{|field| field.downcase}
		@hiddenFields = hiddenFields.map{|hiddenField| hiddenField.downcase}
		@name = firstFieldVal.downcase
		@data = Hash.new

		@fields[1..-1].each{|field|
			@data[field] = Array.new
		}
	end

	def addData(vals)
		vals.each_index{|index|
			value = vals[index].downcase.strip

			if(!value.eql?(""))
				if(value.include?(";"))
					@data[@fields[index + 1]].concat(value.split(";"))
				else
					@data[@fields[index + 1]]<<value
				end
				
				@data[@fields[index + 1]].uniq!
			end
		}
	end

	def matches?(field, value)
		downField = field.downcase
		downVal = value.downcase

		if(@fields[0].eql?(downField))
			@name.eql?(downVal) || @name.start_with?(downVal)
		elsif(@data.has_key?(downField))
			@data[downField].include?(downVal)
		else
			false
		end
	end

	def eql?(item)
		@name.eql?(item.downcase)
	end

	def to_s(extended = false)
		outStr = "#{@fields[0].pretty}: #{@name.pretty}\n"

		@data.each_pair{|key, value|
			if(!@hiddenFields.include?(key) || extended)
				outStr<<"  #{key.pretty}: #{value.map{|val| val.pretty}}\n"
			end
		}

		outStr
	end
end