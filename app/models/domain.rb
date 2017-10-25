# frozen_string_literal: true
#
# Not really a model, just a view of reports
class Domain < Sequel::Model
  dataset_module do
    def by_most_frequent
      order(Sequel.desc(:count))
    end
  end
end
