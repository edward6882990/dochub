require_relative 'entity'

module Serializers
  class User < Entity
    for_entity :user

    def to_hash
      data = {
        id: user.id,
        email: user.email,
        name: user.name,
        created_at: user.created_at,
        updated_at: user.updated_at
      }

      data
    end
  end
end
