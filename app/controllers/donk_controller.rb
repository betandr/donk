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
            bpm = params.has_key?(:bmp) ? params[:bmp].to_i : 120

            frequency = 60000 / bpm
            clip_padding = space_length(clip_length(type), bpm)

            tmp_padding_file = "/tmp/silence_#{clip_padding}.wav"
            tmp_frequency_file = "/tmp/silence_#{frequency}.wav"

            system "sox -n -r 44100 -c 2 #{tmp_padding_file} trim 0.0 0.#{clip_padding}"

            if (type == "kick") then
                combiner = Sox::Combiner.new(
                    [
                        "#{Rails.public_path}/clips/#{type}.wav",
                        "#{tmp_padding_file}",
                        "#{Rails.public_path}/clips/#{type}.wav",
                        "#{tmp_padding_file}",
                        "#{Rails.public_path}/clips/#{type}.wav",
                        "#{tmp_padding_file}",
                        "#{Rails.public_path}/clips/#{type}.wav",
                        "#{tmp_padding_file}",
                    ], :combine => :concatenate)

                combiner.write("#{Rails.public_path}/loops/#{type}_#{bpm}.wav")
                send_file "#{Rails.public_path}/loops/#{type}_#{bpm}.wav", :type=>"audio/wav", :filename => "#{type}_#{bpm}.wav"

            elsif (type = "clap") then

                system "sox -n -r 44100 -c 2 #{tmp_frequency_file} trim 0.0 0.#{frequency}"

                combiner = Sox::Combiner.new(
                    [
                        "#{tmp_frequency_file}",
                        "#{Rails.public_path}/clips/#{type}.wav",
                        "#{tmp_padding_file}",
                        "#{tmp_frequency_file}",
                        "#{Rails.public_path}/clips/#{type}.wav",
                        "#{tmp_padding_file}",
                    ], :combine => :concatenate)

                combiner.write("#{Rails.public_path}/loops/#{type}_#{bpm}.wav")
                send_file "#{Rails.public_path}/loops/#{type}_#{bpm}.wav", :type=>"audio/wav", :filename => "#{type}_#{bpm}.wav"
            end
        end
end
