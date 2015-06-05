require 'ruby-sox'

class DonkController < ApplicationController

    def index

    end

    def donk
        loop("donk", params)
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
            # ...but not each time, as they don't change
            case type
                when "kick" then 156
                when "clap" then 182
                when "donk" then 243
            end
        end

        # Calculates the gap between samples
        def space_length(clip_length, bpm)
            frequency = 60000 / bpm
            result = frequency - clip_length

            if result > 0 then result else 0 end
        end

        # Create the loop by concatenating silence and the clips
        def loop(type, params)
            bpm = params.has_key?(:bmp) ? params[:bmp].to_i : 120

            frequency = 60000 / bpm

            clip_file = "#{Rails.public_path}/clips/#{type}.wav"
            clip_padding_file = "/tmp/silence_#{frequency}.wav"
            clip_half_padding_file = "/tmp/silence_#{frequency / 2}.wav"

            system "sox -n -r 44100 -c 2 #{clip_padding_file} trim 0.0 0.#{frequency}"
            system "sox -n -r 44100 -c 2 #{clip_half_padding_file} trim 0.0 0.#{frequency / 2}"

            if (type == "kick") then
                combiner = Sox::Combiner.new(["#{clip_padding_file}", "#{clip_file}"], :combine => :concatenate)
                combiner.write("/tmp/#{type}_#{bpm}_1.wav")

                combiner = Sox::Combiner.new(["#{clip_padding_file}", "#{clip_padding_file}", "#{clip_file}"], :combine => :concatenate)
                combiner.write("/tmp/#{type}_#{bpm}_2.wav")

                combiner = Sox::Combiner.new(["#{clip_padding_file}", "#{clip_padding_file}", "#{clip_padding_file}", "#{clip_file}"], :combine => :concatenate)
                combiner.write("/tmp/#{type}_#{bpm}_3.wav")

                system "sox -m
                    #{Rails.public_path}/clips/#{type}.wav
                    /tmp/#{type}_#{bpm}_1.wav
                    /tmp/#{type}_#{bpm}_2.wav
                    /tmp/#{type}_#{bpm}_3.wav
                    #{Rails.public_path}/loops/#{type}_#{bpm}.wav"

                send_file "#{Rails.public_path}/loops/#{type}_#{bpm}.wav", :type=>"audio/wav", :filename => "#{type}_#{bpm}.wav"

            elsif (type == "clap") then
                combiner = Sox::Combiner.new(["#{clip_padding_file}", "#{clip_file}"], :combine => :concatenate)
                combiner.write("/tmp/#{type}_#{bpm}_1.wav")

                combiner = Sox::Combiner.new(["#{clip_padding_file}", "#{clip_padding_file}", "#{clip_padding_file}", "#{clip_file}"], :combine => :concatenate)
                combiner.write("/tmp/#{type}_#{bpm}_2.wav")

                system "sox -m
                    /tmp/#{type}_#{bpm}_1.wav
                    /tmp/#{type}_#{bpm}_2.wav
                    #{Rails.public_path}/loops/#{type}_#{bpm}.wav"

                send_file "#{Rails.public_path}/loops/#{type}_#{bpm}.wav", :type=>"audio/wav", :filename => "#{type}_#{bpm}.wav"

            elsif (type == "donk") then
                combiner = Sox::Combiner.new(["#{clip_half_padding_file}", "#{clip_file}"], :combine => :concatenate)
                combiner.write("/tmp/#{type}_#{bpm}_1.wav")

                combiner = Sox::Combiner.new(["#{clip_half_padding_file}", "#{clip_padding_file}", "#{clip_padding_file}", "#{clip_file}"], :combine => :concatenate)
                combiner.write("/tmp/#{type}_#{bpm}_2.wav")

                combiner = Sox::Combiner.new(["#{clip_half_padding_file}", "#{clip_padding_file}", "#{clip_padding_file}", "#{clip_padding_file}", "#{clip_padding_file}", "#{clip_file}"], :combine => :concatenate)
                combiner.write("/tmp/#{type}_#{bpm}_3.wav")

                system "sox -m
                    /tmp/#{type}_#{bpm}_1.wav
                    /tmp/#{type}_#{bpm}_2.wav
                    /tmp/#{type}_#{bpm}_3.wav
                    #{Rails.public_path}/loops/#{type}_#{bpm}.wav"

                send_file "#{Rails.public_path}/loops/#{type}_#{bpm}.wav", :type=>"audio/wav", :filename => "#{type}_#{bpm}.wav"
            end
        end
end
