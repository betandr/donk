require 'ruby-sox'

class DonkController < ApplicationController

    clip_lengths = {'kick' => 156, 'clap' => 182}

    def index

    end

    def kick
        loop("kick", params)
    end

    def clap
        loop("clap", params)
    end

    private
        def clip_length(type)
            # Calculated using:
            # sox kick.mp3 -n stat 2>&1 | sed -n 's#^Length (seconds):[^0-9]*\([0-9.]*\)$#\1#p'
            # ...not each time, as they don't change
            case type
                when "kick"
                    156
                when "clap"
                    182
            end
        end

        def space_length(clip_length, bpm)
            frequency = 60000 / bpm
            frequency - clip_length
        end

        def loop(type, params)
            bmp = params.has_key?(:bmp) ? params[:bmp].to_i : 120
            pattern = params.has_key?(:pattern) ? params[:pattern] : "xxxx"

            clip_padding = space_length(clip_length(type), bmp)

            tmp_file = "/tmp/silence_#{clip_padding}.wav"

            system "sox -n -r 44100 -c 2 #{tmp_file} trim 0.0 0.#{clip_padding}"

            combiner = Sox::Combiner.new(
                [
                    "#{Rails.public_path}/clips/#{type}.mp3",
                    "#{tmp_file}",
                    "#{Rails.public_path}/clips/#{type}.mp3",
                    "#{tmp_file}",
                    "#{Rails.public_path}/clips/#{type}.mp3",
                    "#{tmp_file}",
                    "#{Rails.public_path}/clips/#{type}.mp3",
                    "#{tmp_file}",
                ], :combine => :concatenate)



            combiner.write("#{Rails.public_path}/clips/#{type}_#{bmp}_#{pattern}.mp3")

            send_file "#{Rails.public_path}/clips/#{type}_#{bmp}_#{pattern}.mp3", :type=>"audio/mp3", :filename => "#{type}_#{bmp}_#{pattern}.mp3"
        end
end
