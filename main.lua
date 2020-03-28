math.randomseed(os.time())
g = love.graphics

function love.load()
  width = g.getWidth()
  height = g.getHeight()

  people = {}

end

function love.update(dt)

end

function love.draw()
  g.setBackgroundColor(1, 1, 1)

end

function distance(a, b)
  return math.sqrt(((a.y-b.y)^2)+((a.x-b.x)^2))
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit(0)
  end
end
