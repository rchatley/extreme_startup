task :cucumber do
  sh "cucumber -f progress"
end

task :rspec do
  sh "rspec spec"
end

task :default => [:rspec, :cucumber]
