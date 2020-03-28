class EntityManager
  attr_reader :entity_list, :id_at_tag, :tag_at_id

  def initialize
    @entity_list = Hash.new
    # a list of ids indexed by tag
    @id_at_tag = Hash.new
    # a list of tags indexed by id
    @tag_at_id = Hash.new
    #an array of used ids
    @used_ids = Array.new
  end

  def get_id_at_tag
    return @id_at_tag
  end

  def get_tag_at_id
    return @tag_at_id
  end

  def create_id
    id = rand(1..10000)
    while @used_ids.include?(id)
      id = rand(1..1000000)
    end
    @used_ids << id
    return id
  end

  def create_entity(tag)
    id = create_id
    @id_at_tag[tag] = id
    @tag_at_id[id] = tag
    @entity_list[id] = Array.new
    @entity_list.delete(nil)
  end

  def remove_entity_from_tag(tag)
    id = @id_at_tag[tag]
    @entity_list.delete(id)
    @id_at_tag.delete(tag)
    @tag_at_id.delete(id)
  end

  def remove_entity(id)
    @entity_list.delete(id)
    @id_at_tag.delete(tag)
    @tag_at_id.delete(id)
  end

  def add_component(tag, component)
    id = @id_at_tag[tag]
    if @entity_list[id].nil?
      @entity_list[id] = Array.new(1){component}
    else
      @entity_list[id] << component
    end
  end

  def add_components(tag, components)
    id = @id_at_tag[tag]
    components.each do |component|
      if @entity_list[id].nil?
        @entity_list[id] = Array.new(1){component}
      else
        @entity_list[id] << component
      end
    end
  end

  def components_of(id)
    components = []
    @entity_list[id].each do |comp|
      components << comp.class
    end
    return components
  end

  def has_component_of_type(id, component_class)
    return components_of(id).include?(component_class)
  end

  def get_component(id, component_class)
    @entity_list[id].each do |comp|
      if comp.to_s == component_class.to_s
        return comp
      end
    end
    return nil
  end

  def get_component_with_tag(tag, component_class)
    id = @id_at_tag[tag]
    @entity_list[id].each do |comp|
      if comp.to_s == component_class.to_s
        return comp
      end
    end
    return nil
  end

  def entities_with_component(component_class)
    entities = []
    @entity_list.each do |e|
      entity = @entity_list[e[0]]
      entity.each do |c|
        if c.to_s == component_class.to_s
          entities << e[0]
        end
      end
    end
    return entities
  end

  def entities_with_components(component_classes)
    id_list = []
    @entity_list.each do |e|
      id_list << e[0]
    end
    count = 0
    while count < id_list.length
      id = id_list[count]
      component_classes.each do |comp|
        if !has_component_of_type(id, comp)
          id_list.delete(id)
          break
        end
        count += 1
      end
    end
    return id_list
  end

  # not entirely sure if this works...
  # def add_entity(tag, entity)
  #   id = @id_at_tag[tag]
  #   @entity_list[id] << {entity => @entity_list[entity]
  # end

end
