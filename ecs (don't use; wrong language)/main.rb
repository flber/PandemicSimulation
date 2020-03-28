require 'gosu'
require 'chunky_png'
require 'chipmunk'
require_relative 'EntityManager'
require_relative 'Components'
require_relative 'Systems'

$width = 640
$height = 480
SUBSTEPS = 6

module ZOrder
  Default = 1
end

class Main < (Eaxample rescue Gosu::Window)
  def initialize
    @font = Gosu::Font.new(20)
    @space = Array.new($width){Array.new($height){Array.new(){}}}
    super $width, $height
    self.caption = "ECS"
    @e_mng = EntityManager.new

    @ball_chunk_image = ChunkyPNG::Image.from_file("images/ball.png")
    @banana_chunk_image = ChunkyPNG::Image.from_file("images/banana.png")
    @space_chunk_image = ChunkyPNG::Image.from_file("images/space.png")

    @e_mng.create_entity("Space")
    components = [Space.new,
                  GravDir.new(0, 0.6),
                  #Stationary.new,
                  Renderable.new("images/space.png", 0, 1),
                  Location.new($width/2, $height/2, 0, 0),
                  Resistance.new(0.99),
                  Collides.new(@space_chunk_image, "Space")]
    @e_mng.add_components("Space", components)

    @e_mng.create_entity("Ball_1")
    components = [Renderable.new("images/ball.png", 0, 1),
                  Location.new(135, 95, 1, 1),
                  Collides.new(@ball_chunk_image, "Ball_1")]
    @e_mng.add_components("Ball_1", components)

    # @e_mng.create_entity("Ball_2")
    # components1 = [Renderable.new("images/ball.png", 0, 1),
    #               Location.new(505, 385, -1, -1),
    #               Collides.new(@ball_chunk_image, "Ball_2")]
    # @e_mng.add_components("Ball_2", components1)

    # @e_mng.create_entity("Banana")
    # components2 = [Renderable.new("images/banana.png", 0, 1),
    #               Location.new(295, 270, 0, 0),
    #               Collides.new(@banana_chunk_image, "Banana"),
    #               Stationary.new]
    # @e_mng.add_components("Banana", components2)

    @render = Render.new
    @acceleration = Acceleration.new
    @collisions = Collisions.new
    # @move = Move.new

    # ent_list = @e_mng.entity_list
    # id_list = []
    # ent_list.each do |ent|
    #   id_list << ent[0]
    # end
    # puts "#{id_list}"

  end

  def update
    @space = @collisions.process_tick(@e_mng, @space)
    @acceleration.process_tick(@e_mng)
    @render.process_tick(@e_mng)
    
    id1 = @e_mng.id_at_tag["Ball_1"]
    loc_comp = @e_mng.get_component(id1, Location)
    # id2 = @e_mng.id_at_tag["Ball_2"]
    if button_down?(Gosu::KB_SPACE)
      loc_comp.dx = (mouse_x - @e_mng.get_component(id1, Location).x)/10
      loc_comp.dy = (mouse_y - @e_mng.get_component(id1, Location).y)/10
      # @e_mng.get_component(id2, Location).dx = (mouse_x - @e_mng.get_component(id2, Location).x)/10
      # @e_mng.get_component(id2, Location).dy = (mouse_y - @e_mng.get_component(id2, Location).y)/10
    end
  end

  def draw
    @font.draw("x: #{mouse_x}", 10, 10, 5, 1.0, 1.0, Gosu::Color::YELLOW)
    @font.draw("y: #{mouse_y}", 10, 30, 5, 1.0, 1.0, Gosu::Color::YELLOW) # show where the mouse is
    # @move.process_tick(@e_mng)

    @point = Gosu::Image.new("images/point.png")
    components = [Collides, Location]
    @e_mng.entities_with_components(components).each do |e|
      col_comp = @e_mng.get_component(e, Collides)
      loc_comp = @e_mng.get_component(e, Location)
      outline = col_comp.shape
      hits = col_comp.hit_list
      hits.each do |point|
        @point.draw_rot(point[0], point[1], 5, 0)
      end
      outline.each do |point|
        x = point[0] - (col_comp.max_side/2) + loc_comp.x
        y = point[1] - (col_comp.max_side/2) + loc_comp.y
        @point.draw_rot(x, y, 5, 0)
      end
    end
  end

  def button_down(id)
   if id == Gosu::KB_ESCAPE
     close
   else
     super
   end
  end

  def needs_cursor?
    true
  end
end

Main.new.show if __FILE__ == $0
