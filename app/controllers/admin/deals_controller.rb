module Admin
  class DealsController < AdminController
    before_action :set_deal, only: [:show, :edit, :update, :destroy]

    def index
      @deals = Deal.with_attached_images.page(params[:page]).per(1)
    end

    def new
      @deal = Deal.new
    end

    def create
      @deal = Deal.new(deal_params)
      respond_to do |format|
        if @deal.save
          format.html { redirect_to admin_deal_path(@deal), notice: t("create.flash.success")}
        else
          format.html { render :new }
        end
      end
    end

    def show
      if params[:publishable_check_date]
        @status = @deal.can_be_scheduled_to_publish_on(Date.parse(params[:publishable_check_date]))
      end
      respond_to do |format|
        format.js
        format.html
      end
    end

    def edit
    end

    def update
      respond_to do |format|
        if @deal.update(deal_params)
          format.html { redirect_to admin_deal_path(@deal), notice: t("update.flash.success") }
        else
          format.html { render :edit }
        end
      end
    end

    def destroy
      @deal.destroy
      respond_to do |format|
        format.html { redirect_to admin_deals_path, alert: @deal.errors[:base][0] }
        flash[:notice] = t("destroy.flash.success")
      end
    end

    private def deal_params
      params.require(:deal).permit(:title, :description, :price, :discount_price,
                                   :quantity, images: [])
    end

    private def set_deal
      @deal = Deal.find(params[:id])
      redirect_to login_path, notice: "Please login again" if @deal.blank?
    end

  end
end
