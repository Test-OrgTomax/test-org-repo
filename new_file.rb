# The production class we want to test
class PaymentProcessor
  def initialize(api_client)
    @api_client = api_client
  end

  def charge(amount)
    response = @api_client.post_charge(amount)
    response[:status] == 200
  end
end

# RSpec Test
RSpec.describe PaymentProcessor do
  it 'successfully charges the client' do
    # 1. Create a generic mock/test double
    mock_api_client = double('StripeClient')
    
    # 2. Stub a method and define its return value
    allow(mock_api_client).to receive(:post_charge).with(100).and_return(status: 'success')
    
    processor = PaymentProcessor.new(mock_api_client)
    expect(processor.charge(100)).to be true
  end

  it 'verifies a method was actually called (Spies / Expectations)' do
    mock_api_client = double('StripeClient')
    
    # Set an expectation BEFORE execution: the test will fail if this isn't called
    expect(mock_api_client).to receive(:post_charge).with(50).and_return(status: 'failed')
    
    processor = PaymentProcessor.new(mock_api_client)
    processor.charge(50)
  end
end
