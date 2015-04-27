require 'rails_helper'

describe PDFGenerator do
  describe '.generate_subscription_invoice' do
    let(:invoice)  { FactoryGirl.create(:subscriptions_invoice) }
    let(:template) { 'pro/subscriptions/invoices.pdf.haml' }

    it 'does nothing if the invoice or template are not defined' do
      expect(PDFGenerator.generate_subscription_invoice(nil, nil)).to be_nil
    end

    xit 'generates the invoice as PDF' do
      PDFGenerator.generate_subscription_invoice(invoice, template)

      expect(WickedPdf).to receive(:pdf_from_string)
    end
  end

  describe '.generate_participation_request_invoice' do
    it 'does nothing if the invoice or template are not defined' # do
    #   expect(PDFGenerator.generate_participation_request_invoice(nil, nil)).to be_nil
    # end

    it 'generates the invoice as PDF' # do
    #   PDFGenerator.generate_participation_request_invoice(invoice, template)
    #
    #   expect(WickedPdf).to receive(:pdf_from_string)
    # end
  end
end
