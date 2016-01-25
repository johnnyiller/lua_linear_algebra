require('matrix')
require('benchmark')
n = 10000

Benchmark.bm do |x|
  x.report {
    A = Matrix.build(10,10) do 
          rand
        end
    n.times do 
      result = A * A
    end
  }
end
