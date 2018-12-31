class String
  def beats(other)
    [self, other]
  end

  def loses_to(other)
    [other, self]
  end
end

