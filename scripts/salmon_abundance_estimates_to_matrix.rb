require 'yaml'

conffile = ARGV[0]
conf = YAML.load(File.open(conffile).read)

STDERR.puts conf.inspect


COLUMN_NAMES = %w{
Name
Length
EffectiveLength
TPM
NumReads
}

names = conf['names']
outdir_prefix = conf['outdir_prefix']

data = {}

source_files = []
names.each do |name|
  data[name] = {}
  source_file = "#{outdir_prefix}#{name}/quant.sf"
  source_files << source_file
  File.open(source_file).each_with_index do |l, i|
    next if i == 0
    a = l.chomp.split(/\t/, -1)
    id = a[0]
    val = a[4]
    data[name][id] = val
  end
end

ids = data[names[0]].keys.sort

## Read sample_info_file

if conf['sample_info_file']
  sample_info = {}
  File.open(conf['sample_info_file']).each do |l|
    next if /^\#/.match(l)
    a = l.chomp.split(/\t/)
    sample_info[a[0]] = a
  end
end


puts "#=== Transcript Abundance Matrix ==="
puts "#"
puts "# method: salmon"
puts "# source:"
source_files.each do |sf|
  puts "#   #{sf}"
end
puts "#"
if conf['sample_info_file']
  puts "# sample information"
  names.each do |n|
    puts "#  #{sample_info[n].join("\t")}"
  end
end

puts "# script: #{__FILE__}"
puts "# date:   #{Time.now}"
puts "#"
puts "# id\t" + names.join("\t")
if conf['sample_info_file']
  puts "# id\t" + names.map{|n| sample_info[n][1]}.join("\t")
end

ids.each do |id|
  values = names.map{|n| data[n][id]}
  puts [id, values].flatten.join("\t")
end
