require_relative 'entity'

module Serializers
  class Doc < Entity
    for_entity :doc

    def to_hash
      data = {
        id: doc.id,
        content: doc.content,
        # TODO: Include later for single entity call
        # raw_data: doc.raw_data,
        classification: doc.classification
      }

      data
    end
  end
end
