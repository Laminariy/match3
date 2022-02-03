local Interface = {}

  local commands = {}

  function Interface.add_command(pattern, fn)
    assert(type(pattern) == 'string', 'Pattern must be string!')
    assert(type(fn) == 'function', 'You must provide function!')
    commands[pattern] = fn
  end

  function Interface.check_command()
    local input = io.read()
    local match
    for pattern, fn in pairs(commands) do
      match = {string.match(input, pattern)}
      if next(match) then
        fn(unpack(match))
        break
      end
    end
  end

return Interface
