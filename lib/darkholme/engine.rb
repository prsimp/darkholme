module Darkholme
  # An Engine contains all of a game's entities, components, and systems.
  # Usually only one is needed for your entire game, although no limitation
  # is hardcoded. Use at your discretion.
  class Engine
    attr_reader :systems, :entities, :families

    # Create a new engine with empty systems and entities
    #
    # @return [Engine] The new Engine
    def initialize
      @systems = {}
      @families = {}
      @entities = Set.new
    end

    # Add an entity to the engine (with callbacks). Once added,
    # the entity is available for use by systems during each
    # update loop.
    #
    # @param entity [Entity] The entity to add
    #
    # @return Result of entity#added_to_engine
    def add_entity(entity)
      @entities << entity
      entity.added_to_engine self
    end

    # Remove an entity from the engine (with callbacks). Once removed,
    # the entity will no longer be updated during the update loop
    #
    # @param entity [Entity] The entity to remove
    #
    # @return Result of entity#removed_from_engine
    def remove_entity(entity)
      @entities.delete entity
      entity.removed_from_engine self
    end

    # Add a system to be updated each frame
    #
    # @param system [System] The system to add
    #
    # @return Result of system#added_to_engine
    def add_system(system)
      @systems[system.class] = system
      system.added_to_engine self
    end

    # Remove a system from the engine. It will no longer be updated
    # each frame
    #
    # @param system_class [Class] Class of System to remove
    #
    # @return Result of system#removed_from_engine
    def remove_system(system_class)
      system = @systems.delete system_class
      system.removed_from_engine(self) if system
    end

    # Retrieve a system added to the engine by its class
    #
    # @param system_class [Class] Class of the system to get
    #
    # @example Standard usage
    #   engine.system_for(MySystem)
    #
    # @return [System] A System instance, if found
    def system_for(system_class)
      @systems[system_class]
    end

    # Retrieve all entities matching Family provided
    #
    # @param family [Family] Family to use when checking entities
    #
    # @example Standard usage
    #   engine.entities_for_family(
    #     Family.for(MyComponent, AnotherComponent)
    #   )
    #
    # @return [Array<Entity>] All entities matching provided Family
    def entities_for_family(family)
      @families[family] ||= begin
        Set.new.tap do |entities|
          @entities.each do |entity|
            entities << entity if family.member?(entity)
          end
        end
      end
    end

    # Update all systems within engine. This should called once per
    # frame in game.
    #
    # @param delta [Float] Time between last frame and this one
    #
    # @example Standard usage
    #   engine.update(0.0008)
    def update(delta)
      @systems.each {|klass, system| system.update(delta) }
    end

    # A callback called every time an entity added to the engine
    # has a component added. Updates all associated families
    def component_added(entity, component)
      @families.each do |family, entities|
        unless entity.family_bits.set?(family.index)
          if family.member?(entity)
            entities << entity
            entity.family_bits.set(family.index)
          end
        end
      end
    end

    # A callback called every time an entity added to the engine
    # has a component removed. Updates all associated families
    def component_removed(entity, component)
      @families.each do |family, entities|
        if entity.family_bits.set?(family.index)
          unless family.member?(entity)
            entities.delete(entity)
            entity.family_bits.clear(family.index)
          end
        end
      end
    end
  end
end
