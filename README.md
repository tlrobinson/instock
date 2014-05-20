### Instructions

Run locally:

  cp .env.example .env
  # fill in .env
  foreman run casperjs frys.coffee PRODUCT_ID ZIP_CODE

Setup on Heroku:

  heroku apps:create -b https://github.com/stomita/heroku-buildpack-phantomjs.git

  heroku config:set PATH=n1k0-casperjs-4f105a9/bin:/usr/local/bin:/usr/bin:/bin:/app/vendor/phantomjs/bin
  heroku config:set FROM_EMAIL="example@example.com"
  heroku config:set TO_EMAILS="example@example.com example2@example.com"
  heroku config:set MANDRILL_KEY="0123456789ABCDEF"

  git push heroku master

To run manually:

  heroku run casperjs frys.coffee PRODUCT_ID ZIP_CODE

To schedule to run automatically:

  heroku addons:add scheduler:standard
  heroku addons:open scheduler

  # Add task for "casperjs frys.coffee PRODUCT_ID ZIP_CODE"
