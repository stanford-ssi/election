require_relative '../scripts/main'

describe 'main' do

  it 'works on sample-data-1' do
    winner, _eliminations = find_winner('spec/data/sample-ballots-1.tsv', 'spec/data/sample-pairings-1.txt', 'spec/data/sample-tie-breakers-1.txt')

    expect(winner).to eq('A + D')
  end

  it 'can print out data' do
    expected_output = %q{Instant runoff:
	Round 1: Eliminated D + E (had 1 first-place votes)
	Round 2: Eliminated C + E (had 1 first-place votes)
	Round 3: Eliminated C + D (had 1 first-place votes)
	Round 4: Eliminated B + C (had 1 first-place votes)
	Round 5: Eliminated A + E (had 1 first-place votes)
	Round 6: Eliminated B + E (had 1 first-place votes)
	Round 7: Eliminated A + B (had 2 first-place votes)
	Round 8: Eliminated A + C (had 1 first-place votes)
	Round 9: Eliminated B + D (had 1 first-place votes)

Winner is: A + D
}

    expect{
      print_winner('spec/data/sample-ballots-1.tsv', 'spec/data/sample-pairings-1.txt', 'spec/data/sample-tie-breakers-1.txt')
    }.to output(expected_output).to_stdout
  end
end