local x = os.clock()
require 'torch'
A = torch.rand(10,10)
print(A)

for i=1, 100 do
 local B = A * A
end

print(string.format("elapsed time: %.2f\n", os.clock() - x))

