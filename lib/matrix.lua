-- this script lets us deal with matrix operations in a sane way.. hopefully
local Matrix = {}
-- lua is kind of like javascript but better and faster
-- notice we are using a table to represent an array.  to 
-- be honest I like this a bit better than using an array.
-- we pass in references to zero and one so that we can use rational
-- numbers if we want for our matrix
function Matrix.new(rows,columns,zero,one)
  local zero = zero or 0
  local one = one or 1
  
  local self = {}

  self.columns = columns
  self.rows = rows
  -- call a function for each x y pair
  local function each(func)
    for x=1, rows do
      for y=1, columns do
        func(x,y)
      end
    end
  end

  -- sparse data structure for a matrix, really like this implemenation
  function self.set(x,y,value)
    if value == zero or x > rows or y > columns  then
      self[x*columns + y] = nil 
    else
      self[x*columns + y] = value
    end
  end

  function self.get(x,y)
    local val = self[x*columns + y] 
    if val == nil then
      return zero
    else
      return val
    end
  end

  local function lead_zeros_for_row(row_index)
    for column=1, columns do 
      local value = self.get(row_index, column)
      if value and value ~= zero then
        return column - 1
      end
    end
  end

  local function swap_row(row_one, row_two)
    -- double assignment allows quick swapping...
    for column=1, columns do 
      self[row_one*columns + column], self[row_two*columns + column] = self[row_two*columns + column], self[row_one*columns + column]
    end

  end

  function self.row_sort()
    local item_count = rows
    local has_changed
    repeat 
      has_changed = false
      item_count = item_count - 1
      for i = 1, item_count do 
        if lead_zeros_for_row(i) > lead_zeros_for_row(i+1) then
          swap_row(i, i+1) 
          has_changed = true
        end
      end
    until has_changed == false
  end

  local function substitute_row(start_row, sub_row, pivot_column)

    local pivot_value = self.get(start_row, pivot_column)
    local pivot_basis = self.get(sub_row, pivot_column)

    -- if we have actual numbers to operate on then we can do what
    -- we do with them.
    if pivot_value ~= zero and pivot_basis ~= zero then 

      local factor = pivot_basis / pivot_value
      local first_sub_value = factor * pivot_value

      if pivot_basis - first_sub_value == zero then
        for column=pivot_column, columns do 
          local sub_amount = factor * self.get(start_row, column)
          self.set(sub_row, column, self.get(sub_row, column) - sub_amount)
        end
      else
        for column=pivot_column, columns do 
          local sub_amount = factor * self.get(start_row, column)
          self.set(sub_row, column, self.get(sub_row, column) + sub_amount)
        end
      end

    end

  end

  function self.ref()
    -- we first sort the matrix because that gives us a nice known starting
    -- structure then we can take advantage of this structure to perform our
    -- operations...
    self.row_sort()
    for row = 1, rows do 
      local pivot_column = lead_zeros_for_row(row) + 1
      for next_row = row + 1, rows do  
        substitute_row(row, next_row, pivot_column)
      end
    end
  end

  function self.rref()
    self.ref()    
    for row=rows, 1, -1 do

      local pivot_column = lead_zeros_for_row(row) + 1
      local pivot_value = self.get(row, pivot_column)

      -- scale row so that the pivot is a 1
      for column=pivot_column, columns do
        self.set(row, column, self.get(row,column) / pivot_value)  
      end

      for prev_row = row - 1, 1, -1 do 
        substitute_row(row, prev_row, pivot_column)
      end

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
	  -- get the value from the sparse matrix
    for x=1, rows do
      for y=1, columns do
        local value = self.get(x,y)
        if value and value > zero then
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
      if val == one then
        local previous_row = index - 1
        if previous_row >= 1 then 
          for x=previous_row,1 do
            if self.get(x, column_index) > zero then
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
    each(function(x,y)
      local val = matrix_rows[x][y]
      if val == zero then
        val = nil
      end
      self.set(x,y,val)
    end)
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
  local _matrix_tostring = function()
    local str = "\n"
    each(function(x,y)
      local val = self.get(x,y)

      str = str .. tostring(val) .. " "
      if y == columns then
        str = str .. "\n"
      end
    end)
    return str
  end

  -- Do some matrix multiplication by hand to verify this logic.
  local function _multiply(A,B)
    if A.columns ~= B.rows then
      error("sorry columns and rows must match to multiply matrices")
    end
    _new_matrix = Matrix.new(A.rows, B.columns, zero, one )
    for i=1, A.rows do
      for j=1, B.columns do 
        local row_add = zero
        for k=1, A.columns do 
          row_add = row_add + A.get(i,k) * B.get(k,j) 
        end
        _new_matrix.set(i,j,row_add)
      end
    end
    return _new_matrix

  end
   
  -- meta table is like built in methods for the
  -- object, they are used by other built ins from
  -- allows you to use operators with your tables
  setmetatable(self, { 
    __tostring = _matrix_tostring,
    __mul = _multiply
  })

  return self
end

return Matrix
