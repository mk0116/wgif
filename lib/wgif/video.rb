require 'streamio-ffmpeg'
require 'fileutils'

module WGif
  class Video
    attr_accessor :name, :clip, :logger

    def initialize(name, filepath)
      @name = name
      @clip = FFMPEG::Movie.new(filepath)
      FileUtils.mkdir_p "/tmp/wgif/#{name}/"
      @logger = Logger.new("/tmp/wgif/#{name}/#{name}.log")
      FFMPEG.logger = @logger
    end

    def trim(start_timestamp, duration)
      options = {
        custom: "-ss #{start_timestamp} -t 00:00:#{format('%06.3f', duration)}"
      }
      transcode(@clip, "/tmp/wgif/#{@name}/#{@name}-clip.mov", options)
      WGif::Video.new "#{@name}", "/tmp/wgif/#{@name}/#{@name}-clip.mov"
    end

    def to_frames(options = {})
      make_frame_dir
      if options[:frames]
        framerate = options[:frames] / @clip.duration
      else
        framerate = 24
      end
      transcode(@clip, "/tmp/wgif/#{@name}/frames/\%5d.png", "-vf fps=#{framerate}")
      open_frame_dir
    end

    private

    def make_frame_dir
      FileUtils.rm Dir.glob("/tmp/wgif/#{@name}/frames/*.png")
      FileUtils.mkdir_p "/tmp/wgif/#{@name}/frames"
    end

    def open_frame_dir
      Dir.glob("/tmp/wgif/#{@name}/frames/*.png").sort
    end

    def transcode(clip, file, options)
      clip.transcode(file, options)
    rescue FFMPEG::Error => error
      unless error.message.include? 'no output file created'
        raise WGif::ClipEncodingException
      end
      if error.message.include? 'Invalid data found when processing input'
        raise WGif::ClipEncodingException
      end
    end
  end
end
