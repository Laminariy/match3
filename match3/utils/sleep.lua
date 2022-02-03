-- very stupid sleep func
return function(sec)
  local t0 = os.clock()
  while os.clock() - t0 <= sec do end
end
