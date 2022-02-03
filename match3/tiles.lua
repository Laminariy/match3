local Class = require('./utils/class')
local blocks = require('./blocks')
local randomchoice = require('./utils/lume').randomchoice


local Empty = Class{}
  Empty.type = 'Empty'

  function Empty:init(board, x, y)
    self.board = board
    self.x = x
    self.y = y
  end

  function Empty:get_block()
    return nil
  end

  function Empty:tick()
    return false
  end

  function Empty:check_fall()
    return false
  end


local Slot = Class{__includes = Empty}
  Slot.type = 'Slot'

  function Slot:attach_block(block)
    self.block = block
  end

  function Slot:get_block()
    return self.block
  end

  function Slot:detach_block()
    local block = self.block
    self.block = nil
    return block
  end

  function Slot:on_match(v_match, h_match)
    if v_match then
      for _, tile in ipairs(v_match) do
        tile:detach_block()
      end
    end
    if h_match then
      for _, tile in ipairs(h_match) do
        tile:detach_block()
      end
    end
  end

  function Slot:tick()
    if self.block then
      local d_tile = self.board:get_tile(self.x, self.y-1)
      if d_tile and d_tile:check_fall() then
        local block = self:detach_block()
        d_tile:attach_block(block)
        return true
      end
    end
    return false
  end

  function Slot:check_fall()
    return not self.block
  end


local Spawner = Class{__includes = Empty}
  Spawner.type = 'Spawner'

  function Spawner:tick()
    local d_tile = self.board:get_tile(self.x, self.y-1)
    if d_tile and d_tile:check_fall() then
      local block = blocks.Block(unpack(randomchoice(blocks.types)))
      d_tile:attach_block(block)
      return true
    end
    return false
  end


return {
  Empty = Empty,
  Slot = Slot,
  Spawner = Spawner
}
