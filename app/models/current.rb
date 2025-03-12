class Current < ActiveSupport::CurrentAttributes
  attribute :session, :account
  delegate :user, to: :session, allow_nil: true

  def session=(session)
    super
    return if user.blank?

    self.account = user.account
  end
end
