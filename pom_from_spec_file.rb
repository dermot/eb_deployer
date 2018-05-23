#!/usr/bin/env ruby
#I'm sure there's a better way to do this... 
require 'maven/tools/pom'
include Maven::Tools
spec_file = ARGV[0] 
pom = POM.new(spec_file)
model = POM.new(spec_file).to_model(spec_file)
pom_file_name  = model.artifact_id + '-' + model.version + '.pom'
f = File.open(pom_file_name,'w')
f.puts pom.to_s
f.close