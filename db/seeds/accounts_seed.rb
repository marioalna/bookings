class AccountsSeed
  class << self
    def create_seed_data
      new.create
    end
  end

  def create
    p 'creating account'
    create_account

    @account
  end

  private

    def create_account
      @account = Account.create!(id: 1, name: 'HR Company', email: 'admin@test.com')
      create_users
    end

    def create_users
      user = @account.users.create! name: "Mario Alvarez", username: 'marioalvarezuser', email: 'admin@test.com', role: User::ADMIN,
                             password: '111111', password_confirmation: '111111'
      @account.users.create! name: "Jorge Alvarez", username: 'jorgeuser', email: 'regular@test.com', role: User::REGULAR,
                             password: '111111', password_confirmation: '111111'
    end
end
