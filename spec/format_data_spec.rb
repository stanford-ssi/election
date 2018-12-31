require_relative '../src/format_data.rb'

describe 'format_data' do

  it 'monkey patches String' do
    expect('A'.beats('B')).to eq(['A', 'B'])
    expect('C'.beats('D')).to eq(['C', 'D'])
  end

end