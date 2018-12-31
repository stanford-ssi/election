require_relative '../src/format_data.rb'

describe 'format_data' do

  it 'monkey patches String' do
    expect('A'.beats('B')).to eq(['A', 'B'])
    expect('C'.beats('D')).to eq(['C', 'D'])

    expect('A'.loses_to('B')).to eq(['B', 'A'])
    expect('C'.loses_to('D')).to eq(['D', 'C'])
  end

end