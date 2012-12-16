module CoursesHelper
  def readable_promotion promotion
    if promotion.blank?
      ""
    else
      "#{(promotion * 100).to_i} %"
    end
  end
end
