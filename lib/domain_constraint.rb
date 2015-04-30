class DomainConstraint

  def matches?(request)
    Bugsnag.notify(RuntimeError.new("DomainConstraint"),
                                    { request: request, subdomain: request.subdomain })
    Structure.where(slug: request.subdomain).first.present?
  end
end
