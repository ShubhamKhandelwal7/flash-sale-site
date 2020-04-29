class LineItem < ApplicationRecord

  acts_as_paranoid
  belongs_to :order, optional: true
  belongs_to :deal
end