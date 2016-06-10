module Serializers
  class Entity
    attr_accessor :entity

    def initialize(entity, options = {})
      @entity = entity
      @options = options
    end

    def to_hash(entity)
      raise NotImpelementedError
    end

    def hash_all_properties_of(entity)
      hash = {}
      entity.attributes.keys.each do |key|
        hash[key.to_sym] = entity.send(key.to_sym)
      end
      hash
    end

    def self.represent(entity, options = {})
      new(entity, options).to_hash
    end

    def self.to_hash(entities, options = {})
      entities.map do |entity|
        new(entity, options).to_hash
      end
    end

    def self.for_entity(entity_name)
      alias_method entity_name, :entity
    end
  end
end