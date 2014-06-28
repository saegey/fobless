web: bundle exec rackup config.ru -p $PORT
worker: bundle exec sidekiq -c 2 -r ./server.rb
