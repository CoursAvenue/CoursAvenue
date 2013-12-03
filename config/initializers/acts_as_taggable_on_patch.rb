module ActsAsTaggableOn
  class Tag
    attr_accessible :name
  end

  class Tagging
    attr_accessible :tag_id, :context, :taggable
  end
end
