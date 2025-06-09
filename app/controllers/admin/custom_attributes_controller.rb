class Admin::CustomAttributesController < AdminController
  before_action :find_custom_attribute, only: %i[edit update destroy]

  def index
    @custom_attributes = Current.account.custom_attributes
  end

  def new
    @custom_attribute = Current.account.custom_attributes.new
  end

  def create
    @custom_attribute = Current.account.custom_attributes.create custom_attribute_params

    if @custom_attribute.save
      notice = t("admin.customAttributes.created")
      redirect_to admin_custom_attributes_path, notice:
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @custom_attribute.update(custom_attribute_params)
      notice = t("admin.customAttributes.updated")
      redirect_to admin_custom_attributes_path, notice:
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    @custom_attribute.destroy

    notice = t("admin.customAttributes.deleted")

    redirect_to admin_custom_attributes_path, notice:
  end

  private

    def custom_attribute_params
      params.require(:custom_attribute).permit(:name, :block_on_schedule)
    end

    def find_custom_attribute
      @custom_attribute = Current.account.custom_attributes.find params[:id]
    end
end
