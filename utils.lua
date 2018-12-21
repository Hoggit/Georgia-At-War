function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function randomFromList(list)
  local idx = math.random(1, #list)
  return list[idx]
end

function listContains(list, elem)
  for _, value in ipairs(list) do
    if value == elem then
        return true
    end
  end

  return false
end

tableIndex = function(tbl, val)
  for i,v in pairs(tbl) do
    if val == v then
      return i
    end
  end
end

array_size = function(o)
    local num = 0
    for i, j in pairs(o) do
        num = num + 1
    end
    return num
end

