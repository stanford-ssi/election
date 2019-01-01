require_relative 'errors'

# monkey patch String so that it's easier to keep track of the ordering in beats vs loses to
class String
  def beats(other)
    [self, other]
  end

  def loses_to(other)
    [other, self]
  end
end

# Helper method to turn a header string into a hash, where keys are column indices and values are the candidates
def map_columns_to_candidates(first_line)
  headers = first_line.split("\t")
  column_to_candidates = {}

  headers.each.with_index do |header, i|
    match = /Your Vote \[([^\]]+)\]/.match header
    if match
      column_to_candidates[i] = match[1]
    end
  end

  column_to_candidates
end

# Validates that a set of lines (strings) representing the downloaded ballot csv is in the right format
# Throws a DataValidationError if it's invalid
def validate_ballot!(lines)
  # verify that it has a header
  raise DataValidationError if lines.empty?

  column_to_candidates = map_columns_to_candidates lines.first

  column_to_candidates.values.each do |candidate|
    # verify that each of the candidates is in a format we expect
    raise DataValidationError.new("Invalid candidate format: #{candidate}") unless /^\w+( \+ \w+)?$/.match? candidate
  end

  individual_candidates = column_to_candidates.values.select{|candidate| candidate =~ /^\w+$/}.uniq
  candidate_pairs = column_to_candidates.values.select{|candidate| candidate =~ /^\w+ \+ \w+$/}.uniq

  # make sure all permutations of candidates exist
  individual_candidates.each_with_index do |candidate_1, index|
    (index + 1).upto(individual_candidates.length - 1) do |index_2|
      candidate_2 = individual_candidates[index_2]
      pair_a = "#{candidate_1} + #{candidate_2}"
      pair_b = "#{candidate_2} + #{candidate_1}"

      has_a = candidate_pairs.include? pair_a
      has_b = candidate_pairs.include? pair_b

      raise DataValidationError.new("Candidate pair is duplicated (#{pair_a} and #{pair_b})") if has_a && has_b
      raise DataValidationError.new("Candidate pair does not appear (#{pair_a})") unless has_a || has_b

      # delete them here so we can check for leftovers
      candidate_pairs.delete pair_a if has_a
      candidate_pairs.delete pair_b if has_b
    end
  end

  # verify that there are no leftovers
  raise DataValidationError.new("Excess candidate pairs (#{candidate_pairs.join(', ')})") unless candidate_pairs.empty?
end

# Validates that a set of lines (strings) representing co-president tie-breaking config is in the right format
# Throws a DataValidationError if it's invalid
def validate_tie_breakers!(lines)
  lines.each do |line|
    next if line.strip.empty?
    next if line[0] == '#'

    raise DataValidationError.new(line) unless /^\w+ \+ \w+ > \w+ \+ \w+$/.match? line
  end
end

# Validates that a set of lines (strings) representing co-president selected pairings is in the right format
# Throws a DataValidationError if it's invalid
def validate_pairings!(lines)
  lines.each do |line|
    next if line.strip.empty?
    next if line[0] == '#'

    raise DataValidationError.new(line) unless /^\w+ \+ \w+$/.match? line
  end
end