class Role < ApplicationRecord
	has_many :users

  serialize :authorities, Hash
end
