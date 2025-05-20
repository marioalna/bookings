class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: t('passwords.reset.reset'), to: user.email
  end
end
