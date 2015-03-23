FactoryGirl.define do
  factory :newsletter_metric, :class => 'Newsletter::Metric' do
    newsletter

    nb_email_sent 1
    nb_opening 1
    nb_click 1
  end

end
