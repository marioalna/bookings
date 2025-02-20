class Admin::UsersController < AdminController
  before_action :find_user, only: %i[edit update destroy]

  def index
    @users = Current.account.users
  end

  def new
    @user = Current.account.users.new
  end

  def create
    @user = Current.account.users.create user_params

    if @user.save
      notice = t("admin.users.created")
      redirect_to admin_users_path, notice:
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      notice = t("admin.users.updated")
      redirect_to admin_users_path, notice:
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy

    notice = t("admin.users.deleted")

    redirect_to admin_users_path, notice:
  end

  private

    def user_params
      params.require(:user).permit(:name, :username, :email, :password, :active)
    end

    def find_user
      @user = Current.account.users.find params[:id]
    end
end
