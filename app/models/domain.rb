# frozen_string_literal: true
# Not really a model, just a view of reports
class Domain < Sequel::Model(CSPReports.db['SELECT domain, SUM(count) AS count FROM reports GROUP BY domain ORDER BY count DESC'])
end
