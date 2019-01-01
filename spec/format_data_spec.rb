require_relative '../src/format_data.rb'
require_relative '../src/errors.rb'

describe 'format_data' do

  describe 'when converting to ranked choices' do
    it 'works on sample-1' do
      data = File.readlines('spec/data/sample-ballots-1.tsv')
      pairings = extract_co_prez_selections File.readlines('spec/data/sample-pairings-1.txt')
      result = convert_to_ranked_choices data, pairings

      expect(result).to eq([
                               ['C + D', 'A + B', 'A + B', 'D + E', 'A + D'],
                               ['A + D', 'C + D', 'A + B', 'A + B', 'D + E'],
                               ['A + D', 'C + D', 'A + B', 'D + E', 'A + B'],
                               ['D + E', 'C + E', 'B + C', 'A + D', 'A + E', 'A + C', 'B + D', 'A + B', 'B + E', 'C + D'],
                               ['A + B', 'B + E', 'A + E', 'A + C', 'C + E', 'D + E', 'C + D', 'B + D', 'B + C'],
                               ['A + E', 'B + E', 'B + C']
                           ])
    end

    it '#extract_ranked_choices extracts the choices for a line' do
      columns = {
          0 => 'A',
          1 => 'B',
          2 => 'C'
      }

      expect(extract_ranked_choices(['First Choice', 'Second Choice', 'Third Choice'], columns)).to eq(['A', 'B', 'C'])
      expect(extract_ranked_choices(['Third Choice', 'Second Choice', 'First Choice'], columns)).to eq(['C', 'B', 'A'])
      expect(extract_ranked_choices(['Third Choice', 'Second Choice', ''], columns)).to eq(['B', 'A'])
    end

    it 'can convert a rank string to an integer' do
      expect(convert_rank_to_integer('First Choice')).to eq(1)
      expect(convert_rank_to_integer('Second Choice')).to eq(2)
      expect(convert_rank_to_integer('Third Choice')).to eq(3)
      expect(convert_rank_to_integer('Fourth Choice')).to eq(4)
      expect(convert_rank_to_integer('Fifth Choice')).to eq(5)
      expect(convert_rank_to_integer('Sixth Choice')).to eq(6)
      expect(convert_rank_to_integer('Seventh Choice')).to eq(7)
      expect(convert_rank_to_integer('Eighth Choice')).to eq(8)
      expect(convert_rank_to_integer('Ninth Choice')).to eq(9)
      expect(convert_rank_to_integer('Tenth Choice')).to eq(10)
    end

    it 'throws an error when converting an unknown rank string' do
      expect{ convert_rank_to_integer('Blork')}.to raise_error(DataValidationError)
    end
  end

  describe '#extract_co_prez_selections' do
    it 'calls validate' do
      expect{
        extract_co_prez_selections ['bogus']
      }.to raise_error(DataValidationError)
    end

    it 'extracts selections' do
      expect(extract_co_prez_selections(['A + B', 'B + A', '', '  ', '# comment'])).to eq({'A' => 'B', 'B' => 'A'})
    end
  end

  describe '#extract_tie_breakers' do
    it 'calls validate' do
      expect{
        extract_tie_breakers ['bogus']
      }.to raise_error(DataValidationError)
    end

    it 'extracts tie breakers' do
      expect(extract_tie_breakers([
                                      'A + B > B + C',
                                      'A + C > B + C',
                                      '',
                                      '  ',
                                      '# comment'
                                  ])).to eq([
                                                ['A + B', 'B + C'],
                                                ['A + C', 'B + C']
                                            ])
    end
  end

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
      end

      it 'makes each line selects a valid ranking option' do
        expect{
          validate_ballot! [
                               'Timestamp	Would you like to rank a full list of all 10 possible co-president candidate pairs, or to rank a single list with the five candidates?	Your Vote [A + B]	Your Vote [A + C]	Your Vote [A + D]	Your Vote [A + E]	Your Vote [B + C]	Your Vote [B + D]	Your Vote [B + E]	Your Vote [C + D]	Your Vote [C + E]	Your Vote [D + E]	Your Vote [A]	Your Vote [B]	Your Vote [C]	Your Vote [D]	Your Vote [E]	Select Two Financial Officers	Ian Gomez?',
                               '12/31/2018 18:15:55	Something spooky											Second Choice	Third Choice	First Choice	Fifth Choice	Fourth Choice	'
                           ]
        }.to raise_error(DataValidationError)
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