class Admin::ResourcesController < AdminController
  before_action :find_resource, only: %i[edit update destroy]

  def index
    @resources = Current.account.resources
  end

  def new
    @resource = Current.account.resources.new
  end

  def create
    @resource = Current.account.resources.create resource_params

    if @resource.save
      notice = t("admin.resources.created")
      redirect_to admin_resources_path, notice:
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @resource.update(resource_params)
      notice = t("admin.resources.updated")
      redirect_to admin_resources_path, notice:
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    @resource.destroy

    notice = t("admin.resources.deleted")

    redirect_to admin_resources_path, notice:
  end

  private

    def resource_params
      params.require(:resource).permit(:name, :max_capacity, :photo)
    end

    def find_resource
      @resource = Current.account.resources.find params[:id]
    end
end
