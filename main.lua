math.randomseed(os.time())
g = love.graphics

function love.load()
  width = g.getWidth()
  height = g.getHeight()

  people = {}
  cities = {}

  numCitiesH = 3
  numCitiesW = 3
  numPeople = 100

  cityBorder = 25
  cityWidth = (width/numCitiesW) - cityBorder - cityBorder/(numCitiesW)
  cityHeight = (height/numCitiesH) - cityBorder - cityBorder/(numCitiesH)

  colors = {}
  colors.s = {0.12,0.56,1.00}
  colors.i = {0.65,0.16,0.16}
  colors.r = {0.46,0.53,0.60}

  for j = 1, numCitiesH do    -- make cities
    for i = 1, numCitiesW do
      local city = {}
      city.x = i*cityBorder + (i-1)*cityWidth
      city.y = j*cityBorder + (j-1)*cityHeight
      city.w = cityWidth
      city.h = cityHeight
      city.cx = average({city.x, city.x+city.w})
      city.cy = average({city.y, city.y+city.h})
      table.insert(cities, city)
    end
  end

end

function love.update(dt)

end

function love.draw()
  g.setBackgroundColor(1, 1, 1)

  for i = 1, #cities do
    local city = cities[i]
    g.setColor(0, 0, 0)
    g.rectangle("line", city.x, city.y, city.w, city.h)
  end
end

function distance(a, b)
  return math.sqrt(((a.y-b.y)^2)+((a.x-b.x)^2))
end

function average(a)
  sum = 0
  for i = 1, #a do
    sum = sum + a[i]
  end
  return sum / #a
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit(0)
  end
end
