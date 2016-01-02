-- this script lets us deal with matrix operations in a sane way.. hopefully
local Matrix = {}
-- lua is kind of like javascript but better and faster
-- notice we are using a table to represent an array.  to 
-- be honest I like this a bit better than using an array.
function Matrix.new(rows,columns)
  local self = {}
  -- sparse data structure for a matrix, really like this implemenation
  function self.set(x,y,value)
    if x <= rows and y <= columns then
      if value == 0 then
	self[x*columns + y] = nil	 
      else
	self[x*columns + y] = value
      end
    end
  end
  function self.get(x,y)
    local val = self[x*columns + y] 
    if val == nil then
      return 0
    else
      return val
    end
  end

  -- tests if the matrix is in row echelon form
  -- example of a block quote.. 
  --[=====[
  --]=====]
  function self.is_row_echelon_form()
    -- start off the grid so that the first one is automatically valid
    local indexes = {}
    local left_index = 0
    for x=1, rows do
      for y=1, columns do 
	-- get the value from the sparse matrix
	local value = self.get(x,y)
	if value and value > 0 then
	  indexes[x] = y
	  if y <= left_index then
	    -- this is the primary condition for echelon form
	    return false, indexes
	  else
	    left_index = y
	    break
	  end
	end
      end
    end 
    return true, indexes
  end
  self.is_ref = self.is_row_echelon_form

  function self.is_reduced_row_echelon_form()
    local isref, indexes = self.is_ref() 
    if not isref then
      return false
    end
    for index, column_index in ipairs(indexes)  do
      local val = self.get(index,column_index)  
      if val == 1 then
	local previous_row = index - 1
	if previous_row >= 1 then 
	  for x=previous_row,1 do
	    if self.get(x, column_index) > 0 then
	      return false, indexes
	    end
	  end
	end
      else
	return false, indexes
      end
    end
    return true, indexes
  end
  self.is_rref = self.is_reduced_row_echelon_form

  function self.load(matrix_rows)
    for i=1, rows do
      for j=1, columns do
	local val = matrix_rows[i][j]
	if val == 0 then
	  val = nil
	end
	self.set(i,j,val)
      end
    end
  end

  -- dump and load should make a copy of the matrix making
  -- we don't copy by default cause what if we have a giant
  -- matrix, instead we want to mutate the existing table most 
  -- of the time
  function self.dump(matrix_rows)
    local T = {}
    for x=1, rows do
      T[x] = {}
      for y=1, columns do
	T[x][y] = self.get(x,y)
      end
    end
    return T
  end

  -- print out a reasonably formatted matrix
  local tostring = function()
    local str = "\n"
    for x=1, rows do
      for y=1, columns do 
	local val = self.get(x,y)
	if val == nil then
	  val = 0
	end
	str = str .. val .. " "
      end
      str = str .. "\n"
    end
    return str
  end
  
  -- meta table is like built in methods for the
  -- object, they are used by other built ins from 
  -- what I can tell
  setmetatable(self, { __tostring = tostring })

  return self
end

return Matrix
