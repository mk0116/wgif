require 'youtube-dl.rb'
require 'typhoeus'
require 'wgif/download_bar'
require 'wgif/exceptions'
require 'wgif/video'
require 'wgif/video_cache'
require 'uri'
require 'cgi'

module WGif
  class Downloader

    def initialize
      @cache = WGif::VideoCache.new
    end

    def video_id(youtube_url)
      uri = URI(youtube_url)
      params = CGI.parse(uri.query)
      params['v'].first
    rescue
      raise WGif::InvalidUrlException
    end

    def get_video(youtube_url)
      id = video_id youtube_url
      cached_clip = @cache.get(id)
      if cached_clip
        cached_clip
      else
        path = load_clip(id, youtube_url)
        video = WGif::Video.new(id, path)
        video
      end
    end

    private

    def create_progress_bar(request, output_file)
      size = nil
      download_bar = WGif::DownloadBar.new

      request.on_headers do |response|
        size = response.headers['Content-Length'].to_i
        download_bar.update_total(size)
      end

      request.on_body do |chunk|
        output_file.write(chunk)
        download_bar.increment_progress(chunk.size)
      end
    end

    def load_clip(id, youtube_url)
      FileUtils.mkdir_p '/tmp/wgif'
      path = "/tmp/wgif/#{id}"
      full_path = "/tmp/wgif/#{id}.webm"
      unless File.exist?(full_path)
        YoutubeDL.download youtube_url, output: path
      end
      full_path
    end
  end
end
