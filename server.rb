require 'bundler'

Bundler.require

def send_text_message(body)
  twilio_client = Twilio::REST::Client.new(
    ENV['TWILIO_ACCOUNT_SID'],
    ENV['TWILIO_AUTH_TOKEN']
  )
  message = twilio_client.account.messages.create({
    from: ENV['APP_PHONE_NUMBER'],
    to: ENV['MY_PHONE_NUMBER'],
    body: body
  })
end

class SmsWorker
  include Sidekiq::Worker

  def perform(body)
    send_text_message(body)
  end
end

class Fobless < Sinatra::Base
  if ENV['NEW_RELIC_ENABLED']
    configure :production do
      require 'newrelic_rpm'
    end
  end

  error 403 do
    'Access forbidden'
  end

  get '/twilio/voice' do
    params = CGI::parse(request.query_string)
    if params['AccountSid'].first == twilio_account_sid
      if authorized_phone_numbers.include?(current_caller(params))
        SmsWorker.perform_async("Door was opened @ #{Time.now}")
        builder :authorized
      else
        builder :forward_call
      end
    else
      403
    end
  end

  private

  def twilio_account_sid
    if ENV['TWILIO_ACCOUNT_SID']
      ENV['TWILIO_ACCOUNT_SID']
    else
      raise "No valid twilio account sid"
    end
  end

  def authorized_phone_numbers
    if ENV['AUTHORIZED_NUMBERS']
      ENV['AUTHORIZED_NUMBERS'].split(",")
    else
      raise "No valid authorized phone numbers"
    end
  end

  def current_caller(params)
    if params["From"]
      params["From"].first
    else
      raise "No valid caller"
    end
  end

  def sound_file
    if ENV['MP3_FILE']
      ENV['MP3_FILE']
    else
      raise "No valid sound file"
    end
  end

  def my_phone_number
    if ENV['MY_PHONE_NUMBER'] && ENV['MY_PHONE_NUMBER'].length > 0
      ENV['MY_PHONE_NUMBER']
    else
      raise "No valid phone number"
    end
  end
end