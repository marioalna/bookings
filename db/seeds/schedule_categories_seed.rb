class ScheduleCategoriesSeed
  class << self
    def create_seed_data(account)
      new(account).create_seed_data
    end
  end

  def initialize(account)
    @account = account
  end

  def create_seed_data
    p 'creating schedule categories'
    add_categories
  end

  private

  attr_reader :account

  def add_categories
    account.schedule_categories.create!(
      name: 'Morning',
      colour: 'red'
    )
    account.schedule_categories.create!(
      name: 'Evening',
      colour: 'blue'
    )
  end
end
