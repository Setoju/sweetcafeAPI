module RequestHelpers
  def json_response
    JSON.parse(response.body, symbolize_names: true)
  rescue JSON::ParserError
    {}
  end

  def expect_error_response(status, *messages)
    expect(response).to have_http_status(status)
    messages.each do |message|
      expect(json_response[:errors]).to include(message)
    end
  end

  def expect_success_response(status, message: nil)
    expect(response).to have_http_status(status)
    expect(json_response[:message]).to eq(message) if message
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
