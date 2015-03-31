class Analytic::Action
  extend ::Legato::Model

  filter :for_structure, &lambda { |structure| matches(:dimension1, structure) }

  dimensions :dimension1
  metrics :hits, :metric3
end
