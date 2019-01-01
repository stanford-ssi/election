# WARNING: As a utility, the tests for this script are minimal

require_relative '../src/format_data'
require_relative '../src/rcv'

# Given the files to read from, returns the winner and the elimination metadata
def find_winner(ballot_file, pairing_file, tie_breaker_file)
  ballot = File.readlines ballot_file
  pairings = extract_co_prez_selections File.readlines(pairing_file)
  tie_breakers = extract_tie_breakers File.readlines(tie_breaker_file)

  ranked_choices = convert_to_ranked_choices ballot, pairings

  eliminations = []
  winner = rcv(ranked_choices, tie_breakers, eliminations)

  [winner, eliminations]
end

# Given the files to read from, prints out the winner and the elimination metadata
def print_winner(ballot_file, pairing_file, tie_breaker_file)
  winner, eliminations = find_winner ballot_file, pairing_file, tie_breaker_file

  puts "Instant runoff:"
  eliminations.each.with_index do |elimination, i|
    puts "\tRound #{i + 1}: Eliminated #{elimination[:candidate]} (had #{elimination[:votes]} first-place votes)"
  end

  puts "\nWinner is: #{winner}"
end

# print_winner('spec/data/sample-ballots-1.tsv', 'spec/data/sample-pairings-1.txt', 'spec/data/sample-tie-breakers-1.txt')