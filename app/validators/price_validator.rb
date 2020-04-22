class PriceValidator < ActiveModel::Validator
  def validate(record)
    return true if record.price && record.price > (record.discount_price || 0)
    record.errors.add(:price, I18n.t(".errors.discount_price"))
  end
end