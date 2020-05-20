class Payment < ApplicationRecord
  enum state: {
    pending: 0,
    succeeded: 1,
    failed: 2,
  }

  validates :state, uniqueness: { scope: :order_id }, if: -> { succeeded? }
  validates :transaction_id, :state, :amount, presence: true

  belongs_to :order

  scope :success, -> { where(state: :succeeded) }
  scope :no_success, -> { where.not(state: :succeeded) }

  def stripe_transact(token)
    if (stripe_customer = get_stripe_customer) && add_source(stripe_customer.id, token) && (charge = create_charge(stripe_customer.id))
      update_payment(charge)
      save && succeeded?
    else
      false
    end
  rescue StandardError
    false
  end

  private def get_stripe_customer

    if order.user.stripe_customer_id.blank? && !create_stripe_customer
      #FIXME_AB: logging
      return false
    end
    Stripe::Customer.retrieve(order.user.stripe_customer_id)
  end

  private def create_stripe_customer
    customer_info = {
      name: order.user.name,
      email: order.user.email,
      address: {
        line1: order.address.home_address,
        postal_code: order.address.pincode,
        city: order.address.city,
        state: order.address.state,
        country: order.address.country.upcase,
      }
      #FIXME_AB: meta info: user id , env.
    }
    #FIXME_AB: logging with customer_info
    new_stripe_cus = Stripe::Customer.create(customer_info)
    #FIXME_AB: logging: customer created on stripe with id: customer id, updating in db..
    new_stripe_cus && order.user.update(stripe_customer_id: new_stripe_cus.id)
  rescue StandardError
    #FIXME_AB: catch exception in variable and log exception message, request id
    false
  end

  #FIXME_AB: check if we can skip this step and use token directly with charge call
  private def add_source(customer_id, token)
    #FIXME_AB: logging
    a  = Stripe::Customer.create_source(
      customer_id,
      {source: token},
    )
  rescue Exception => e
    #FIXME_AB: logging
    false
  end

  private def create_charge(customer_id)
    # logging
    #FIXME_AB: pass token here
    if order.payments.success.blank? && order.payments.no_success.count <= ENV['MAX_PAYMENT_ATTEMPTS'].to_i
      Stripe::Charge.create({
        amount: order.total_amount.round * 100,
        currency: 'inr',
        description: "Payment for Order ID: #{order.id}",
        customer: customer_id,
      })
    end
  rescue Exception => e
    #FIXME_AB: logging
    # debugger
    false
  end

  private def update_payment(stripe_resp)
    self.stripe_response = stripe_resp
    self.transaction_id = stripe_resp.id
    self.state = stripe_resp.status
    self.method = stripe_resp.payment_method_details['type']
    self.amount = stripe_resp.amount / 100
    self.category = stripe_resp.object
    self.currency = stripe_resp.currency
    if self.method == 'card'
      card = stripe_resp.payment_method_details['card']
      self.card_brand = card['brand']
      self.card_last_digits = card['last4']
      self.card_exp_month = card['exp_month']
      self.card_exp_year = card['exp_year']
    end
  end

end
