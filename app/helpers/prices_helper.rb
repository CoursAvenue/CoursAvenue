# encoding: utf-8
module PricesHelper

  def readable_amount amount
    if amount.nil?
      nil
    else
      ('%.2f' % amount).gsub('.', ',').gsub(',00', '')
    end
  end

end
