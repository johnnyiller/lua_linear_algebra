local x = os.clock()
require 'torch'
A = torch.rand(10,10)

for i=1, 100000 do
 local B = A * A
end

print(string.format("elapsed time: %.2f\n", os.clock() - x))

