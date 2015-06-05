class DonkController < ApplicationController

  def generate_kick
      bmp = params.has_key?(:bmp) ? params[:bmp] : 120
      pattern = params.has_key?(:pattern) ? params[:pattern] : "xxxx"

      send_file "#{Rails.public_path}/clips/kick.mp3", :type=>"audio/mp3", :filename => "kick_#{bmp}_#{pattern}.mp3"
  end
end
