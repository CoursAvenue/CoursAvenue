require 'rails_helper'

describe Analytic::Client do
  # subject { Analytic.client }
  #
  # # TODO: Mock Analytic::Hit
  # describe '#hits' do
  #   let(:start_date)   { 7.days.ago }
  #   let(:end_date)     { 2.days.ago }
  #   let(:structure_id) { 974 }
  #
  #   it 'returns the metrics per date' do
  #     metrics = subject.hits(974, start_date, end_date)
  #
  #     expect(metrics).to       be_a(Array)
  #     expect(metrics.first).to be_a(OpenStruct)
  #   end
  #
  #   it 'returns the metrics within the interval' do
  #     metrics = subject.hits(974, start_date, end_date)
  #
  #     expect(Date.parse(metrics.first.date)).to eq(start_date.to_date)
  #     expect(Date.parse(metrics.last.date)).to eq(end_date.to_date)
  #   end
  # end
  #
  # describe '#impression_count' do
  # end
  #
  # describe '#view_count' do
  # end
  #
  # describe '#action_count' do
  # end
end
