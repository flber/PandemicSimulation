module Checks
  def inWindow(x, y)
    return x > 0 && x < $width &&
           y > 0 && y < $height # return if you're in the window
  end
end

class System

  include Checks

  def process_tick
    raise RuntimeError, "You're doing something wrong!" # this shouldn't be reached!
  end

end

#=================================================

class Render < System

  def process_tick(ent_mng)
    component_list = [Renderable, Location]
    ent_mng.entities_with_components(component_list).each do |e| # get every entity with a location and a renderable comp
      if ent_mng.has_component_of_type(e, Location)
        render_comp = ent_mng.get_component(e, Renderable)
        loc_comp = ent_mng.get_component(e, Location) # get its components
        x = loc_comp.x
        y = loc_comp.y
        angle = render_comp.rotation
        image = render_comp.image
        image.draw_rot(x, y, render_comp.zorder, angle) # draw the image at its coordinates
      end
    end
  end

end

#=================================================

class Acceleration < System

  def process_tick(ent_mng)
    ent_mng.entities_with_component(Location).each do |e| # find every entity with a location component
      loc_comp = ent_mng.get_component(e, Location)
      if !ent_mng.has_component_of_type(e, Stationary) # if it doesn't have a Stationary component as well...
        loc_comp.x += loc_comp.dx
        loc_comp.y += loc_comp.dy # add the velicity to the location
      end
    end
  end

end

#=================================================

class Collisions < System

  def process_tick(ent_mng, space)
    space.clear
    space = Array.new($width){Array.new($height){Array.new(){}}}
    component_list = [Collides, Location, Renderable]
    ent_mng.entities_with_components(component_list).each do |e|
      # puts "e: #{e}"
      if ent_mng.has_component_of_type(e, Space)
        col_comp = ent_mng.get_component(e, Collides)
        loc_comp = ent_mng.get_component(e, Location)
        render_comp = ent_mng.get_component(e, Renderable)
        int_shape = col_comp.shape_interior
        int_shape.each do |point|
          x = point[1] - 45 - (render_comp.height/2) + loc_comp.x
          y = point[0] + 45 - (render_comp.width/2) + loc_comp.y
          if inWindow(x, y)
            #puts "#{e}"
            space[x][y] << "i#{e}"
          end
        end
      else
        hit_stop = false
        col_comp = ent_mng.get_component(e, Collides)
        @shape = col_comp.shape
        render_comp = ent_mng.get_component(e, Renderable)
        loc_comp = ent_mng.get_component(e, Location)
        #add current points
        @shape.each do |point|
          x = point[0] - (col_comp.max_side/2) + loc_comp.x
          y = point[1] - (col_comp.max_side/2) + loc_comp.y
          if inWindow(x, y)
            space[x][y] << e
          end
        end
        # puts "@shape: #{@shape}"
        @shape.each do |point|
          x = point[0] - 25 + loc_comp.x
          y = point[1] - 50 + loc_comp.y
          if inWindow(x, y) && space[x][y].length > 1 # if youre' in the window and the point you're on has hit something
            o_id = 0
            space[x][y].each do |id| # go through the ids at that location
              if id != e && !hit_stop # if the id you're on is not your own and you haven't hit something before
                o_id = id # save the id of the other shape
                if o_id.to_s[0..0] == "i" # if the id has an "i" as the first letter
                  space_id = o_id[1..o_id.length].to_i # find the actual id (sans "i")
                  space_res = ent_mng.get_component(space_id, Resistance)
                  space_grav = ent_mng.get_component(space_id, GravDir)
                  col_comp.hit_list << [x, y]
                  x_vel = space_grav.x_vel
                  y_vel = space_grav.y_vel
                  res = space_res.res
                  loc_comp.dx *= res
                  loc_comp.dy *= res
                  loc_comp.dx += x_vel
                  loc_comp.dy += y_vel
                else
                  if ent_mng.has_component_of_type(o_id, Stationary)
                    loc_comp.dx *= -1.0
                    loc_comp.dy *= -1.0
                  end
                  if ent_mng.has_component_of_type(e, Stationary)
                    o_id_loc = ent_mng.get_component(o_id, Location) # get the other shape's Loc
                    o_id_loc.dx *= -1.0
                    o_id_loc.dy *= -1.0
                  else
                    o_id_loc = ent_mng.get_component(o_id, Location) # get the other shape's Loc
                    this_change_x = loc_comp.dx/2.0
                    this_change_y = loc_comp.dy/2.0
                    other_change_x = o_id_loc.dx/2.0
                    other_change_y = o_id_loc.dy/2.0

                    o_id_old_dx = o_id_loc.dx # this is just to get an output that's accurate
                    o_id_loc.dx -= other_change_x
                    o_id_loc.dy -= other_change_y
                    loc_comp.dx -= this_change_x
                    loc_comp.dy -= this_change_y

                    o_id_loc.dx += this_change_x
                    o_id_loc.dy += this_change_y
                    loc_comp.dx += other_change_x
                    loc_comp.dy += other_change_y
                  end
                end
              else
                hit_stop = true
                # puts "NO HIT! -------------------------------"
              end
            end
          end
        end
      end
    end
    return space
  end

end

#=================================================

class Move < System

  def process_tick(ent_mng) # this isn't working yet...
    components = [Player, Location]
    ent_mng.entities_with_components(components).each do |e|
      player_comp = ent_mng.get_component(e, Player)
      loc_comp = ent_mng.get_component(e, Location)
      puts "player comp up: #{player_comp.up}"
      if button_down?(player_comp.up)
        loc_comp.dy -= 2
      end
      if button_down?(player_comp.left)
        loc_comp.dx -= 2
      end
      if button_down?(player_comp.down)
        loc_comp.dy += 2
      end
      if button_down?(player_comp.right)
        loc_comp.dx += 2
      end
    end
  end

end
