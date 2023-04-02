
class VoiceController < ApplicationController
  before_action :aws_connexion, only: [:tts, :stt]

  def tts

    # Parse input from JSON payload
    input_text = params[:text]

    #Detect the language on input text using Amazon Comprehend
    comprehend_client = Aws::Comprehend::Client.new(region: 'eu-central-1')
    language_resp = comprehend_client.detect_dominant_language({ 
      text: input_text
    })
    language_resp = language_resp.languages[0].language_code

    # Perform sentiment analysis on input text using Amazon Comprehend
    sentiment_resp = comprehend_client.detect_sentiment({
      text: input_text,
      language_code: language_resp
    })

    # Get sentiment score and label
    sentiment_score = sentiment_resp.sentiment_score.positive
    sentiment_label = sentiment_resp.sentiment.to_s.capitalize

    # Generate audio file using Polly
    polly_client = Aws::Polly::Client.new
    if language_resp == "fr"
      response = polly_client.synthesize_speech({
        output_format: 'mp3',
        text: input_text,
        voice_id: 'Lea'
      })
    else
      response = polly_client.synthesize_speech({
        output_format: 'mp3',
        text: input_text,
        voice_id: 'Salli'
    })
    end

    # Save audio file to S3 bucket
    s3_client = Aws::S3::Client.new( region: 'eu-central-1' ) 
    obj_key = "#{SecureRandom.uuid}.mp3"
    s3_client.put_object({
      body: response.audio_stream.read,
      bucket: 'my-audio-bucket280',
      key: obj_key
    })

    # Generate pre-signed URL for audio file
    presigner = Aws::S3::Presigner.new
    audio_url = presigner.presigned_url(:get_object, bucket: 'my-audio-bucket280', key: obj_key, expires_in: 3600)

    # Return response to client with sentiment analysis and audio URL
    render json: {
      audio_url: audio_url,
      sentiment: sentiment_label,
      sentiment_score: sentiment_score
    }
  end

  def stt
    # Parse input from JSON payload
    audio_url = params[:audio_url]

    # Transcribe audio file using Amazon Transcribe
    transcribe_client = Aws::TranscribeService::Client.new(region: 'eu-central-1')
    job_name = SecureRandom.uuid
    transcribe_client.start_transcription_job({
      transcription_job_name: job_name,
      media: {
        media_file_uri: audio_url
      },
      media_format: 'mp3',
      language_code: 'en-US'
    })

    # Wait for transcription job to complete
    while true
      resp = transcribe_client.get_transcription_job({ transcription_job_name: job_name })
      break if resp.transcription_job.transcription_job_status == "COMPLETED"
      sleep 1
    end

    # Get transcription result
    transcription_result_url = resp.transcription_job.transcript.transcript_file_uri
    transcription_result = open(transcription_result_url).read

    # Return transcription result to client
    render json: {
      transcription: transcription_result
    }
  end

private 

  def aws_connexion 
    # Set up AWS credentials and clients
    Aws.config.update({
      region: 'eu-central-1',
      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    })
  end

end
