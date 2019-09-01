require 'spec_helper'
require 'wgif/cli'

describe 'frame order bug', regression: true do
  it 'does not create frames out of order' do
    args =  ['https://www.youtube.com/watch?v=2-r0n5utZhE',
             'tmp.gif',
             '-s',
             '2:22',
             '-d',
             '10',
             '-f',
             '100',
             '-w',
             '200']
    WGif::CLI.new.make_gif(args)
    frames = Dir.entries("/tmp/wgif/2-r0n5utZhE/frames")
    filenames = (1..170).map { |n| sprintf '%05d.png', n }
    expect(frames).to eq(['.', '..'] + filenames)
  end
end
