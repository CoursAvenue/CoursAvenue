
namespace :orders do
  desc 'Generate the invoices of existing orders'
  task :generate => :environment do
    Order.all.each(&:upload_invoice)
  end
end
