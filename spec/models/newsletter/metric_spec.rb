require 'rails_helper'

RSpec.describe Newsletter::Metric, type: :model do
  subject { FactoryGirl.create(:newsletter_metric) }
end
