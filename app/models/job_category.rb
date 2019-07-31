class JobCategory < ApplicationRecord
  has_many :jobs

  paginates_per 10

  def self.top_ten
    job_categories = Job.all.map(&:job_category_id)
    used = Hash.new(0)
    job_categories.each do |v|
      used[v] += 1
    end

    categories = Array.new(0)

    used.keys.each do |id|
      categories << JobCategory.where(id: id)
    end

    if used.size < 10
      categories << JobCategory.where.not(id: used.keys).first(10 - used.size)
    end

    categories.flatten
  end
end
