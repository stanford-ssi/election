class ElectionError < RuntimeError

end

class BallotError < ElectionError

end

class TieBreakingError < ElectionError

  def initialize(candidate1, candidate2)
    super("No tie-breaking information between #{candidate1.inspect} and #{candidate2.inspect}")
  end

end