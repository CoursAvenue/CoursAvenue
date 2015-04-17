require 'rails_helper'

describe PDFGenerator do
  describe '.generate_invoice' do
    let(:invoice)  { FactoryGirl.create(subscriptions_invoice) }
    let(:template) { 'pro/subscriptions/invoices.pdf.haml' }

    it 'does nothing if the invoice or template are not defined' do
      url = PDFGenerator.generate_invoice(nil, nil)

      expect(url).to be_nil
    end

    it 'generates the invoice as PDF' do
    end

    it 'returns the invoice URL' do
    end
  end
end
