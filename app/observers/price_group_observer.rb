class PriceGroupObserver < ActiveRecord::Observer

  def after_save(price_group)
    price_group.structure.update_meta_datas
  end
end
