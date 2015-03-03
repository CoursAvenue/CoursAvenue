require 'rails_helper'

describe Metric do
  # Metrics are freezed
  # describe '.create_action' do
  #   it 'creates an action for each structure' do
  #     options = metric_defaults.merge(s_id: (1..10).to_a)

  #     expect { create_metric(options) }.to change { Metric.count }.by(10)
  #   end

  #   it 'only creates one metric per day per user' do
  #     create_metric

  #     expect { create_metric }.to_not change{ Metric.count }
  #   end
  # end
end

def create_metric(options = metric_defaults, method = :create_action)
  Metric.send(method, options[:action], options[:s_id],
                       options[:fingerprint], options[:ip_address], options[:infos])
end

def metric_defaults
  { action:      'impression',
    s_id:        Faker::Number.number(1),
    fingerprint: 'abcdef',
    ip_address:  '127.0.0.1',
    infos:       nil
  }
end
