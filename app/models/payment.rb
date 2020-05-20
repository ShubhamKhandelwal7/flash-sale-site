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
    if (stripe_customer = create_stripe_customer) && add_source(stripe_customer.id, token) && (charge = create_charge(stripe_customer.id))
      update_payment(charge)
      save && succeeded?
    else
      false
    end
  rescue StandardError
    false
  end

  private def create_stripe_customer
    Stripe::Customer.create({
      name: order.user.name,
      address: {
        line1: order.address.home_address,
        postal_code: order.address.pincode,
        city: order.address.city,
        state: order.address.state,
        country: order.address.country.upcase,
      }
    })
  rescue StandardError
    false
  end

  private def add_source(customer_id, token)
    Stripe::Customer.create_source(
      customer_id,
      {source: token},
    )
  rescue StandardError
    false
  end

  private def create_charge(customer_id)
    if order.payments.success.blank? && order.payments.no_success.count <= ENV['MAX_PAYMENT_ATTEMPTS'].to_i
      Stripe::Charge.create({
        amount: order.total_amount.round * 100,
        currency: 'inr',
        description: 'Order Payment',
        customer: customer_id,
      })
    end
  rescue StandardError
    false
  end

  private def update_payment(stripe_resp)
    self.transaction_id = stripe_resp.id
    self.state = stripe_resp.status
    self.method = stripe_resp.payment_method_details['type']
    self.amount = stripe_resp.amount
    self.category = stripe_resp.object
    self.currency = stripe_resp.currency
  end
  
end