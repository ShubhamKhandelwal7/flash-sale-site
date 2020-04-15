module Admin
  class DealsController < AdminController
    before_action :set_deal, only: [:show, :edit, :update, :destroy]

    def index
      @deals = Deal.with_attached_images.all
    end

    def new
      @deal = Deal.new
    end

    def create
      @deal = Deal.new(deal_params)
      respond_to do |format|
        if @deal.save
          format.html { redirect_to admin_deal_path(@deal), notice: "Deal created sucessfully"}
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
          format.html { redirect_to admin_deal_path(@deal), notice: "Deal updated sucessfully" }
        else
          format.html { render :edit }
        end
      end
    end

    def destroy
      @deal.destroy
      respond_to do |format|
        format.html { redirect_to admin_deals_path, alert: @deal.errors[:base][0] }
        flash[:notice] = "Deal destroyed sucessfully"
      end
    end

    private

    def deal_params
      params.require(:deal).permit(:title, :description, :price, :discount_price,
                                   :quantity, images: [])
    end

    def set_deal
      @deal = Deal.find(params[:id])
    end

  end
end
