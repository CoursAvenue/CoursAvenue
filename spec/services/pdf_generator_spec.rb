require 'rails_helper'

describe PDFGenerator do
  describe '.generate_invoice' do
    let(:invoice)  { FactoryGirl.create(:subscriptions_invoice, :payed) }
    let(:template) { 'pro/subscriptions/invoices.pdf.haml' }

    before do
      allow_any_instance_of(AWS::S3::S3Object).to receive(:write).and_return(true)
    end

    it 'does nothing if the invoice or template are not defined' do
      expect(PDFGenerator.generate_invoice(nil, nil)).to be_nil
    end

    xit 'generates the invoice as PDF' do
      PDFGenerator.generate_invoice(invoice, template)

      expect(WickedPdf).to receive(:pdf_from_string)
    end
  end
end
