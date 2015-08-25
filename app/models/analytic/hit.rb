# Legator model for all of the metrics.
# The `dimension1`, `metric1`, `metric2` and `metric3` are defined in Google Analytics' dashboard.
# `dimension1` is The structure id
# `metric1`    is the impression count.
# `metric2`    is the view count.
# `metric3`    is the phone_number count.
# `metric4`    is the website count.
#
# We also use the default date dimension and hits metric.
# This allows us to filter by structure and by date, and to get the hits and the actions.
class Analytic::Hit
  extend ::Legato::Model

  filter :for_structure, &lambda { |structure| matches(:dimension1, structure) }

  dimensions :dimension1, :date
  metrics :hits, :metric1, :metric2, :metric3, :metric4, :pageviews
end
# More information:
# <https://www.google.com/analytics/web/?authuser=1#management/Settings/a36532956w65949456p67806356/%3Fm.page%3DCustomMetrics%26m-content-metricsTable.rowShow%3D10%26m-content-metricsTable.rowStart%3D0%26m-content-metricsTable.sortColumnId%3Dindex%26m-content-metricsTable.sortDescending%3Dfalse/>
