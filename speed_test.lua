local x = os.clock()
Matrix = require("lib.matrix")

A = Matrix.new(10,10,0.0,1.0)
for i=1, 10 do 
  for j=1, 10 do 
    A.set(i,j,math.random())
  end
end

for i=1, 100000 do
  local result = A * A
end

print(string.format("elapsed time: %.2f\n", os.clock() - x))
