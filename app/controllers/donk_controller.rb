class DonkController < ApplicationController

    def index

    end

    def kick
        loop("kick", params)
    end

    def clap
        loop("clap", params)
    end

    private
        def loop(type, params)
            bmp = params.has_key?(:bmp) ? params[:bmp] : 120
            pattern = params.has_key?(:pattern) ? params[:pattern] : "xxxx"

            merge_samples

            send_file "#{Rails.public_path}/clips/#{type}.mp3", :type=>"audio/mp3", :filename => "#{type}_#{bmp}_#{pattern}.mp3"
        end
end
