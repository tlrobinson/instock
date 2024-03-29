system = require 'system'

VERBOSE = system.env.VERBOSE is "true"
LOG_LEVEL = system.env.LOG_LEVEL or "warn"
MANDRILL_KEY = system.env.MANDRILL_KEY
FROM_EMAIL = system.env.FROM_EMAIL or ""
TO_EMAILS = ({ email: email } for email in system.env.TO_EMAILS.split(" "))

MANDRILL_HOST = "https://mandrillapp.com"

sendEmail = (subject="", body="") ->
  body = body.replace(/[\u0080-\uffff]/g, "")

  console.log "Sending #{body} to", TO_EMAILS

  url = MANDRILL_HOST + '/api/1.0/messages/send.json'
  data =
    key: MANDRILL_KEY
    message:
      text: body
      subject: subject
      from_email: FROM_EMAIL
      to: TO_EMAILS
    async: false

  casper = require('casper').create
    verbose: VERBOSE
    logLevel: LOG_LEVEL
  casper.start()
  casper.thenOpen(url, method: 'POST', data: JSON.stringify(data, null, 2))
  .run()

checkFrys = (product, zip, distance) ->
  casper = require('casper').create
    verbose: VERBOSE
    logLevel: LOG_LEVEL

  args = casper.cli.args
  product = product or args[0]
  zip = zip or args[1]
  distance = distance or args[2] or 100

  console.log "Checking Frys: ", product, zip, distance

  productUrl = "http://www.frys.com/product/#{product}"
  productTitle = ""

  casper.start()
  casper.thenOpen(productUrl)
  .then ->
    productTitle = @evaluate ->
      document.querySelector(".product_title b").innerText
    @click "#product_storepickup_info a"
  .then ->
    @fill 'form[action^="/wf"]',
      pickupZip: zip
      distance: distance
    , false
    @click '[name="a=STORE_INV_CHECK,w=CHECKOUT"]'
  .wait 10000, ->
    console.log "waited 10sec"
  .then ->
    stores = @evaluate ->
      for row in Array::slice.call(document.querySelectorAll("[name=storeSelect] tr"), 3)
        try
          store: row.querySelector("td:first-child b").innerText
          availability: row.querySelector("td:last-child").innerText isnt "Items unavailable"
    available = (store.store for store in stores when store.availability)
    console.log "product:", productTitle
    console.log "url:", productUrl
    console.log "available:", available
    if available.length > 0
      sendEmail "[Frys] #{productTitle}", "http://www.frys.com/product/#{product}\n\nAvailable:\n\n" + available.join("\n")
  .wait 10000, ->
    console.log "waited 10sec"
  .run()

checkFrys()
