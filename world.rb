require "./lib/population.rb"

start_time = Time.now
puts "Loading population ..........."
p = Population.new
puts "Building connections ............"
p.build_connections
puts "Counting nodes for causes ..........  #{p.walk_and_count("causes")}"
puts "DONE!"
puts "Total time = #{Time.now - start_time} seconds"
