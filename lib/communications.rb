require 'twilio-ruby'
require 'sendgrid-ruby'

module Communications
  def self.included base
    base.extend(Twilio, Sendgrid)
  end
  
  class << self
    attr_accessor :twilio_client, :sendgrid_client
  end
  
  def self.setup_twilio_client
    account_sid = Rails.application.credentials.twilio[:account_sid]
    auth_token = Rails.application.credentials.twilio[:auth_token]
    
    unless account_sid.blank? && auth_token.blank?
      @twilio_client = ::Twilio::REST::Client.new(account_sid, auth_token)
    end
  end
  
  def self.setup_sendgrid_client
    api_key = Rails.application.credentials.sendgrid[:api_key]
    
    unless api_key.blank?
      @sendgrid_client = ::SendGrid::API.new(api_key: api_key)
    end
  end
  
  class Twilio
    ::Communications.setup_twilio_client
    
    class Mms
      def self.send(body, recipient_mobile_number, media_url)
        begin
          message = @twilioclient.messages.create(body: body,
            from: ENV['twilio_mms_send_number'],
            media_url: [media_url],
            to: recipient_mobile_number)
          Rails.logger.info "Twilio MMS message create performed. SID: " << message.sid
        rescue Twilio::REST::TwilioError => e
          Rails.logger.error "Twilio MMS message create error. Message: " << e.message
        end
      end
    end

    class Sms
      def self.send(body, recipient_mobile_number)
        begin
          message = @twilio_client.messages.create(
            body: body,
            from: ENV['twilio_sms_send_number'],
            to: recipient_mobile_number)
          Rails.logger.info "Twilio SMS message create performed. SID: " << message.sid
        rescue Twilio::REST::TwilioError => e
          Rails.logger.error "Twilio SMS message create error. Message: " << e.message
        end
      end
    end
    
    class WhatsApp
      def self.send(body, recipient_whatsapp_number)
        begin
        message = @twilio_client.messages.create(
          from: 'whatsapp:' << ENV['twilio_whatsapp_send_number'],
          body: body,
          to: 'whatsapp:' << recipient_whatsapp_number)
        Rails.logger.info "Twilio WhatsApp message create performed. SID: " << message.sid
      rescue Twilio::REST::TwilioError => e
        Rails.logger.error "Twilio WhatsApp message create error. Message: " << e.message
      end
      end
    end
  end
  
  class Sendgrid
    ::Communications.setup_sendgrid_client
    
    class Email
      def self.send(recipient_email, message_type, message_subject, message_body)
        from = Email.new(email: 'test@example.com')
        to = Email.new(email: recipient_email)
        subject = message_subject
        content = Content.new(type: message_type, value: message_body)
        mail = Mail.new(from, subject, to, content)
        
        response = @sendgrid_client.client.mail._('send').post(request_body: mail.to_json)
        Rails.logger.info "Sendgrid emial send performed. Status: " << response.status_code
      end
    end
  end
end