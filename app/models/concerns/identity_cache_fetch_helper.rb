# Defines simple class method allowing you to fetch a model by its id or slug.
# Usage:
#     Add `include Concerns::IdentityCacheFetchHelper` to your model,
#     and call `Model.fetch_by_id_or_slug(id_or_slug)`.
module Concerns
  module IdentityCacheFetchHelper
    extend ActiveSupport::Concern

    included do
      def self.fetch_by_id_or_slug(param)
        if param.to_s.match(/\D/)
          self.fetch_by_slug(param)
        else
          self.fetch(param)
        end
      end
    end
  end
end
