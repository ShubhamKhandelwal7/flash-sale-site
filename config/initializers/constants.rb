REGEXPS = {
  email: /\A[^@\s]+@[-a-z0-9]+\.+[a-z]{2,}\z/i,
  password: /\A(?=.*[a-zA-Z])(?=.*[0-9]).*\z/,
  tax: /\A\d+(?:\.\d{0,4})?\z/
}

DEALS = {
  min_images_limit: 2,
  min_quant_limit: 11,
  max_deals_per_day: 2,
  min_tax_allowed: 0,
  max_tax_allowed: 28
}

USERS = {
  min_password_length: 6,
  max_orders_count_for_discount: 5
}

ADDRESSES = {
  pincode_length: 6
  # country_code_length: 2
}

ORDERS = {
  max_deal_quant_per_user: 1,
  max_deal_quant_per_order: 1
}

LINEITEMS = {
  default_quantity: 1
}

STATE_TRASITIONS = {
  'cart' => [ 'paid'],
  'paid' => ['placed', 'cancelled', 'refunded'],
  'placed' => ['shipped', 'cancelled', 'refunded', 'delivered'],
  'shipped'=> ['delivered', 'cancelled', 'refunded'],
  'delivered' => [],
  'cancelled' => ['refunded'],
  'refunded' => []
}

REPORTS = {
  top_customer_lookback: 6
}

ISO_COUNTRYCODES_ARRAY = IsoCountryCodes.all.collect(&:alpha2).freeze

