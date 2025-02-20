class Admin::ScheduleCategoriesController < AdminController
  before_action :find_schedule_category, only: %i[edit update destroy]

  def index
    @schedule_categories = Current.account.schedule_categories
  end

  def new
    @schedule_category = Current.account.schedule_categories.new
  end

  def create
    @schedule_category = Current.account.schedule_categories.create schedule_category_params

    if @schedule_category.save
      notice = t('admin.scheduleCategories.created')
      redirect_to admin_schedule_categories_path, notice:
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @schedule_category.update(schedule_category_params)
      notice = t('admin.scheduleCategories.updated')
      redirect_to admin_schedule_categories_path, notice:
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @schedule_category.destroy

    notice = t('admin.scheduleCategories.deleted')

    redirect_to admin_schedule_categories_path, notice:
  end

  private

    def schedule_category_params
      params.require(:schedule_category).permit(:name, :icon, :colour)
    end

    def find_schedule_category
      @schedule_category = Current.account.schedule_categories.find params[:id]
    end
end
