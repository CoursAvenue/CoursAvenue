class Analytic::Impression
  extend ::Legato::Model

  filter :for_structure, &lambda { |structure| matches(:dimension1, structure) }

  dimensions :dimension1
  metrics :hits, :metric1
end
