require_relative 'format_data.rb'
require_relative 'errors.rb'

# Runs a Ranked-Choice voting algorithm
#
# Ballots should be an array of ballots, where each ballot is an array of 0 or more strings
# Any individual string should represent a candidate
# In the case of the SSI election, each "candidate" will actually be a pairing
#
# Tie breakers should also be an array of arrays.
# Each array in it represents how to break a tie.
# For example, the tie breaker ['A', 'B'] would mean that A beats B, and so if A and B got an equal number of first-place votes, B should be the one eliminated
def rcv(ballots, tie_breakers)
  raise BallotError.new('Ballots must be non-empty') if ballots.empty?

  # for each candidate, count how many first place votes they got
  first_place_votes = {}
  ballots.each do |ballot|
    next if ballot.empty?

    first_place_votes[ballot.first] = 0 if first_place_votes[ballot.first].nil?
    first_place_votes[ballot.first] += 1
  end

  # if there's only one candidate left, return that candidate
  raise BallotError.new('No candidates') if first_place_votes.size == 0
  return first_place_votes.keys.first if first_place_votes.size == 1

  # figure out which candidates are in last place
  ordered_votes = first_place_votes.sort_by{|_candidate, vote_number| vote_number}
  last_place_candidates = []
  last_place_vote_count = ordered_votes.first.last # ordered_votes.first will give [candidate, vote_count]
  ordered_votes.each do |candidate, vote_count|
    break if vote_count > last_place_vote_count
    last_place_candidates << candidate
  end

  # figure out which of the last place candidates to eliminate, based on the tie breakers
  last_place_candidate = last_place_candidates.first
  last_place_candidates.drop(1).each do |candidate| # we drop the first because we don't want to compare against itself
    broken_in_favor_of_candidate = tie_breakers.include? candidate.beats(last_place_candidate)
    broken_against_candidate = tie_breakers.include? candidate.loses_to(last_place_candidate)

    # verify that you have enough tie breaking information
    raise TieBreakingError.new(candidate, last_place_candidate) unless broken_in_favor_of_candidate || broken_against_candidate
    raise TieBreakingError.new(candidate, last_place_candidate) if broken_in_favor_of_candidate && broken_against_candidate

    last_place_candidate = candidate if broken_against_candidate
  end

  # eliminate the candidate in last place
  cleaned_ballots = ballots.map do |ballot|
    ballot.reject{|candidate| candidate == last_place_candidate }
  end

  # recurse on the cleaned ballots
  rcv cleaned_ballots, tie_breakers
end
