require 'rails_helper'

describe Metric do
  context '#create_action' do
    let (:structure) { FactoryGirl.create(:structure) }

    def create_metric
      metric = Metric.create_action('impression', nil, structure.id, 'abcdef', '127.0.0.1')
    end

    it 'only creates one metric per day per user' do
      create_metric

      expect { create_metric }.to_not change{ Metric.count }
    end
  end
end
