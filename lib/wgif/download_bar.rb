module WGif
  class DownloadBar

    FORMAT = '==> %p%% |%B|'
    SMOOTHING = 0.8

    attr_reader :progress_bar

    def initialize
    end

    def update_total(size)
    end

    def increment_progress(size)
    end
  end
end
