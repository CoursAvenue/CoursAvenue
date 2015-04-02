# Legato model for the actions metric.
# The `dimension1` and `metric3` are defined in Google Analytics' dashboard.
# `dimension1` is The structure id and `metric3` is the actions count.
#
# We also use the default date dimension and hits metric.
# This allows us to filter by structure and by date, and to get the hits and the actions.
class Analytic::Action
  extend ::Legato::Model

  filter :for_structure, &lambda { |structure| matches(:dimension1, structure) }

  dimensions :dimension1, :date
  metrics :hits, :metric3
end
# More information:
# <https://www.google.com/analytics/web/?authuser=1#management/Settings/a36532956w65949456p67806356/%3Fm.page%3DCustomMetrics%26m-content-metricsTable.rowShow%3D10%26m-content-metricsTable.rowStart%3D0%26m-content-metricsTable.sortColumnId%3Dindex%26m-content-metricsTable.sortDescending%3Dfalse/>
