# payment_processor_test.rb
require 'minitest/autorun'
require 'minitest/mock'
require_relative 'payment_processor'

class PaymentProcessorTest < Minitest::Test
  def setup
    # Create a fresh mock instance before every individual test run
    @mock_gateway = Minitest::Mock.new
    @processor    = PaymentProcessor.new(@mock_gateway)
  end

  def test_successful_checkout
    user_token = "tok_visa_123"
    
    # 1. Set the expectation: 
    # .expect(method_name, return_val, expected_arguments_as_array)
    @mock_gateway.expect(:charge, { status: "success", id: "ch_999" }, [{ amount: 50, card_token: user_token }])

    # 2. Execute the action under test
    result = @processor.checkout("Alice", 50, user_token)

    # 3. Assertions
    assert_equal true, result[:success]
    assert_equal "ch_999", result[:transaction_id]
    
    # 4. Verify that all expected methods on our mock object were explicitly called
    assert_mock @mock_gateway
  end

  def test_failed_checkout_from_gateway
    user_token = "tok_declined"

    # Expect the charge method but simulate a card decline response
    @mock_gateway.expect(:charge, { status: "failed", error_message: "Card Declined" }, [{ amount: 100, card_token: user_token }])

    result = @processor.checkout("Bob", 100, user_token)

    assert_equal false, result[:success]
    assert_equal "Card Declined", result[:error]
    assert_mock @mock_gateway
  end

  def test_skips_gateway_call_if_amount_is_invalid
    # In this test, we do NOT set an expectation on @mock_gateway.
    # If the main code incorrectly calls the gateway, the mock will throw an error.
    
    result = @processor.checkout("Charlie", -10, "tok_any")

    assert_equal false, result[:success]
    assert_equal "Invalid amount", result[:error]
  end
end
