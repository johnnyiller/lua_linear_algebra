require 'busted.runner'()
local Matrix = require("lib.matrix")

describe("Matrix", function()
  randomize()
  describe("getters and setters", function()
    it("sets and gets withing the bound of the matrix", function()
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
      local matrix = Matrix.new(3,4)
      matrix.set(1,1,12)
      matrix.set(2,2,9)
      matrix.set(3,4,6)
      local d = matrix.dump()
      assert.same(12, d[1][1])
      assert.same(9, d[2][2])
    end)
    it("should load a matrix from a list of lists", function()
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

      local r = require('rational') 
      local matrix = Matrix.new(4,4, r(0/1), r(1/1))
      matrix_rows = {
        {r(1,1),r(0,1),r(3,4),r(6,4)},
        {r(0,1),r(1,1),r(3,1),r(1,1)},
        {r(0,1),r(0,1),r(0,1),r(0,1)},
        {r(0,1),r(0,1),r(0,1),r(0,1)}
      }
      matrix.load(matrix_rows)
      assert.truthy(matrix.is_row_echelon_form())
      assert.truthy(matrix.is_reduced_row_echelon_form())


    end)
  end)
  describe("sort rows", function()

    it("should be able to swap a row with another row mutating", function()
      local r = require('rational')
      local matrix = Matrix.new(4, 4, r(0,1), r(1,1))
      matrix_rows = {
        {r(0,1), r(3,2),r(2,1),r(2,5)},
        {r(3,5), r(3,2),r(2,1),r(2,5)},
        {r(0,1), r(0,1),r(2,1),r(2,5)},
        {r(2,9), r(3,2),r(2,1),r(2,5)}
      }
      matrix.load(matrix_rows)
      matrix.row_sort()
      assert.equal(r(3,5), matrix.get(1,1))
      assert.equal(r(3,2), matrix.get(3,2))
      assert.equal(r(2,1), matrix.get(4,3))
    end)
  end)
  
  describe("ref", function()
    it('should convert a matrix into reduced echelon form', function()
      local r = require('rational')
      local matrix = Matrix.new(3, 6, r(0,1), r(1,1))
      matrix_rows = {
        {r(0,1), r(3,1),r(-6,1),r(6,1),r(4,1),r(-5,1)},
        {r(3,1), r(-7,1),r(8,1),r(-5,1),r(8,1),r(9,1)},
        {r(3,1), r(-9,1),r(12,1),r(-9,1),r(6,1),r(15,1)}
      }
      matrix.load(matrix_rows)
      matrix.ref()
      assert.truthy(matrix.is_row_echelon_form())
      
    end)
    it('should produce a specific form or ref for a properly sorted matrix', function()
      local r = require('rational')
      local matrix = Matrix.new(3, 6, r(0,1), r(1,1))
      matrix_rows = {
        {r(3,1), r(-9,1),r(12,1),r(-9,1),r(6,1),r(15,1)},
        {r(3,1), r(-7,1),r(8,1),r(-5,1),r(8,1),r(9,1)},
        {r(0,1), r(3,1),r(-6,1),r(6,1),r(4,1),r(-5,1)}
      }
      matrix.load(matrix_rows)
      matrix.ref()
      assert.equal(r(3,1), matrix.get(1,1))
      assert.equal(r(2,1), matrix.get(2,2))
      assert.equal(r(1,1), matrix.get(3,5))
      assert.equal(r(0,1), matrix.get(3,1))
      assert.equal(r(0,1), matrix.get(3,2))
      assert.equal(r(0,1), matrix.get(3,3))

    end)
  end)

  describe("rref", function()

    it('should produce a specific form or ref for a properly sorted matrix', function()
      local r = require('rational')
      local matrix = Matrix.new(3, 6, r(0,1), r(1,1))
      matrix_rows = {
        {r(3,1), r(-9,1),r(12,1),r(-9,1),r(6,1),r(15,1)},
        {r(3,1), r(-7,1),r(8,1),r(-5,1),r(8,1),r(9,1)},
        {r(0,1), r(3,1),r(-6,1),r(6,1),r(4,1),r(-5,1)}
      }
      matrix.load(matrix_rows)
      matrix.rref()
      assert.truthy(matrix.is_reduced_row_echelon_form())
    end)

  end)

  describe("matrix multiplication", function()

    it("should work with multipliable matrices", function()
      local r = require('rational')
      local A = Matrix.new(2, 2, r(0,1), r(1,1))
      local B = Matrix.new(2, 3, r(0,1), r(1,1))
      matrix_rows = {
        {r(2,1), r(3,1)},
        {r(1,1), r(-5,1)}
      }
      A.load(matrix_rows)
      matrix_rows = {
        {r(4,1), r(3,1), r(6,1)},
        {r(1,1), r(-2,1), r(3,1)}
      }
      B.load(matrix_rows)
      C = A * B
      assert.equal(C.get(1,1),r(11,1))
      assert.equal(C.get(1,2),r(0,1))
      assert.equal(C.get(2,3),r(-9,1))

    end)

  end)


end)
