module Admin
  class DealsController < AdminController
    before_action :set_deal, only: [:show, :edit, :update, :destroy, :check_publishability, :publish, :unpublish]

    def index
      sort_by = (params[:sort] && params[:sort][:sort_by].present?) ? params[:sort][:sort_by] : 'published_at'
      order = (params[:order] && params[:order][:order_by].present?) ? params[:order][:order_by] : 'asc'
      @deals = Deal.with_attached_images.order("#{sort_by} #{order}")
                   .page(params[:page]).per(ENV["PER_PAGE_DEAL"].to_i)
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
      render json: { status: @deal.publish(params[:publish_date]), publish_presenter: @deal.presenter.publish_status }
    end

    def unpublish
      if @deal.unpublish
        flash[:notice] = "Deal #{@deal.title} unscheduled succsssfully"
      else
        flash[:alert] = "Deal could not get unscheduled"
      end
      redirect_to admin_deal_path(@deal.id)
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
