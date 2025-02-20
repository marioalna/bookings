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
      name: 'Mesa 1',
      max_capacity: 15
    )
    account.resources.create!(
      name: 'Mesa 2',
      max_capacity: 10
    )
  end
end
