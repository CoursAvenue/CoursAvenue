class Analytic::View
  extend ::Legato::Model

  filter :for_structure, &lambda { |structure| matches(:dimension1, structure) }

  dimensions :dimension1
  metrics :hits, :metric2
end
