require_relative '../src/format_data.rb'
require_relative '../src/errors.rb'

describe 'format_data' do

  describe 'when monkey patching String' do
    it 'creates a beats method' do
      expect('A'.beats('B')).to eq(['A', 'B'])
      expect('C'.beats('D')).to eq(['C', 'D'])
    end

    it 'creates a loses_to method' do
      expect('A'.loses_to('B')).to eq(['B', 'A'])
      expect('C'.loses_to('D')).to eq(['D', 'C'])
    end
  end

  describe 'when validating data' do

    describe '#validate_ballot' do
      it 'allows a valid dataset' do
        expect{ validate_ballot! File.readlines('spec/data/sample-ballots-1.tsv') }.to_not raise_error
      end

      it 'verifies that the data has a header' do
        expect{ validate_ballot! [] }.to raise_error(DataValidationError)
      end

      it 'makes sure the names are extractable' do
        expect{
          validate_ballot! [
                                     'Timestamp	Would you like to rank a full list of all 10 possible co-president candidate pairs, or to rank a single list with the five candidates?	Your Vote [A + B + C]	Your Vote [A + C]	Your Vote [A + D]	Your Vote [A + E]	Your Vote [B + C]	Your Vote [B + D]	Your Vote [B + E]	Your Vote [C + D]	Your Vote [C + E]	Your Vote [D + E]	Your Vote [A]	Your Vote [B]	Your Vote [C]	Your Vote [D]	Your Vote [E]	Select Two Financial Officers	Ian Gomez?'
                                 ]
        }.to raise_error(DataValidationError)
      end

      it 'makes sure there are the right number of columns' do
        expect{
          validate_ballot! [
                                     'Timestamp	Would you like to rank a full list of all 10 possible co-president candidate pairs, or to rank a single list with the five candidates?	Your Vote [A + B]	Your Vote [A + C]	Your Vote [A + D]	Your Vote [A + E]	Your Vote [B + C]	Your Vote [B + D]	Your Vote [B + E]	Your Vote [C + D]	Your Vote [C + E]	Your Vote [D + E]	Your Vote [A]	Your Vote [B]	Your Vote [C]	Your Vote [D]	Select Two Financial Officers	Ian Gomez?'
                                 ]
        }.to raise_error(DataValidationError)
      end

      it 'makes sure it has all combinations of candidates' do
        expect{
          validate_ballot! [
                               'Timestamp	Would you like to rank a full list of all 10 possible co-president candidate pairs, or to rank a single list with the five candidates?	Your Vote [A + B]	Your Vote [C + A]	Your Vote [A + D]	Your Vote [A + E]	Your Vote [B + C]	Your Vote [B + D]	Your Vote [B + E]	Your Vote [C + D]	Your Vote [C + E]	Your Vote [D + E]	Your Vote [A]	Your Vote [B]	Your Vote [C]	Your Vote [D]	Your Vote [F]	Select Two Financial Officers	Ian Gomez?'
                           ]
        }.to raise_error(DataValidationError)
      end

      it 'makes sure it does not have excess combinations of candidates' do
        expect{
          validate_ballot! [
                               'Timestamp	Would you like to rank a full list of all 10 possible co-president candidate pairs, or to rank a single list with the five candidates?	Your Vote [A + B]	Your Vote [B + A]	Your Vote [A + D]	Your Vote [A + E]	Your Vote [B + C]	Your Vote [B + D]	Your Vote [B + E]	Your Vote [C + D]	Your Vote [C + E]	Your Vote [D + E]	Your Vote [A]	Your Vote [B]	Your Vote [C]	Your Vote [D]	Your Vote [F]	Select Two Financial Officers	Ian Gomez?'
                           ]
        }.to raise_error(DataValidationError)

        # expect{
        #   validate_ballot! [
        #                        'Timestamp	Would you like to rank a full list of all 10 possible co-president candidate pairs, or to rank a single list with the five candidates?	Your Vote [A + B]	Your Vote [A + C]	Your Vote [A + D]	Your Vote [A + E]	Your Vote [B + C]	Your Vote [B + D]	Your Vote [B + E]	Your Vote [C + D]	Your Vote [C + E]	Your Vote [D + E]	Your Vote [A]	Your Vote [B]	Your Vote [C]	Your Vote [D]	Your Vote [E]	Select Two Financial Officers	Ian Gomez?'
        #                    ]
        # }.to raise_error(DataValidationError)
      end
    end

    describe '#validate_tie_breakers' do
      it 'allows valid tie breakers' do
        expect{ validate_tie_breakers! File.readlines('spec/data/sample-tie-breakers-1.txt') }.to_not raise_error
      end

      it 'allows comments and blank lines' do
        expect{ validate_tie_breakers! ['A + B > A + C', '# comment', '', '   '] }.to_not raise_error
      end

      it 'throws an error on invalid tie breakers' do
        expect{
          validate_tie_breakers! [
                                     'A + B'
                                 ]
        }.to raise_error(DataValidationError)

        expect{
          validate_tie_breakers! [
                                     'A + B > C'
                                 ]
        }.to raise_error(DataValidationError)

        expect{
          validate_tie_breakers! [
                                     'A > B + C'
                                 ]
        }.to raise_error(DataValidationError)

        expect{
          validate_tie_breakers! [
                                     'bork'
                                 ]
        }.to raise_error(DataValidationError)

        expect{
          validate_tie_breakers! [
                                     'A + B'
                                 ]
        }.to raise_error(DataValidationError)

        expect{
          validate_tie_breakers! [
                                     'A + B > B + C > C + D'
                                 ]
        }.to raise_error(DataValidationError)
      end
    end

    describe '#validate_pairings' do
      it 'allows valid pairings' do
        expect{ validate_pairings! File.readlines('spec/data/sample-pairings-1.txt') }.to_not raise_error
      end

      it 'allows comments and blank lines' do
        expect{ validate_pairings! ['A + B', '# comment', '', '   '] }.to_not raise_error
      end

      it 'throws an error on invalid pairings' do
        expect{
          validate_pairings! [
                                 'bork'
                             ]
        }.to raise_error(DataValidationError)

        expect{
          validate_pairings! [
                                 'a +'
                             ]
        }.to raise_error(DataValidationError)

        expect{
          validate_pairings! [
                                 'a + b +'
                             ]
        }.to raise_error(DataValidationError)

        expect{
          validate_pairings! [
                                 ' a + b'
                             ]
        }.to raise_error(DataValidationError)

        expect{
          validate_pairings! [
                                 '$ + B'
                             ]
        }.to raise_error(DataValidationError)
      end
    end

  end

end