module Admin
  class DealsController < AdminController
    before_action :set_deal, only: [:show, :edit, :update, :destroy, :check_publishability, :publish]

    def index
      #FIXME_AB: Lets give a dropdown in the frontend to order by created_at, publish date. default should be publish date. with ASC DESC
      @deals = Deal.with_attached_images.order(published_at: :asc).page(params[:page]).per(ENV["PER_PAGE_DEAL"].to_i)
    end

    def sort
      @deals = Deal.with_attached_images.order("#{params[:sort][:sort_by]} #{params[:order][:order_by]}")
                   .page(params[:page]).per(ENV["PER_PAGE_DEAL"].to_i)
      render :index
    end

    def new
      @deal = Deal.new
    end

    def create
      @deal = Deal.new(deal_params)
      respond_to do |format|
        if @deal.save
          format.html { redirect_to admin_deal_path(@deal), notice: t(".flash.success")}
        else
          format.html { render :new }
        end
      end
    end

    def edit
    end

    def update
      respond_to do |format|
        if @deal.update(deal_params)
          format.html { redirect_to admin_deal_path(@deal), notice: t(".flash.success") }
        else
          format.html { render :edit }
        end
      end
    end

    def destroy
      if @deal.destroy
        flash[:notice] = t(".flash.success")
      else
        flash[:error] = "#{t(".flash.failure")} #{@deal.errors[:base][0]}"
      end
      redirect_to admin_deals_path
    end

    def check_publishability
      if params[:publishable_check_date]
        @status = @deal.can_be_scheduled_to_publish_on(Date.parse(params[:publishable_check_date]))
      end
    end

    def publish
      publish_on_date = Date.parse(params[:publish_date])
      if publish_on_date.present? && @deal.can_be_scheduled_to_publish_on(publish_on_date)
        @deal.published_at = publish_on_date
        @status = @deal.save
        flash.now[:notice] = "Deal #{@deal.title} is now Published"
      else
        @status = false
        flash.now[:alert] = "Deal could not get Published on this date"
      end
    rescue StandardError
      @status = false
      flash.now[:alert] = "Deal could not get Published on this date"
    end

    def delete_image_attachment
      @deal_image = ActiveStorage::Attachment.find(params[:id])
      @deal_image.purge_later
      render json: { status: true }
    rescue ActiveRecord::RecordNotFound
      render json: { status: false }
    end

    private def deal_params
      params.require(:deal).permit(:title, :description, :price, :discount_price,
                                   :quantity, :tax, images: [])
    end

    private def set_deal
      @deal = Deal.find(params[:id])
      if @deal.blank?
        redirect_to login_path, notice: "Please login again"
      end
    end

  end
end
