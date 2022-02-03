local Class = require('./utils/class')


local Block = Class{}

  function Block:init(type, match_key)
    self.type = type
    self.match_key = match_key
  end

  function Block:check_match(match_key)
    return match_key == self.match_key
  end


return {
  Block = Block,
  types = {
    {'A', 'A'},
    {'B', 'B'},
    {'C', 'C'},
    {'D', 'D'},
    {'E', 'E'},
    {'F', 'F'},
  }
}
