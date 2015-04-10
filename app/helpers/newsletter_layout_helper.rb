module NewsletterLayoutHelper
  def proportion_to_width(proportion)
    proportion == 'one-quarter' ? '150' : '450'
  end
end
