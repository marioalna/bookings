class ResourcesSeed
  class << self
    def create_seed_data(account)
      new(account).create_seed_data
    end
  end

  def initialize(account)
    @account = account
  end

  def create_seed_data
    p 'creating resources'
    add_resources
  end

  private

  attr_reader :account

  def add_resources
    account.resources.create!(
      name: 'Table 1',
      max_capacity: 8
    )
    account.resources.create!(
      name: 'Table 2',
      max_capacity: 12
    )
    account.resources.create!(
      name: 'Main office',
      max_capacity: 20
    )
    account.resources.create!(
      name: 'Gym',
      max_capacity: 50
    )
  end
end
