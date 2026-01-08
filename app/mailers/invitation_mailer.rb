class InvitationMailer < ApplicationMailer

  def invite_user(invitation)
    @invitation = invitation
    @registration_url = new_user_registration_url(token: @invitation.token, host: 'www.acctra.me')
    headers['X-SMTPAPI'] = {
      "filters" => {
        "clicktrack" => { "settings" => { "enable" => 0 } }
      }
    }.to_json
    mail(to: @invitation.email, subject: 'You’re invited to join the platform!')
  end
end
