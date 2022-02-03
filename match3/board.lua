local Class = require('./utils/class')
local randomchoice = require('./utils/lume').randomchoice
local weightedchoice = require('./utils/lume').weightedchoice
local unique = require('./utils/lume').unique
local concat = require('./utils/lume').concat
local map = require('./utils/lume').map

local tiles = require('./tiles')
local blocks = require('./blocks')


local Board = Class{}

  function Board:init()
    self.map = {}

    -- simple map generation
    -- here can be level loading or something
    for x = 1, 10 do
      self.map[x] = {}
      self.map[x][11] = tiles.Spawner(self, x, 11)
      for y = 1, 10 do
        self.map[x][y] = tiles.Slot(self, x, y)
      end
    end

    -- map filling
    local block
    for tile in self:iterate() do
      if tile.type == 'Slot' then
        block = blocks.Block(unpack(randomchoice(blocks.types)))
        tile:attach_block(block)
      end
    end

    -- shuffle board before playing
    self:mix()
  end

  function Board:get_tile(x, y)
    return self.map[x] and self.map[x][y] or nil
  end

  function Board:iterate(pos_x, pos_y, dir_x, dir_y)
    if pos_x and pos_y and dir_x and dir_y then
      local res
      return function()
        res = self:get_tile(pos_x, pos_y)
        pos_x = pos_x + dir_x
        pos_y = pos_y + dir_y
        return res
      end
    else
      local res
      pos_x, pos_y = 0, 1
      return function()
        pos_x = pos_x + 1
        res = self:get_tile(pos_x, pos_y)
        if not res then
          pos_y = pos_y + 1
          pos_x = 1
          res = self:get_tile(pos_x, pos_y)
        end
        return res
      end
    end
  end

  function Board:tick()
    local repeat_tick = false
    for tile in self:iterate() do
      if tile:tick() then
        repeat_tick = true
      end
    end
    if not repeat_tick then
      repeat_tick = self:clear_all_matches()
    end
    if not repeat_tick then
      if not self:check_potential_matches() then
        self:mix()
      end
    end
    return repeat_tick
  end

  function Board:clear_all_matches()
    local success = false
    local match
    for tile in self:iterate() do
      match = self:get_tile_match(tile.x, tile.y)
      if next(match) then
        tile:on_match(match.v_match, match.h_match)
        success = true
      end
    end
    return success
  end

  function Board:check_potential_matches()
    local line, block_1, block_2
    for tile in self:iterate() do
      -- left
      --       #
      -- # [#] X #
      --       #
      line = self:get_line_match(tile.x, tile.y, -1, 0)
      if #line == 2 then
        block_1 = tile:get_block()
        block_2 = self:get_tile(tile.x+2, tile.y) and self:get_tile(tile.x+2, tile.y):get_block() or nil
        if block_2 and block_1.type == block_2.type then
          return true
        end
        block_2 = self:get_tile(tile.x+1, tile.y+1) and self:get_tile(tile.x+1, tile.y+1):get_block() or nil
        if block_2 and block_1.type == block_2.type then
          return true
        end
        block_2 = self:get_tile(tile.x+1, tile.y-1) and self:get_tile(tile.x+1, tile.y-1):get_block() or nil
        if block_2 and block_1.type == block_2.type then
          return true
        end
      end

      -- down
      --    #
      --  # X #
      --   [#]
      --    #
      line = self:get_line_match(tile.x, tile.y, 0, -1)
      if #line == 2 then
        block_1 = tile:get_block()
        block_2 = self:get_tile(tile.x, tile.y+2) and self:get_tile(tile.x, tile.y+2):get_block() or nil
        if block_2 and block_1.type == block_2.type then
          return true
        end
        block_2 = self:get_tile(tile.x+1, tile.y+1) and self:get_tile(tile.x+1, tile.y+1):get_block() or nil
        if block_2 and block_1.type == block_2.type then
          return true
        end
        block_2 = self:get_tile(tile.x-1, tile.y+1) and self:get_tile(tile.x-1, tile.y+1):get_block() or nil
        if block_2 and block_1.type == block_2.type then
          return true
        end
      end
    end
    return false
  end

  function Board:get_line_match(pos_x, pos_y, dir_x, dir_y)
    if not (self:get_tile(pos_x, pos_y) and self:get_tile(pos_x, pos_y):get_block()) then
      return {}
    end

    local match_key = self:get_tile(pos_x, pos_y):get_block().match_key
    local match = {self:get_tile(pos_x, pos_y)}
    local block

    for tile in self:iterate(pos_x+dir_x, pos_y+dir_y, dir_x, dir_y) do
      block = tile:get_block()
      if block and block:check_match(match_key) then
        table.insert(match, tile)
      else
        break
      end
    end
    return match
  end

  function Board:get_tile_match(pos_x, pos_y)
    -- vertical
    local v_match = self:get_line_match(pos_x, pos_y, 0, 1)
    v_match = concat(v_match, self:get_line_match(pos_x, pos_y, 0, -1))
    v_match = unique(v_match)
    -- horizontal
    local h_match = self:get_line_match(pos_x, pos_y, 1, 0)
    h_match = concat(h_match, self:get_line_match(pos_x, pos_y, -1, 0))
    h_match = unique(h_match)

    return {
      v_match = #v_match>=3 and v_match or nil,
      h_match = #h_match>=3 and h_match or nil
    }
  end

  function Board:move(pos_x, pos_y, dir_x, dir_y)
    -- tile checking
    local f_tile = self:get_tile(pos_x, pos_y)
    local s_tile = self:get_tile(pos_x+dir_x, pos_y+dir_y)
    if not (f_tile and s_tile) then
      return false, 'Invalid move!'
    end
    local f_block, s_block = f_tile:get_block(), s_tile:get_block()
    if not (f_block and s_block) then
      return false, 'Invalid move!'
    end

    -- change blocks
    f_tile:detach_block()
    s_tile:detach_block()
    f_tile:attach_block(s_block)
    s_tile:attach_block(f_block)

    -- match checking
    local f_res = self:get_tile_match(pos_x+dir_x, pos_y+dir_y)
    local s_res = self:get_tile_match(pos_x, pos_y)

    if not (next(f_res) or next(s_res)) then
      -- return blocks
      f_tile:detach_block()
      s_tile:detach_block()
      f_tile:attach_block(f_block)
      s_tile:attach_block(s_block)
      return false, 'No match move!'
    end

    -- tile event
    if next(f_res) then
      f_tile:on_match(f_res.v_match, f_res.h_match)
    end
    if next(s_res) then
      s_tile:on_match(s_res.v_match, s_res.h_match)
    end
    return true
  end

  function Board:mix()
    -- shuffle func
    local weights = {}
    local board_blocks = {}
    local left, down, success, res, block
    local function shuffle()
      -- detaching all blocks
      for tile in self:iterate() do
        block = tile:get_block()
        if block then
          if not board_blocks[block.type] then
            board_blocks[block.type] = {}
          end
          table.insert(board_blocks[block.type], tile:detach_block())
        end
      end

      -- try shuffle
      for tile in self:iterate() do
        if tile.type == 'Slot' then
          for k, v in pairs(board_blocks) do
            weights[k] = #v
          end

          -- check left tiles
          left = self:get_line_match(tile.x-1, tile.y, -1, 0)
          left = map(left, function(tile) return tile:get_block() end)
          if #left >= 2 then
            weights[left[1].type] = 0
          elseif #left > 0 then
            if weights[left[1].type] ~= 0 then
              weights[left[1].type] = weights[left[1].type] + 10
            end
            left = self:get_tile(tile.x-2, tile.y)
            left = left and left:get_block() or nil
            if left and weights[left.type] ~= 0 then
              weights[left.type] = weights[left.type] + 10
            end
          end

          -- check down tiles
          down = self:get_line_match(tile.x, tile.y-1, 0, -1)
          down = map(down, function(tile) return tile:get_block() end)
          if #down >= 2 then
            weights[down[1].type] = 0
          elseif #down > 0 then
            if weights[down[1].type] ~= 0 then
              weights[down[1].type] = weights[down[1].type] + 10
            end
            down = self:get_tile(tile.x, tile.y-2)
            down = down and down:get_block() or nil
            if down and weights[down.type] ~= 0 then
              weights[down.type] = weights[down.type] + 10
            end
          end

          -- try choose from weights
          success, res = pcall(weightedchoice, weights)
          if not success then
            return false
          end
          block = board_blocks[res][#board_blocks[res]]
          table.remove(board_blocks[res])
          tile:attach_block(block)
        end
      end
      return true
    end

    -- shuffling
    while not shuffle() do end
  end

  function Board:dump()
    local rows = {}
    for tile in self:iterate() do
      if not rows[tile.y] then
        rows[tile.y] = {}
      end
      rows[tile.y][tile.x] = tile
    end
    return rows
  end

return Board
