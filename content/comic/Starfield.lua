import 'util'
import 'comic'

local Starfield = class 'Starfield'

local function create_star()
  local star = {}
  local max_x, max_y = love.graphics.getDimensions ()
  local x = (math.random() * max_x - max_x*0.5) 
  local y = (math.random() * max_y - max_y*0.5) * 1.75

  star.brightness = math.random() 
  star.position = Vec2(0, 0)
  star.velocity = Vec2(x, y) --* star.brightness
  return star
end

function Starfield:init (parent_ctx)
  self.context = parent_ctx:new(self)
  self.star_index = 0
  self.stars = {}
  for i=1, 50 do
    local star = create_star()
    local index = (self.star_index + i) % 600
    self.stars[index] = star
  end
  self.star_index = self.star_index + 50
end


function Starfield:update(dt)
  for i=1, #self.stars do
    local star = self.stars[i]
    star.position:do_add_amount(star.velocity, dt*0.001)
    star.velocity:do_mul (math.pow (2, (dt*10)/2))
  end


  for i=1, 5 do
    local star = create_star()
    local index = (self.star_index + i) % 900
    self.stars[index] = star
  end
  self.star_index = self.star_index + 5


end

function Starfield:draw()
  local function portrait_stencil ()
    love.graphics.rectangle("fill", -0.5, -0.75, 1, 1.5)
  end

  love.graphics.stencil(portrait_stencil, "replace", 1)

  love.graphics.setStencilTest("greater", 0)
  love.graphics.setPointSize( 2 )
  local star_points = {}
  for i=1, #self.stars do
    local star = self.stars[i]
    table.insert(star_points, star.position.x)
    table.insert(star_points, star.position.y)
  end
  love.graphics.points(star_points)

  love.graphics.setStencilTest()

  -- draw blotter
  love.graphics.push()
  love.graphics.reset()

  local x, y = love.graphics.getDimensions ()
  local offset = Vec2(x*0.5-250, y*0.5-375)


  love.graphics.setColor (1, 1, 1, 0.97)
  local blotter = self.context.resources.images.blotter

  love.graphics.draw(blotter, offset.x, offset.y)
  -- love.graphics.rectangle("fill", offset.x, offset.y, 500, 750)
  love.graphics.setColor (1, 1, 1, 1)


  love.graphics.pop()

end

return Starfield
