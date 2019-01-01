require_relative 'errors'

# the index of the column that asks if you are using
OPTION_INDEX = 1

# the regex that says they are ranking all candidate pairings
RANK_ALL = /I would like to rank all \d+ pairs/

# the regex that says they are ranking individual candidates and turning it over to the co-prezes
RANK_CO_PREZ = /I would like to rank the \d+ individual candidates/

def convert_to_ranked_choices(lines, co_prez_selections)
  validate_ballot! lines

  column_to_candidates = map_columns_to_candidates lines.first
  individual_candidate_columns = column_to_candidates.select{|_index, candidate| /^\w+$/.match? candidate}.to_h
  paired_candidate_columns = column_to_candidates.reject{|_index, candidate| /^\w+$/.match? candidate}.to_h

  all_ranked_choices = []

  lines.drop(1).each do |line|
    parts = line.split("\t")

    ranking_all = RANK_ALL.match? parts[OPTION_INDEX]

    if ranking_all
      ranked_choices = extract_ranked_choices parts, paired_candidate_columns
    else
      ranked_choices = extract_ranked_choices parts, individual_candidate_columns

      # pair the candidates up
      ranked_choices.map! {|candidate| "#{candidate} + #{co_prez_selections[candidate]}"}
    end

    # alphabetize candidate pairs
    ranked_choices.map! {|pair| pair.split(' + ').sort.join(' + ')}

    all_ranked_choices << ranked_choices
  end

  all_ranked_choices
end

# Given an array of parts of a line, and a map from column to candidate, figure out how to order the specified candidates as an array
def extract_ranked_choices(parts, relevant_columns)
  ranking = {}

  relevant_columns.each do |index, candidate|
    next if index >= parts.length # tsv will truncate unnecessary columns
    rank = parts[index].strip

    ranking[convert_rank_to_integer rank] = candidate unless rank.empty?
  end

  # convert to an array, sorted by ranking
  ranking.sort_by{|rank, _candidate| rank}.to_h.values
end

# Given a rank as a string (eg "First Choice"), turn it into an integer (eg 1)
def convert_rank_to_integer(rank_string)
  lookup = %w(First Second Third Fourth Fifth Sixth Seventh Eighth Ninth Tenth)
  rank = lookup.index(rank_string.split(' ').first) # find index of first word of the string

  raise DataValidationError.new("Invalid rank string: #{rank_string}") if rank.nil?

  rank + 1 # add 1 for consistency
end

# Takes lines from a file and converts them to a hash where the key is a candidate and the value is their ideal pairing
def extract_co_prez_selections(lines)
  validate_pairings! lines

  selections = {}
  lines.each do |line|
    next if line.strip.empty?
    next if line[0] == '#'

    first, second = line.split(' + ')
    selections[first.strip] = second.strip
  end

  selections
end

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

  # check that each ballot selects an option
  lines.drop(1).each do |line|
    option = line.split("\t")[OPTION_INDEX]

    raise DataValidationError.new("Invalid selection: #{option}") unless RANK_ALL.match?(line) || RANK_CO_PREZ.match?(line)
  end
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