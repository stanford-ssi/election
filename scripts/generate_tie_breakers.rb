# WARNING: As a utility, the tests for this script are minimal

require_relative '../src/format_data.rb'

# Pairs of each element of the array with every other element of the array
# For example, pair([A, B, C]) will give [[A, B], [A, C], [B, C]]
def pair(array)
  pairs = []

  array.each_with_index do |element_1, index|
    (index + 1).upto(array.length - 1) do |index_2|
      pairs << [element_1, array[index_2]]
    end
  end

  pairs
end

# Takes in an array of individual candidates, then pairs them and over STDIN asks for which pair is better than the other pair, for all pairs
# Asks for file to output to
def generate_tie_breakers(candidates)
  # pair up all candidates, turning the pairs into strings
  pairs = pair(candidates).map do |candidate_1, candidate_2|
    "#{candidate_1} + #{candidate_2}"
  end

  to_tie_break = pair(pairs)

  tie_breakers = []

  to_tie_break.each do |pair_1, pair_2|
    answer = nil
    until answer == 1 || answer == 2
      STDOUT.puts "Which is better: [1] #{pair_1} or [2] #{pair_2}"
      answer = STDIN.gets.strip.to_i
    end

    if answer == 1
      tie_breakers << pair_1.beats(pair_2)
    else
      tie_breakers << pair_1.loses_to(pair_2)
    end
  end

  tie_breakers.map{|pair_1, pair_2| "#{pair_1} > #{pair_2}"}
end

# puts generate_tie_breakers %w(A B C D E)