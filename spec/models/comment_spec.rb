# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Comment do
  let(:structure_comment) { FactoryGirl.create(:structure_comment) }
  let(:structure) { course.structure }

  context :structure do
    it 'returns the structure' do
      structure_comment.structure.should be structure_comment.commentable
    end
  end
end
