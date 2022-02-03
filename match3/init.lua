local interface = require('./utils/interface')
local color = require('./utils/color')
local sleep = require('./utils/sleep')
local ripairs = require('./utils/lume').ripairs
local map = require('./utils/lume').map
local Board = require('./board')



local log = {}
local clear_screen = true
local use_colors = true
local colors = {
  [' '] = 'white',
  A = 'white',
  B = 'red',
  C = 'yellow',
  D = 'green',
  E = 'blue',
  F = 'purple'
}
local function draw_screen(board_dump)
  -- clear screen
  if clear_screen then
    io.write('\027[H\027[2J')
  end

  -- draw board
  print('\n ', table.concat({0,1,2,3,4,5,6,7,8,9}, ' '), '\n')
  for i, row in ripairs(board_dump) do
      if i ~= 11 then
      row = map(row, function(tile)
        local block = tile:get_block()
        block = not block and ' ' or block.type
        if use_colors then
          block = color(block, colors[block])
        end
        return block
      end)
      print((i-1), table.concat(row, ' '), (i-1))
    end
  end
  print('\n ', table.concat({0,1,2,3,4,5,6,7,8,9}, ' '), '\n')

  -- draw log
  for _, entry in ipairs(log) do
    print(entry)
  end
  log = {}

  print('\n')
end


local is_running = true
local board = Board()

interface.add_command('q', function() is_running = false end)
interface.add_command('color', function() use_colors = not use_colors end)
interface.add_command('clear', function() clear_screen = not clear_screen end)
interface.add_command('m (%d) (%d) (%l)', function(pos_x, pos_y, dir)
  -- correct cords
  pos_x = pos_x + 1
  pos_y = pos_y + 1

  local dir_x, dir_y = 0, 0
  if dir == 'l' then
    dir_x = -1
  elseif dir == 'r' then
    dir_x = 1
  elseif dir == 'u' then
    dir_y = 1
  elseif dir == 'd' then
    dir_y = -1
  else
    table.insert(log, 'Invalid move direction!\nUse l, r, u, d')
    return
  end
  local success, err = board:move(pos_x, pos_y, dir_x, dir_y)
  if not success then
    table.insert(log, err)
  end
end)


while is_running do
  draw_screen(board:dump())
  while board:tick() do
    sleep(0.5)
    draw_screen(board:dump())
  end
  interface.check_command()
end
