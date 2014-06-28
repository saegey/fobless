ENV['RACK_ENV'] = 'test'

require './server'
require 'rspec'
require 'rack/test'
require 'nokogiri'
require 'sidekiq/testing'
require 'coveralls'

describe 'Fobless' do
  include Rack::Test::Methods

  Sidekiq::Testing.fake!
  Coveralls.wear!

  def app
    Fobless.new
  end

  it "forwards phone call" do
    get "/twilio/voice?AccountSid=#{ENV['TWILIO_ACCOUNT_SID']}"
    expect(last_response).to be_ok
    expect(last_response.header['Content-Type']).to include('application/xml;charset=utf-8')
    expect(last_response.body).to have_xpath('/Response')
    expect(last_response.body).to have_xpath('//Dial')
    expect(last_response.body).to have_xpath('//Dial/@timeout').with_text(10)
    expect(last_response.body).to have_xpath('//Dial/@record').with_text("false")
    expect(last_response.body).to have_xpath('//Dial/.').with_text(ENV['MY_PHONE_NUMBER'])
  end

   it "plays sound file to open door" do
    get "/twilio/voice?From=#{escaped_number}&AccountSid=#{ENV['TWILIO_ACCOUNT_SID']}"
    expect(last_response).to be_ok
    expect(last_response.header['Content-Type']).to include('application/xml;charset=utf-8')
    expect(last_response.body).to have_xpath('/Response')
    expect(last_response.body).to have_xpath('//Play/@digits').with_text(ENV['KEYPAD_CODE'])
  end

  it "text messages user when access is granted" do
    get "/twilio/voice?From=#{escaped_number}&AccountSid=#{ENV['TWILIO_ACCOUNT_SID']}"
  end

  it "forbids access for invalid accounts" do
    get "/twilio/voice?From=#{escaped_number}&AccountSid=123"
    expect(last_response).to_not be_ok
    expect(last_response.body).to eq('Access forbidden')
  end

  it "sends text message" do
    body = "Door was opened @ #{Time.now}"
    message = send_text_message(body)
    expect(message.status).to eq("queued")
    expect(message.from).to eq(ENV['APP_PHONE_NUMBER'])
    expect(message.body).to eq(body)
    expect(message.to).to eq("+1#{ENV['MY_PHONE_NUMBER'].gsub('-', '')}")
    expect(message.sid).to be_true
  end

  it "queues a text message if authroized phone number" do
    SmsWorker.jobs.clear
    get "/twilio/voice?From=#{escaped_number}&AccountSid=#{ENV['TWILIO_ACCOUNT_SID']}"
    expect(SmsWorker.jobs.size).to eq(1)
  end

  it "shoud not queue text message for unauthorized number" do
    SmsWorker.jobs.clear
    get "/twilio/voice?From=AccountSid=#{ENV['TWILIO_ACCOUNT_SID']}"
    expect(SmsWorker.jobs.size).to eq(0)
  end

  it "should return awesome for heartbeat url" do
    get "/heartbeat"
    expect(last_response).to be_ok
    expect(last_response.body).to eq("awesome")
  end

  private

  def escaped_number
    CGI.escape(authorized_numbers.first)
  end

  def authorized_numbers
    ENV['AUTHORIZED_NUMBERS'].split(",")
  end
end