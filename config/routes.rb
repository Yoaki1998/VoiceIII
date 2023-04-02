Rails.application.routes.draw do
  post '/text_to_speech', to: 'voice#tts'
  post '/speech_to_text', to: 'voice#stt'
end
