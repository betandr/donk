Rails.application.routes.draw do
  get 'kick' => 'donk#kick'
  get 'clap' => 'donk#clap'
  get 'donk' => 'donk#donk'
end
