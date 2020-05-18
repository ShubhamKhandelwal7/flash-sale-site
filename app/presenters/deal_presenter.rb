class DealPresenter < ApplicationPresenter
  presents :deal

  @delegation_methods = [:published_at, :images]

  delegate *@delegation_methods, to: :deal

  def publish_status
    if published_at.present?
      "scheduled on #{published_at.to_s(:deal_publish)}"
    else
      "NOT scheduled"
    end
  end

  def cover_image
    images.first
  end
end
