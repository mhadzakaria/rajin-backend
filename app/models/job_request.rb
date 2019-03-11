class JobRequest < ApplicationRecord
	include AASM

  belongs_to :user
  belongs_to :job

  aasm :column => :status do
    state :accepted
    state :rejected

    event :accept do
      transitions from: [:rejected], to: :accepted
    end
    event :reject do
      transitions from: [:accepted], to: :rejected
    end
  end
end
