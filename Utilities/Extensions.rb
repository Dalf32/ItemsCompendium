#Extensions.rb

##
# Adds titlecase and pretty functions to String for easier formatting during print statements.
##
class String
  ##
  # Quick and dirty titlecase function.
  ##
  def titlecase
    gsub(/['\w]+/){|word| word.capitalize}
  end

  ##
  # Replaces underscores with spaces and titlecases the string.
  ##
  def pretty
    gsub('_', ' ').titlecase
  end
end

##
# Adds include_similar? function to Array for more robust searching.
##
class Array
  ##
  # Same as include? except returns true if the Array contains a value that
  # either starts with or otherwise includes the key.
  ##
  def include_similar?(key)
    retval = false

    each{|value|
      if value.start_with?(key) || value.include?(key)
        retval = true
      end
    }

    retval
  end

  ##
  # Removes brackets and double quotes from the standard to_s function.
  ##
  def pretty
    to_s[1..-2].gsub('"', '')
  end
end
