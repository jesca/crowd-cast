# Written by Jhoong and Sukriti
require 'digest/sha1'
require 'net/http'

class ReservationsController < ApplicationController
  wrap_parameters :reservation, include: [:advertisement_id, :listing_id, :dates, :start_date, :end_date, :price]

  # GET /reservations/new
  def new
    @listing = Listing.find(params[:listing_id])
    @reservation = Reservation.new
    username = cookies[:username]
    if (advertiser = Advertiser.find_by_username(username))
      @ads = Advertisement.getAds(advertiser.id)
    end
  end

  def get
    reservation_params = get_reservations_params
    listing = Listing.find(reservation_params[:listing_id])
    reservation_params.delete("listing_id")
    reservation_params.merge!(:listing => listing)
    reservations = Reservation.get(reservation_params)
    if reservations and reservations.any?
      reservation_dates = []
      reservations.each do |reservation|
         reservation_dates.push({ start: reservation.start_date, end: reservation.end_date})
      end
      render :json => reservation_dates
    else
      render :json => { status: -1 }
    end
  end

  # POST /reservations
  # POST /reservations.json
  def create
    reservation_params = create_reservations_params
    # lets verify these entries actually exist
    username = cookies[:username]
    advertiser = Advertiser.find_by_username(username)
    listing = Listing.find(reservation_params[:listing_id])
    advertisement = Advertisement.find(reservation_params[:advertisement_id])
    reservation_params.delete("listing_id")
    reservation_params.delete("advertisement_id")
    reservation_params.merge!(:advertiser => advertiser, :listing => listing, :advertisement => advertisement)
    order = Digest::SHA1.hexdigest "" + advertiser.id.to_s + reservation_params[:dates].to_s + Time.new.to_s 
    
    # For each reservation, create
    dates = reservation_params[:dates]
    reservation_params.delete("dates")
    reservations = []
    dates.each do |reservation|
       reservation = Reservation.new(reservation_params.merge(:start_date => reservation[:start_date],  
                                                              :end_date => reservation[:end_date], 
                                                              :price => reservation[:price],
                                                              :completed => false,
                                                              :order => order ))
        # If one reservation is invalid, abort
        if not reservation.valid?
          errors = reservation.errors
          if errors[:full_dates].any?
            return render :json => {status: -1, conflicts: errors[:full_dates]}
          else
            return render :json => {status: -1}
          end
       else
          reservations.push(reservation)
       end
    end
    # Save reservations
    total_amount = 0
    reservations.each do |reservation|
      reservation.save
      total_amount += reservation.price
    end
    Reservation.delay(run_at: 2.minutes.from_now).deleteOrder(order)
    return render :json => { status: 1, order: order, total: total_amount }
  end
   
   # Clean out the tables
    def resetFixture
        Reservation.TESTAPI_resetFixture
        render :json => { status: 1 }
    end

  def show
    @order_id = params[:order_id]
    @order_price = params[:total_amount]
  end

  def confirm_payment 
    # Used as guide: http://stackoverflow.com/questions/14316426/is-there-a-paypal-ipn-code-sample-for-ruby-on-rails
    response = validate_IPN_notification(request.raw_post)
    case response
    when "VERIFIED"
      if params[:payment_status] == "Pending" || params[:payment_status] == "Completed"
          Reservation.completePayment(params[:custom])
      end
      # check that paymentStatus=Completed
      # check that txnId has not been previously processed
      # check that receiverEmail is your Primary PayPal email
      # check that paymentAmount/paymentCurrency are correct
      # process payment
    end
    render :nothing => true
  end 
  
  protected 
  def validate_IPN_notification(raw)
    uri = URI.parse('https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 60
    http.read_timeout = 60
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl = true
    response = http.post(uri.request_uri, raw,
                         'Content-Length' => "#{raw.size}",
                         'User-Agent' => "My custom user agent"
                       ).body

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def create_reservations_params
      params.require(:reservation).permit(:listing_id, :advertiser_id, :advertisement_id, dates: [ :start_date, :end_date, :price])
    end
   
    def get_reservations_params
      params.permit(:listing_id, :start_date, :end_date)
    end
end
