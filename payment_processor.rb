# payment_processor.rb

# Simulates a production client that talks to a third-party payment gateway API.
class PaymentGatewayClient
  def charge(amount:, card_token:)
    # In production, this would make an external HTTP network request
    raise "Network Error: Cannot connect to real gateway during tests!"
  end
end

# The core service object containing business logic under test
class PaymentProcessor
  def initialize(gateway_client = PaymentGatewayClient.new)
    @gateway = gateway_client
  end

  def checkout(user, amount, card_token)
    return { success: false, error: "Invalid amount" } if amount <= 0

    # Delegate the actual payment collection to our dependency
    response = @gateway.charge(amount: amount, card_token: card_token)

    if response[:status] == "success"
      { success: true, transaction_id: response[:id] }
    else
      { success: false, error: response[:error_message] }
    end
  end
end
