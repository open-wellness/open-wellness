require 'rave-ruby'

module Payments
  def self.included base
    base.extend(Flutterwave)
  end
  
  class << self
    attr_accessor :rave_client
  end
  
  def self.set_rave_client
    public_key = Rails.application.credentials.rave[:public_key]
    auth_token = Rails.application.credentials.rave[:auth_token]

    unless public_key.blank? && auth_token.blank?
      @rave_client = RaveRuby.new(public_key, auth_token)
    end
  end
  
  class Flutterwave
    class Rave
      Payments.set_rave_client

      # Allows payments from bank accounts in Nigeria, USA and South Africa
      def self.account(bank_name, bank_account_number, charge_currency, payment_type, country,
        charge_amount, email, phone_number, first_name, last_name, ip_address, device_fingerprint)
        payload = {
          "accountbank" => bank_name,
          "accountnumber" => bank_account_number,
          "currency" => charge_currency,
          "payment_type" =>  payment_type,
          "country" => country,
          "amount" => charge_amount, 
          "email" => email,
          "phonenumber" => phone_number,
          "firstname" => first_name,
          "lastname" => last_name,
          "IP" => ip_address,
          "redirect_url" => Rails.configuration.rave[:default_redirect_url],
          "device_fingerprint" => device_fingerprint
        }

        charge_account = Account.new(@rave_client)

        response = charge_account.initiate_charge(payload)
        Rails.logger.info "Flutterwave Rave account charge initiation performed. Response: " << response
        
        if response["validation_required"]
          response = charge_account.validate_charge(response["flwRef"], "12345")
          Rails.logger.info "Flutterwave Rave account charge validation performed. Response: " << response
        end
        
        response = charge_account.verify_charge(response["txRef"])
        Rails.logger.info "Flutterwave Rave account charge verification performed. Response: " << response
      end

      def self.card_charge(card_number, card_cvv, card_expiry_month, card_expiry_year, charge_currency,
        card_country, charge_amount, email, phone_number, first_name, last_name, ip_address, meta_data,
        device_fingerprint, billing_zip, billing_city, billing_address, billing_state, billing_country)
        payload = {
          "cardno" => card_number,
          "cvv" => card_cvv,
          "expirymonth" => card_expiry_month,
          "expiryyear" => card_expiry_year,
          "currency" => charge_currency,
          "country" => card_country,
          "amount" => charge_amount,
          "email" => email,
          "phonenumber" => phone_number,
          "firstname" => first_name,
          "lastname" => last_name,
          "IP" => ip_address,
          "meta" => meta_data,
          "redirect_url" => Rails.configuration.rave[:default_redirect_url],
          "device_fingerprint" => device_fingerprint
        }

        charge_card = Card.new(@rave_client)
        response = charge_card.initiate_charge(payload)

        if response["suggested_auth"]
          suggested_auth = response["suggested_auth"]
          auth_arg = charge_card.get_auth_type(suggested_auth)
          if auth_arg == :pin
            updated_payload = charge_card.update_payload(suggested_auth, payload, pin: params[:pin])
          elsif auth_arg == :address
            updated_payload = charge_card.update_payload(suggested_auth, payload, address:{"billingzip"=> billing_zip, "billingcity"=> billing_city, "billingaddress"=> billing_address, "billingstate"=> billing_state, "billingcountry"=> billing_country})
          end

          response = charge_card.initiate_charge(updated_payload)
          Rails.logger.info "Flutterwave Rave card charge initiation performed. Response: " << response

          if response["validation_required"]
            response = charge_card.validate_charge(response["flwRef"], "12345")
            Rails.logger.info "Flutterwave Rave card charge validation performed. Response: " << response
          end
        else
          # You can handle the get the auth url from this response and load it for the customer to complete the transaction if an auth url is returned in the response.
          print response
        end

        response = charge_card.verify_charge(response["txRef"])
        Rails.logger.info "Flutterwave Rave card charge verification performed. Response: " << response
      end

      def self.preauth_capture(card_token, card_country, charge_amount, email,
        first_name, last_name, ip_address, currency)
        payload = {
          "token" => card_token,
          "country" => card_country,
          "amount" => charge_amount,
          "email" => email,
          "firstname" => first_name,
          "lastname" => last_name,
          "IP" => ip_address,
          "currency" => currency
        }

        preauth = Preauth.new(@rave_client)
        response = preauth.capture(response["flwRef"], "30")
        Rails.logger.info "Flutterwave Rave pre-authorization charge capture performed. Response: " << response

        response = preauth.verify_preauth(response["txRef"])
        Rails.logger.info "Flutterwave Rave pre-authorization charge verification performed. Response: " << response
      end

      def self.preauth_charge(card_token, card_country, charge_amount, email,
        first_name, last_name, ip_address, currency)
        payload = {
          "token" => card_token,
          "country" => card_country,
          "amount" => charge_amount,
          "email" => email,
          "firstname" => first_name,
          "lastname" => last_name,
          "IP" => ip_address,
          "currency" => currency
        }

        preauth = Preauth.new(@rave_client)
        response = preauth.initiate_charge(payload)
        Rails.logger.info "Flutterwave Rave pre-authorization charge initiation performed. Response: " << response

        response = preauth.verify_preauth(response["txRef"])
        Rails.logger.info "Flutterwave Rave pre-authorization charge verification performed. Response: " << response
      end

      def self.preauth_refund(card_token, card_country, charge_amount, email,
        first_name, last_name, ip_address, currency)
        payload = {
          "token" => card_token,
          "country" => card_country,
          "amount" => charge_amount,
          "email" => email,
          "firstname" => first_name,
          "lastname" => last_name,
          "IP" => ip_address,
          "currency" => currency
        }

        preauth = Preauth.new(@rave_client)
        response = preauth.initiate_charge(payload)
        Rails.logger.info "Flutterwave Rave pre-authorization charge initiation performed. Response: " << response

        response = preauth.refund(response["flwRef"])
        Rails.logger.info "Flutterwave Rave pre-authorization charge refund performed. Response: " << response

        response = preauth.verify_preauth(response["txRef"])
        Rails.logger.info "Flutterwave Rave pre-authorization charge verification performed. Response: " << response
      end

      def self.preauth_void(card_token, card_country, charge_amount, email,
        first_name, last_name, ip_address, currency)
        payload = {
          "token" => card_token,
          "country" => card_country,
          "amount" => charge_amount,
          "email" => email,
          "firstname" => first_name,
          "lastname" => last_name,
          "IP" => ip_address,
          "currency" => currency
        }

        preauth = Preauth.new(@rave_client)
        response = preauth.initiate_charge(payload)
        Rails.logger.info "Flutterwave Rave pre-authorization charge initiation performed. Response: " << response

        response = preauth.void(response["flwRef"])
        Rails.logger.info "Flutterwave Rave pre-authorization charge void performed. Response: " << response

        response = preauth.verify_preauth(response["txRef"])
        Rails.logger.info "Flutterwave Rave pre-authorization charge verification performed. Response: " << response
      end

      def self.ghana_mobile_money(charge_amount, email, phone_number, mobile_operator_network, ip_address)
        payload = {
          "amount" => charge_amount,
          "email" => email,
          "phonenumber" => phone_number,
          "network" => mobile_operator_network,
          "redirect_url" => Rails.configuration.rave[:ghana_mobile_money_redirect_url],
          "IP" => ip_address
        }

        charge_mobile_money = MobileMoney.new(@rave_client)

        response = charge_mobile_money.initiate_charge(payload)
        Rails.logger.info "Flutterwave Rave Ghana mobile money charge initiation performed. Response: " << response

        response = charge_mobile_money.verify_charge(response["txRef"])
        Rails.logger.info "Flutterwave Rave Ghana mobile money charge verification performed. Response: " << response
      end

      def self.mpesa(charge_amount, phone_number, email, ip_address, transaction_narration)
        payload = {
          "amount" => charge_amount,
          "phonenumber" => phone_number,
          "email" => email,
          "IP" => ip_address,
          "narration" => transaction_narration,
        }

        charge_mpesa = Mpesa.new(@rave_client)
        response = charge_mpesa.initiate_charge(payload)
        Rails.logger.info "Flutterwave Rave Mpesa charge initiation performed. Response: " << response

        response = charge_mpesa.verify_charge(response["txRef"])
        Rails.logger.info "Flutterwave Rave Mpesa charge verification performed. Response: " << response
      end
      
      def self.list_subscriptions
        subscription = Subscription.new(@rave_client)
        response = subscription.list_all_subscription
      end

      def self.fetch_subscription(id)
        subscription = Subscription.new(@rave_client)
        response = subscription.fetch_subscription(id)
      end

      def self.activate_subscription(id)
        subscription = Subscription.new(@rave_client)
        response = subscription.activate_subscription(id)
      end

      def self.cancel_subscription(id)
        subscription = Subscription.new(@rave_client)
        response = subscription.cancel_subscription(id)
      end

      def self.transfer_single(bank_name, bank_account_number, charge_amount
        transaction_narration, charge_currency)
        payload = {
          "account_bank" => bank_name,
          "account_number" => bank_account_number,
          "amount" => charge_amount,
          "narration" => transaction_narration,
          "currency" => charge_currency,
        }

        transfer = Transfer.new(@rave_client)
        response = transfer.initiate_transfer(payload)
        Rails.logger.info "Flutterwave Rave single transfer initiated. Response: " << response
      end

      def self.transfer_bulk(title, bulk_transaction_list, charge_currency, transaction_narration)
        payload = {
          "title" => title,
          "bulk_data" => bulk_transaction_list
        }

         transfer = Transfer.new(@rave_client)
         response = transfer.bulk_transfer(payload)
         Rails.logger.info "Flutterwave Rave bulk transfer initiated. Response: " << response
      end

      def self.uganda_mobile_money(amount, phone_number, first_name, last_name,
        mobile_network_operator, email, ip_address)
        # This is used to perform mobile money charge
        payload = {
          "amount" => amount,
          "phonenumber" => phone_number,
          "firstname" => first_name,
          "lastname" => last_name,
          "network" => mobile_network_operator,
          "email" => email,
          "IP" => ip_address,
          "redirect_url" => Rails.configuration.rave[:uganda_mobile_money_redirect_url]
        }

        charge_uganda_mobile_money = UgandaMobileMoney.new(@rave_client)
        response = charge_uganda_mobile_money.initiate_charge(payload)
        Rails.logger.info "Flutterwave Rave Uganda mobile money charge initiation performed. Response: " << response

        response = charge_uganda_mobile_money.verify_charge(response["txRef"])
        Rails.logger.info "Flutterwave Rave Uganda mobile money charge verification performed. Response: " << response
      end

      def self.zambia_mobile_money(amount, phone_number, first_name, last_name,
        mobile_network_operator, email, ip_address)
        # This is used to perform zambia mobile money charge
        payload = {
          "amount" => amount,
          "phonenumber" => phone_number,
          "firstname" => first_name,
          "lastname" => last_name,
          "network" => mobile_network_operator,
          "email" => email,
          "IP" => ip_address,
          "redirect_url" => Rails.configuration.rave[:zambia_mobile_money_redirect_url]
        }

        charge_zambia_mobile_money = ZambiaMobileMoney.new(@rave_client)
        response = charge_zambia_mobile_money.initiate_charge(payload)
        Rails.logger.info "Flutterwave Rave Zambia mobile money charge initiation performed. Response: " << response

        response = charge_zambia_mobile_money.verify_charge(response["txRef"])
        Rails.logger.info "Flutterwave Rave Zambia mobile money charge verification performed. Response: " << response
      end

      def self.list_banks
        response = ListBanks.new(@rave_client)
      end
    end
  end
end
