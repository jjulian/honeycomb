class PaymentsController < ApplicationController  
  verify :params => :person_id, :render => :error, :add_flash => { :notice => "You must specify a person ID" }, :only => :new
  verify :params => :token, :redirect_to => :new_payment_url, :only => [:confirm]
  before_filter :find_payment, :only => [:confirm, :complete]
  
  # NB amount is always in pennies
  def new
    @payment = Payment.new(:person_id => params[:person_id],:amount => params[:amount] || 0)
    @person_id = params[:person_id]
  end
  
  def create
    @payment = Payment.create(params[:payment])

    if @payment.valid?
      setup_response = gateway.setup_purchase(@payment.amount,
        :ip                => request.remote_ip,
        :return_url        => confirm_payment_url(@payment),
        :cancel_return_url => new_payment_url(:amount => @payment.amount, :person_id => @payment.person_id)
      )
      @payment.update_attribute(:token,setup_response.token)
      redirect_to gateway.redirect_url_for(setup_response.token)
    else
      render :action => :error
    end
  end
    
  def confirm
    details_response = gateway.details_for(params[:token])

    if details_response.success?
      @address = details_response.address
      state = "Success"
    else
      flash.now[:notice] = details_response.message
      state = "Error"
      render :action => 'error'
    end

    @payment.update_attributes(:details => details_response,:state => state)
  end

  def complete
    # it's okay to modify the amount from what was originally sent to paypal    
    amount = params[:payment][:amount].to_i
    
    purchase = gateway.purchase(amount,
      :ip       => request.remote_ip,
      :payer_id => params[:payer_id],
      :token    => params[:token]
    )

    @payment.update_attribute(:amount,amount)

    if purchase.success?
      @payment.update_attribute(:state,"Complete")
    else
      @payment.update_attribute(:state,purchase.message)
      flash.now[:notice] = "There was a problem with your purchase: #{purchase.message}"
      render :action => 'error'
    end
  end
  
  private

  def find_payment
    @payment = params[:token] ? Payment.find_by_token(params[:token]) : Payment.find_by_id(params[:id])
    if @payment.nil?
      flash.now[:notice] = "Could not find that payment"
      render :action => 'error', :status => 404
    end
  end
  
  def gateway
    @gateway ||= ActiveMerchant::Billing::PaypalExpressGateway.new(PAYPAL_CREDS)
  end

end