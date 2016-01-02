require 'busted.runner'()

describe("Matrix", function()
  randomize()
  describe("getters and setters", function()
    it("sets and gets withing the bound of the matrix", function()
      local Matrix = require("lib.matrix")
      local mtrx = Matrix.new(3,3) 
      local mtrxtwo = Matrix.new(3,3) 
      mtrx.set(1,1,78)
      mtrx.set(1,3,88)
      mtrxtwo.set(1,1,42)
      assert.same(78, mtrx.get(1,1))
      assert.same(88, mtrx.get(1,3))
      assert.same(42, mtrxtwo.get(1,1))
      mtrx.set(2,5,100)
      assert.same(0,mtrx.get(2,5))
    end)
  end)

  describe("utility functions", function()
    it("should dump the matrix to a list of lists", function()
      local Matrix = require("lib.matrix")
      local matrix = Matrix.new(3,4)
      matrix.set(1,1,12)
      matrix.set(2,2,9)
      matrix.set(3,4,6)
      local d = matrix.dump()
      assert.same(12, d[1][1])
      assert.same(9, d[2][2])
    end)
    it("should load a matrix from a list of lists", function()
      local Matrix = require("lib.matrix")
      local matrix = Matrix.new(2,3)
      matrix.load({
	{1,2,3},
	{7,8,9}
      })
      assert.same(8, matrix.get(2,2)) 
    end)
  end)

  describe("form operations", function()
    it("should test for row echelon form", function()
      local Matrix = require("lib.matrix")
      local matrix = Matrix.new(3,4)
      matrix.set(1,1,12)
      matrix.set(2,2,9)
      matrix.set(3,4,6)
      assert.truthy(matrix.is_row_echelon_form())
      assert.truthy(matrix.is_ref())
      matrix.set(3,1,56)
      assert.falsy(matrix.is_row_echelon_form())
    end) 

    it("should test for reduced row echelon form", function()
      local Matrix = require("lib.matrix")
      local matrix = Matrix.new(5,10)

      local matrix_rows = {
	{0,6,1,1,1,1,1,-1,1,1},
	{0,0,0,2,1,-1,1,1,1,1},
	{0,0,0,0,3,-1,1,1,1,1},
	{0,0,0,0,0,2,-1,1,1,1},
	{0,0,0,0,0,0,0,0,-9,1}
      }
      matrix.load(matrix_rows)
      assert.falsy(matrix.is_reduced_row_echelon_form())
      
      matrix_rows = {
	{0,1,1,1,1,1,1,-1,1,1},
	{0,0,0,1,1,-1,1,1,1,1},
	{0,0,0,0,1,-1,1,1,1,1},
	{0,0,0,0,0,1,-1,1,1,1},
	{0,0,0,0,0,0,0,0,1,1}
      }
      matrix.load(matrix_rows)
      assert.falsy(matrix.is_reduced_row_echelon_form())
      
      matrix_rows = {
	{0,1,6,0,0,0,3,3,0,7},
	{0,0,0,1,0,0,3,3,0,5},
	{0,0,0,0,1,0,3,3,0,4},
	{0,0,0,0,0,1,1,1,0,3},
	{0,0,0,0,0,0,0,0,1,1}
      }
      matrix.load(matrix_rows)
      assert.truthy(matrix.is_reduced_row_echelon_form())

      local matrix = Matrix.new(4,4)
      matrix_rows = {
	{1,0,3,6},
	{0,1,3,1},
	{0,0,0,0},
	{0,0,0,0}
      }
      matrix.load(matrix_rows)
      assert.truthy(matrix.is_reduced_row_echelon_form())

    end)
  end)

end)
