require 'rails_helper'

describe PDFGenerator do
  before do
    allow_any_instance_of(ApplicationController).to receive(:render_to_string).
      and_return(Faker::Lorem.sentence)
    allow_any_instance_of(WickedPdf).to receive(:pdf_from_string).
      and_return(Faker::Lorem.sentence)
  end

  describe '.generate_invoice' do
    let(:invoice)  { FactoryGirl.build_stubbed(:subscriptions_invoice, :payed) }
    let(:template) { 'pro/subscriptions/invoices.pdf.haml' }

    before do
      allow_any_instance_of(AWS::S3::S3Object).to receive(:write).and_return(true)
    end

    it 'does nothing if the invoice or template are not defined' do
      expect(PDFGenerator.generate_invoice(nil, nil)).to be_nil
    end

    it 'generates the invoice as PDF' do
      locals    = { :@invoice => invoice, :@structure => invoice.structure }
      generated = PDFGenerator.generate_invoice(invoice, template, locals)

      expect(generated).to be_truthy
    end
  end

  describe '.generate_gift_certificate_voucher' do
    let(:voucher) { FactoryGirl.build_stubbed(:gift_certificate_voucher) }

    it 'does nothing if the voucher is not defined' do
      expect(PDFGenerator.generate_gift_certificate_voucher(nil)).to be_nil
    end

    it 'generates the voucher as a PDF' do
      expect(PDFGenerator.generate_gift_certificate_voucher(voucher)).to_not be_nil
    end

    it 'saves the voucher in a temporary file' do
      expect(PDFGenerator.generate_gift_certificate_voucher(voucher)).to be_a(Tempfile)
    end
  end
end
