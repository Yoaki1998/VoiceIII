Voice!!! API
====================

`Voice!!!` is an API for performing text-to-speech (TTS) and speech-to-text (STT) operations using various AWS services. It contains two methods: `tts` and `stt`, which handle the TTS and STT operations respectively.
Overall, this API was designed as a microservice that will be used in an app called Nemuri.

TTS API
-------

The TTS API converts input text to speech and returns a JSON response containing the URL of the generated audio file, sentiment analysis, and sentiment score.

### HTTP Request

`POST /text_to_speech`

### Query Parameters

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| text | string | Yes | The text to be converted to speech. |

### Response

On success, the API returns a JSON response with the following parameters:

| Parameter | Type | Description |
| --- | --- | --- |
| audio_url | string | The URL of the generated audio file in an S3 bucket. |
| sentiment | string | The sentiment of the input text (positive, negative, neutral). |
| sentiment_score | float | A score indicating the strength of the sentiment analysis result. |

STT API
-------

The STT API transcribes an audio file located at a given URL to text and returns the result.

### HTTP Request

`POST /speech_to_text`

### Query Parameters

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| audio_url | string | Yes | The URL of the audio file to be transcribed. |

### Response

On success, the API returns a JSON response with the following parameter:

| Parameter | Type | Description |
| --- | --- | --- |
| transcription | string | The transcribed text of the input audio file. |