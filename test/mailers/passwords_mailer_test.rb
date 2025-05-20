require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  def setup
    I18n.locale = :es
  end

  test "reset" do
    email = PasswordsMailer.reset user

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "from@example.com" ], email.from
    assert_equal [ user.email ], email.to
    assert_equal "Cambiar contraseña", email.subject
  end

  private

    def user
      @user ||= users(:regular)
    end
end
