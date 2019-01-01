require_relative '../scripts/generate_tie_breakers'

describe 'generate_tie_breakers utility' do

  it 'can pair items' do
    expect(pair(['A', 'B', 'C'])).to eq([
                                            ['A', 'B'],
                                            ['A', 'C'],
                                            ['B', 'C']
                                        ])
  end

  it 'can give a basic pairing' do
    allow(STDIN).to receive(:gets) { '1' }
    allow(STDOUT).to receive(:puts) { }

    result = generate_tie_breakers(['A', 'B', 'C'])
    expect(result).to eq([
                             'A + B > A + C',
                             'A + B > B + C',
                             'A + C > B + C'
                         ])

    first_call = true
    allow(STDIN).to receive(:gets) do
      if first_call
        first_call = false
        '2 '
      else
        '1'
      end
    end

    result = generate_tie_breakers(['A', 'B', 'C'])
    expect(result).to eq([
                             'A + C > A + B',
                             'A + B > B + C',
                             'A + C > B + C'
                         ])
  end
end