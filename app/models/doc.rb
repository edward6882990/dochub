class Doc < ActiveRecord::Base
  validates :name, presence: true,  uniqueness: { scope: :user_id, message: "Another doc with the same name already exist!" }

  belongs_to :user
end
