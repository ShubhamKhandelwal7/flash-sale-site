json.deals @past_deals do |deal|
  json.title deal.title
  json.description deal.description
  json.price deal.price
  json.discount_price deal.discount_price
  json.published_on deal.live_begin.to_s(:deal_publish)
  json.tax deal.tax
end
