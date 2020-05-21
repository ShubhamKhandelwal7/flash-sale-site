class Payment < ApplicationRecord
  enum state: {
    pending: 0,
    succeeded: 1,
    failed: 2,
    cancelled: 3
  }

  validates :state, uniqueness: { scope: [:order_id, :category] }, if: -> { succeeded? }
  validates :transaction_id, :state, :amount, presence: true

  belongs_to :order

  scope :success, -> { where("state = ? AND category = ?", Payment.states[:succeeded], 'charge') }
  scope :no_success, -> { where("state != ? AND category = ?", Payment.states[:succeeded], 'charge') }

  def stripe_transact(token)
    logger.info { "Reached stripe_transact method, creating customer and its charge via stripe" }
    if (stripe_customer = get_stripe_customer) && (charge = create_charge(stripe_customer.id, token))
      logger.info { "Charge updated success, updating DB with stripe resp" }
      update_payment(charge) && succeeded?
    else
      logger.info { "customer or charge failed to get created" }
      false
    end
  rescue Exception => e
    logger.info { "stripe transact failure with exception: #{e}" }
    false
  end

  def refund(charge_id)
    if order.payments.success.present?
      logger.info { "refund initiated for order ID: #{order.id}" }
      refund = Stripe::Refund.create({ charge: charge_id })
      logger.info { "refund created with ID: #{refund.id}" }
      update_payment(refund) && succeeded?
    else
      logger.info { "refund cant be initiated for order ID: #{order.id} as payment_state: not success" }
      false
    end
  rescue Exception => e
    request_failure('refund', e)
    false
  end

  private def get_stripe_customer
    if order.user.stripe_customer_id.blank? && !create_stripe_customer
      logger.info { "No stripe_customer_id present for user ID: #{order.user.id}, also create_stripe_customer failed to create new customer" }
      #FIXME_AB: logging
      return false
    end
    logger.info { "stripe_customer_id found or new stripe_customer_id created for user ID: #{order.user.id}, retrieving from Stripe" }
    Stripe::Customer.retrieve(order.user.stripe_customer_id)
  end

  private def create_stripe_customer
    logger.info { "initiating create_stripe_customer for user ID: #{order.user.id}" }
    customer_info = {
      name: order.user.name,
      email: order.user.email,
      address: {
        line1: order.address.home_address,
        postal_code: order.address.pincode,
        city: order.address.city,
        state: order.address.state,
        country: order.address.country.upcase,
      },
      #FIXME_AB: meta info: user id , env.
      metadata: {
        user_id: order.user.id,
        current_env: Rails.env,
      },
    }
    logger.info { "Creating new stripe_customer with customer_info: #{customer_info}" }
    #FIXME_AB: logging with customer_info
    new_stripe_cus = Stripe::Customer.create(customer_info)
    logger.info { "new stripe customer created with customer_id: #{new_stripe_cus.id}, updating in DB" }
    #FIXME_AB: logging: customer created on stripe with id: customer id, updating in db..
    new_stripe_cus && order.user.update(stripe_customer_id: new_stripe_cus.id)
  rescue Exception => e
    logger.info { "failed to create new stripe customer with exception: #{e.message}, request_id: #{e.response.request_id}, http_status: #{e.response.http_status}" }
    #FIXME_AB: catch exception in variable and log exception message, request id
    false
  end

  #FIXME_AB: check if we can skip this step and use token directly with charge call
  # private def add_source(customer_id, token)
  #   #FIXME_AB: logging
  #   a  = Stripe::Customer.create_source(
  #     customer_id,
  #     {source: token},
  #   )
  # rescue Exception => e
  #   #FIXME_AB: logging
  #   false
  # end

  private def create_charge(customer_id, token)
    # logging
    logger.info { "stripe customer retrieved, initiating stripe create_charge for customer_id: #{customer_id}" }
    #FIXME_AB: pass token here
    if order.payments.success.blank? && order.payments.no_success.count <= ENV['MAX_PAYMENT_ATTEMPTS'].to_i
      charge_info = {
        amount: order.total_amount.round * 100,
        currency: 'inr',
        description: "Payment for Order ID: #{order.id}",
        statement_descriptor_suffix: "Order Payment",
        source: token,     
        metadata: {
          order_id: order.id,
          current_env: Rails.env,
        },
      }
      logger.info { "Creating stripe charge with charge_info: #{charge_info}" }
      charge = Stripe::Charge.create(charge_info)
      logger.info { "stripe charge created: #{charge}, adding customer to it" }
      Stripe::Charge.update(charge.id, { customer: customer_id })
    end
  rescue Exception => e
    #FIXME_AB: logging
    request_failure('charge', e)
    false
  end

  private def request_failure(type, e)
    logger.info { "failed to create stripe #{type} with exception: #{e.message}, request_id: #{e&.response&.request_id}, http_status: #{e&.response&.http_status}" }
    if update_failed_payment(e&.response)
      logger.info { "failed payment details added to DB" }
    else
      logger.info { "failed payment details could not be added to DB" }
    end
  end

  private def update_payment(stripe_resp)
    
    self.stripe_response = stripe_resp
    self.transaction_id = stripe_resp.id
    self.state = stripe_resp.status
    self.category = stripe_resp.object
    self.amount = stripe_resp.amount / 100
    self.currency = stripe_resp.currency
    if self.method == 'card'
      card = stripe_resp.payment_method_details['card']
      self.card_brand = card['brand']
      self.card_last_digits = card['last4']
      self.card_exp_month = card['exp_month']
      self.card_exp_year = card['exp_year']
    end
    if category != 'refund'
      self.method = stripe_resp.payment_method_details['type']
    end
    save
  end

  private def update_failed_payment(stripe_resp)
    self.stripe_response = stripe_resp
    self.transaction_id = stripe_resp.request_id
    self.state = self.class.states[:failed]
    self.amount = self.order.total_amount.round
    save
  end

end
