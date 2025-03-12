module Accounts
  class NewAccount
    def initialize(params)
      @account_name = params[:account][:account_name]
      @user_name = params[:account][:user_name]
      @email = params[:account][:email]
    end

    def call
      account = Account.create(name: account_name, email:)

      if account.persisted?
        user = account.users.create(username: user_name, email:, password: SecureRandom.hex(24))
        user.enable_reset_password
        NewAccountMailer.notify_user(user.id).deliver_later
        true
      else
        false
      end
    end

    private

      attr_reader :account_name, :user_name, :email
  end
end
