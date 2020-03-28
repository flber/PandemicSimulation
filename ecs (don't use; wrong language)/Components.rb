module Checks
  def inWindow(x, y)
    return x > 0 && x < $width &&
           y > 0 && y < $height
  end
end

class Component
  attr_reader :id
  include Checks

  def initialize
    @id = rand(0..1000000)
  end

  def to_s
    return self.class.name
  end

end

#=================================================

class Renderable < Component
  attr_reader :image, :rotation, :width, :height, :zorder, :chunk_image

  def initialize(file_name, rot, zorder)
    @zorder = zorder
    @image = Gosu::Image.new(file_name)
    @rotation = rot
    @chunk_image = ChunkyPNG::Image.from_file(file_name)
    @width = chunk_image.width
    @height = chunk_image.height
  end

end

#=================================================

class Location < Component
  attr_accessor :x, :y, :dx, :dy

  def initialize(x, y, dx, dy)
    @x = x
    @y = y
    @dx = dx
    @dy = dy
  end

end

#=================================================

class Player < Component
  attr_reader :up, :left, :down, :right

  def initialize(up_b, left_b, down_b, right_b)
    @up = up_b
    @left = left_b
    @down = down_b
    @right = right_b
  end

end

#=================================================

class Collides < Component
  attr_reader :shape, :shape_interior, :hit_list, :max_side

  def initialize(chunk_image, id_thing)
    @cimg = chunk_image
    @id_thing = id_thing
    @width = chunk_image.width
    @height = chunk_image.height
    @max_side = [@width*2, @height*2].max
    @shape = Array.new(){}
    @shape_interior = Array.new(){}
    @hit_list = Array.new(){}
    # left_to_right
    # right_to_left
    # up_to_down
    # down_to_up
    make_large_chunky
    circle_map
    verify_shape
    fill_shape
    @large_chunky.save("images/large_#{id_thing}.png", :interlace => true)
    shape_chunky = ChunkyPNG::Image.new(@max_side, @max_side, ChunkyPNG::Color::TRANSPARENT)
    @shape.each do |point|
      x = point[0]
      y = point[1]
      shape_chunky[x, y] = ChunkyPNG::Color.rgba(0, 0, 0, 128)
      # puts "(#{x}, #{y})"
    end
    shape_chunky.save("images/shape_#{id_thing}.png", :interlace => true)
    @shape.clear
    (0..@max_side).each do |x|
      (0..@max_side).each do |y|
        if @large_chunky.get_pixel(x, y) == 255
          shape << [x, y]
        end
      end
    end
  end

  def make_large_chunky
    @large_chunky = ChunkyPNG::Image.new(@max_side, @max_side, ChunkyPNG::Color::TRANSPARENT)
    (0..@max_side).each do |x|
      (0..@max_side).each do |y|
        if (x > (@max_side/2 - @width/2) &&
            x < (@max_side - @width/2) &&
            y > (@max_side/2 - @height/2) &&
            y < (@max_side - @height/2) &&
            @cimg.get_pixel(x - (@max_side/2 - @width/2), y - (@max_side/2 - @height/2)) != nil)
            @large_chunky[x, y] = @cimg.get_pixel(x - (@max_side/2 - @width/2), y - (@max_side/2 - @height/2))
        end
      end
    end
  end

  def circle_map
    theta = 0
    phi = (1 + Math.sqrt(5))/2
    cycle = Math::PI*2
    while theta < (cycle*1000)
      r = @max_side/2
      while r > 0
        x = Math.cos(theta)*r + @max_side/2
        y = Math.sin(theta)*r + @max_side/2
        if @large_chunky.get_pixel(x, y) == 255
          @shape << [x, y]
          break
        end
        r -= 1
      end
      theta += phi
    end
  end

  def left_to_right
    y = 0
    while y < @height
      count = 0
      x = 0
      while x < @width && count < 3
        if @cimg.get_pixel(x, y) != 0
          @shape << [x,y]
          count += 1
        end
        x += 1
      end
      y += 1
    end
    # puts "l to r done!"
  end

  def right_to_left
    y = @height - 1
    while y > 0
      count = 0
      x = @width - 1
      while x > 0 && count < 3
        if @cimg.get_pixel(x, y) != 0
          @shape << [x,y]
          count += 1
        end
        x -= 1
      end
      y -= 1
    end
    # puts "r to l done!"
  end

  def up_to_down
    x = 0
    while x < @height
      count = 0
      y = 0
      while y < @width && count < 3
        if @cimg.get_pixel(x, y) != 0
          @shape << [x,y]
          count += 1
        end
        y += 1
      end
      x += 1
    end
    # puts "u to d done!"
  end

  def down_to_up
    x = @height - 1
    while x > 0
      count = 0
      y = @width - 1
      while y > 0 && count < 3
        if @cimg.get_pixel(x, y) != 0
          @shape << [x,y]
          count += 1
        end
        y -= 1
      end
      x -= 1
    end
    # puts "d to u done!"
  end

  def verify_shape
    @shape = @shape.uniq
    # puts "removed duplicates!"
  end

  def fill_shape
    (0..@height-1).each do |x|
      (0..@width-1).each do |y|
        if @cimg.get_pixel(x, y) != 0
          @shape_interior << [x,y]
        end
      end
    end
  end

end

#=================================================

class Space < Component
end

#=================================================

class Resistance < Component
  attr_accessor :res

  def initialize(resistance)
    @res = resistance
  end

end

#=================================================

class GravDir < Component
  attr_accessor :x_vel, :y_vel

  def initialize(x_vel, y_vel)
    @x_vel = x_vel
    @y_vel = y_vel
  end

end

#=================================================

class Stationary < Component
end
