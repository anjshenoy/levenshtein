require "./lib/population.rb"
require "benchmark"

Benchmark.bm do |x|
  x.report {
    puts "Loading population ..........."
    p = Population.new
    puts "Building connections ............"
    p.build_connections
    puts "Counting nodes for causes ........"
    puts p.walk_and_count("causes")
    puts "DONE!"
  }
end
