class Analytic::Hit
  extend ::Legato::Model

  filter :for_structure, &lambda { |structure| matches(:dimension1, structure) }

  dimensions :dimension1
  metrics :hits, :metric1, :metric2, :metric3
end
