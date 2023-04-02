require "test_helper"

class VoiceControllerTest < ActionDispatch::IntegrationTest
  test "should get tts_or_stt" do
    get voice_tts_or_stt_url
    assert_response :success
  end
end
