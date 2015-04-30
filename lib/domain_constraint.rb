class DomainConstraint

  def matches?(request)
    Structure.where(slug: request.subdomain).first.present?
  end
end
