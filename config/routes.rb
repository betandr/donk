Rails.application.routes.draw do
  root 'donk#index'

  get 'kick' => 'donk#kick'
  get 'clap' => 'donk#clap'
  get 'donk' => 'donk#donk'
end
