require_relative '../src/format_data.rb'
require_relative '../src/rcv.rb'

describe 'rcv' do

  it 'chooses a single candidate' do
    ballots = [
        ['A'],
        [],
        ['A'],
    ]

    expect(rcv(ballots, nil)).to eq('A')
  end

  it 'can decide between two pairs' do
    ballots = [
        ['A', 'B'],
        ['A', 'B'],
        ['B', 'A'],
    ]

    expect(rcv(ballots, nil)).to eq('A')
  end

  it 'eliminates the last choice' do
    ballots = [
        ['A', 'B', 'C'],
        ['A', 'C', 'B'],
        ['B', 'A'],
    ]

    expect(rcv(ballots, nil)).to eq('A')
  end

  it 'breaks ties' do
    ballots = [
        ['A', 'B'],
        ['B', 'A'],
    ]

    expect(rcv(ballots, [ 'A'.beats('B') ])).to eq('A')
    expect(rcv(ballots, [ 'B'.beats('A') ])).to eq('B')
  end

end