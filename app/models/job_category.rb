class JobCategory < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }

  has_many :jobs
  has_many :childs, foreign_key: :parent_id, class_name: 'JobCategory'
  belongs_to :parent, class_name: 'JobCategory', optional: true

  paginates_per 10

  def self.top_ten
    used       = Hash.new(0)
    categories = Array.new(0)

    job_categories = Job.all.map(&:job_category_id)
    job_categories.each do |v|
      used[v] += 1
    end

    top_ten_categories = Hash[used.sort_by{|k, v| v}.reverse]
    top_ten_categories.keys.first(10).each do |id|
      categories << JobCategory.find_by(id: id)
    end

    if used.size < 10
      categories << JobCategory.where.not(id: used.keys).first(10 - used.size)
    end

    categories.flatten
  end
end
