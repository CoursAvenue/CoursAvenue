# For Passenger
web: bundle exec passenger start -p $PORT --max-pool-size ${MAX_POOL_SIZE:-15}
worker: bundle exec rake jobs:work
mailers: QUEUE=mailers bundle exec rake jobs:work
cards: QUEUE=cards bundle exec rake jobs:work

# For Puma
# web: bundle exec puma -C config/puma.rb
# web: bundle exec puma -t ${PUMA_MIN_THREADS:-10}:${PUMA_MAX_THREADS:-10} -w ${PUMA_WORKERS:-2} -p $PORT -e ${RACK_ENV:-development}

# For Thin
# web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb -E $RACK_ENV
