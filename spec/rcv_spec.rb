require_relative '../src/format_data.rb'
require_relative '../src/rcv.rb'
require_relative '../src/errors.rb'

describe 'rcv' do

  describe 'when verifying inputs' do
    it 'requires that there is at least one ballot' do
      expect{ rcv([], []) }.to raise_error(BallotError)
    end

    it 'requires that there is at least one ballot with a candidate' do
      expect{ rcv([[]], []) }.to raise_error(BallotError)
    end

    it 'verifies that enough tie-breaking information exists' do
      ballots = [
          ['A', 'B'],
          ['B', 'A'],
      ]

      expect{ rcv(ballots, []) }.to raise_error(TieBreakingError)
    end

    it "verifies that tie-breaking information doesn't contradict itself" do
      ballots = [
          ['A', 'B'],
          ['B', 'A'],
      ]

      expect{ rcv(ballots, ['A'.beats('B'), 'B'.beats('A')]) }.to raise_error(TieBreakingError)
    end
  end

  describe 'when making decisions' do
    it 'chooses a single candidate' do
      ballots = [
          ['A'],
          [],
          ['A'],
      ]

      expect(rcv(ballots, [])).to eq('A')
    end

    it 'can decide between two pairs' do
      ballots = [
          ['A', 'B'],
          ['A', 'B'],
          ['B', 'A'],
      ]

      expect(rcv(ballots, [])).to eq('A')
    end

    it 'eliminates the last choice' do
      ballots = [
          ['A', 'B', 'C'],
          ['A', 'C', 'B'],
          ['B', 'A'],
      ]

      expect(rcv(ballots, [])).to eq('A')
    end
  end

  describe 'when breaking ties' do
    it 'breaks simple ties' do
      ballots = [
          ['A', 'B'],
          ['B', 'A'],
      ]

      expect(rcv(ballots, [ 'A'.beats('B') ])).to eq('A')
      expect(rcv(ballots, [ 'B'.beats('A') ])).to eq('B')
    end

    it 'breaks three-way ties' do
      ballots = [
          ['A', 'B'],
          ['B', 'A'],
          ['C'],
      ]

      expect(rcv(ballots, [
          'A'.beats('B'),
          'A'.beats('C'),
          'C'.beats('B'),
      ])).to eq('A')

      expect(rcv(ballots, [
          'B'.beats('A'),
          'B'.beats('C'),
          'C'.beats('A')
      ])).to eq('B')
    end
  end

end