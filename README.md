# Fobless
> Auto access for keypad security buildings

## Installation
1. Setup Twilio account with phone number
2. Enter request url for twilio phone number
3. Upload public/phone.mp3 to publicly available site (if you need something than the sound for 9 then you need to make your own audio file)
3. Run `bundle install`
4. Deploy app to heroku
5. Add new relic plugin to prevent site from going asleep
6. Add env variables to heroku

## Required Env Variables
```
NEW_RELIC_LICENSE_KEY=YOUR_KEY
NEW_RELIC_LOG=stdout
NEW_RELIC_APP_NAME=YOUR_APP_NAME
AUTHORIZED_NUMBERS=AUTHORIZED_NUMBERS_COMMA_SEPERATED
MP3_FILE=HTTP_URL_TO_MP3_FILE
APP_PHONE_NUMBER=+12345678
MY_PHONE_NUMBER=123-456-7890
TWILIO_ACCOUNT_SID=YOUR_TWILIO_ACCOUNT_SID
TWILIO_AUTH_TOKEN=YOUR_TWILIO_AUTH_TOKEN
```