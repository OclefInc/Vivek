class MagicLinkMailer < ApplicationMailer
  def login_link(user)
    @user = user
    @magic_link_url = users_magic_link_url(token: @user.magic_link_token)

    mail(
      to: @user.email,
      subject: "Your login link for #{ENV.fetch('APP_NAME', 'Vivek')}"
    )
  end
end
