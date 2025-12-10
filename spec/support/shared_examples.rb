RSpec.shared_examples 'requires authentication' do |method, path|
  it 'returns unauthorized without authentication' do
    send(method, path)
    expect(response).to have_http_status(:unauthorized)
    expect(json_response[:errors]).to eq('Unauthorized')
  end
end

RSpec.shared_examples 'requires admin access' do |method, path, params = {}|
  let(:user) { create(:user) }

  it 'returns forbidden for non-admin users' do
    send(method, path, params: params, headers: auth_headers(user))
    expect(response).to have_http_status(:forbidden)
  end
end

RSpec.shared_examples 'validates presence of' do |field|
  it "validates presence of #{field}" do
    subject.send("#{field}=", nil)
    expect(subject).not_to be_valid
    expect(subject.errors[field]).to include("can't be blank")
  end
end

RSpec.shared_examples 'validates uniqueness of' do |field|
  it "validates uniqueness of #{field}" do
    duplicate = subject.dup
    subject.save!
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[field]).to include('has already been taken')
  end
end

RSpec.shared_examples 'paginatable' do
  it 'responds to pagination parameters' do
    expect(described_class).to respond_to(:page)
  end
end
