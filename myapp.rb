require 'sinatra'
require 'stripe'
require 'dotenv'
Dotenv.load

# Set your secret key. Remember to switch to your live secret key in production.
# See your keys here: https://dashboard.stripe.com/apikeys
Stripe.api_key = ENV['STRIPE_API_KEY']

Stripe.api_version = '2023-10-16'
account_id = ENV['STRIPE_ACCOUNT_ID']

set :static, true
set :port, 3000
set :public_folder, 'public'

# Create a checkout session dynamically based on the passed amount
post '/create-checkout-session' do
  content_type 'application/json'

  amount = params[:amount].to_i * 100  # Convert dollars to cents

  session = Stripe::Checkout::Session.create(
    {
      line_items: [
        {
          price_data: {
            currency: 'aud',
            product_data: { name: 'water bill' },
            unit_amount: amount,
          },
          quantity: 1,
        },
      ],
      payment_intent_data: { application_fee_amount: 123 },
      mode: 'payment',
      invoice_creation: { enabled: true },
      success_url: 'http://localhost:3000/success?session_id={CHECKOUT_SESSION_ID}',
    },
    { stripe_account: account_id }
  )
  
  redirect session.url, 303
end

#create a page to server checkout.html
get '/' do
  @amount = params[:amount] || 10  # Default amount is 10 ($10 AUD)
  erb :index
end

# create a page to serve success.html and use the session_id to get the session details from stripe
get '/success' do
  session_id = params[:session_id]
  puts "Session ID: #{session_id}"  # Log the session ID for debugging

  begin
    # Retrieve the checkout session details
    session = Stripe::Checkout::Session.retrieve(session_id, { stripe_account: account_id })
    
    # Retrieve the invoice associated with the session
    invoice = Stripe::Invoice.retrieve(session.invoice, {stripe_account: account_id})

    # Retrieve the PaymentIntent
    payment_intent = Stripe::PaymentIntent.retrieve(session.payment_intent, { stripe_account: account_id })
    
    # Retrieve the Charge using the latest_charge field from the PaymentIntent
    charge = Stripe::Charge.retrieve(payment_intent.latest_charge, { stripe_account: account_id })
    
    # create a object to pass on to client side which contains checkout_session.amount_total / 100.0 ,invoice.number and reciept_url
 
    receipt_url= charge.receipt_url
    invoice_number= invoice.number
    amount_total=session.amount_total / 100.0
  

    puts "Session: #{session}"  # Log the session for debugging
    puts "Receipt URL: #{receipt_url}"  # Log the receipt URL for debugging

    # Pass the receipt URL to the success page for download
    erb :success, locals: { receipt_url: receipt_url, invoice_number: invoice_number, amount_total:amount_total }

  rescue Stripe::InvalidRequestError => e
    puts "Stripe error: #{e.message}"
    erb :error, locals: { message: "There was an error retrieving your session." }
  end
end