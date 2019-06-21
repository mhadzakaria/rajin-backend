class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.to_csv(records, attributes)
    CSV.generate(headers: true) do |csv|
      csv << attributes.map{|a| a.remove('_csv').titleize }

      records.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def json_delete_timestamp
    attribute = self.attributes
    attribute.delete('created_at')
    attribute.delete('updated_at')
    attribute
  end
end
