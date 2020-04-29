REGEXPS = {
  email: /\A[^@\s]+@[-a-z0-9]+\.+[a-z]{2,}\z/i,
  password: /\A(?=.*[a-zA-Z])(?=.*[0-9]).*\z/
}

ERROR_MSGS = {
  token: "Secure Token could not be generated"
}

DEALS = {
  min_images_limit: '1',
  min_quant_limit: '10',
  max_deals_per_day: '2',
  min_tax_allowed: '0',
  max_tax_allowed: '28'
}

USERS = {
  min_password_length: '6'
}
