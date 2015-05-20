require 'rails_helper'
require 'stripe_mock'

RSpec.describe ParticipationRequest::Invoice, type: :model do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  it { should belong_to(:participation_request) }

  let(:stripe_helper)  { StripeMock.create_test_helper }
  let(:pr)             { FactoryGirl.create(:participation_request, :with_participants) }
  let(:stripe_invoice) { Stripe::Invoice.upcoming(customer: structure.stripe_customer_id) }
  let(:token)          { stripe_helper.generate_card_token }

  subject { FactoryGirl.create(:participation_request_invoice, participation_request: pr) }

  describe 'pdf_url' do
    # context "when there isn't a stripe_invoice_id" do
    #
    #   it "returns nil" do
    #     expect(subject.pdf_url).to be_nil
    #   end
    # end

    context "when there's a stripe_invoice_id" do
      let(:bucket_pattern) { /.*\/coursavenue-staging.*/ }

      it "returns the generated PDF's URL" do
        allow(PDFGenerator).to receive(:generate_invoice).and_return(nil)

        expect(subject.pdf_url).to match(bucket_pattern)
      end
    end
  end

  describe '#file_path' do
    let(:structure) { pr.structure }

    it 'returns the file_path of the invoice on S3' do
      invoice_file_path = "invoices/#{ structure.slug }/participation_requests/#{ subject.id }.pdf"

      expect(subject.file_path).to eq(invoice_file_path)
    end
  end
end
