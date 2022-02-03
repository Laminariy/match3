local colors = {
  white = '27;37',
  red = '27;31',
  yellow = '27;33',
  green = '27;32',
  blue = '27;36',
  purple = '27;35'
}

return function(s, color)
  return '\27[' .. colors[color or 'white'] .. 'm' .. s .. '\27[0m'
end
