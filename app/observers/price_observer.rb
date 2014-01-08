class PriceObserver < ActiveRecord::Observer

  def after_save(price)
    price.structure.update_meta_datas
  end
end
