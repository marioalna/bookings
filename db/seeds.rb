return if Rails.env.production?

require_relative 'seeds/accounts_seed'
require_relative 'seeds/schedule_categories_seed'
require_relative 'seeds/resources_seed'
require_relative 'seeds/bookings_seed'

account = AccountsSeed.create_seed_data
ScheduleCategoriesSeed.create_seed_data(account)
ResourcesSeed.create_seed_data(account)
BookingsSeed.create_seed_data(account)
