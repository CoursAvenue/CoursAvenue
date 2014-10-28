ActiveRecord::Base.class_eval do
  def encode_with_override_override(coder)
    encode_with_without_override(coder)
    coder.tag = "!ruby/ActiveRecord:#{self.class.name}" unless coder.is_a? ::Hash
  end
  alias_method :encode_with, :encode_with_override_override
end
