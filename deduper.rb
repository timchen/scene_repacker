require "rubygems"
require "mp3info"
require 'find'
require 'fileutils'
RSS_DIR = '/Volumes/Media/RSS_WIP/omgwtfnzbs'
MOM_DIR = '/Volumes/Media/Music/RSS'


Dir["#{RSS_DIR}/*/"].each do |dir| 
  puts File.basename(dir)
  if File.exist?(File.join(dir, "/inner-sanctum.txt"))
    #puts "inner-sanctum.txt found"
    File.delete(File.join(dir, "/inner-sanctum.txt"))
  end
  if File.directory?(File.join(MOM_DIR, File.basename(dir)))
    puts "...FOUND"
    mom_files = Dir.glob(File.join(MOM_DIR, File.basename(dir), "/*"))
    rss_files = Dir.glob(File.join(dir, "/*"))
    puts "...DIFFERS (#{rss_files.count} vs #{mom_files.count})" if rss_files.count != mom_files.count
    puts "...DELETING"
    FileUtils.rm_rf(File.join(dir))
    next
  end
  puts "...MOVING"
  FileUtils.mv(dir, File.join(MOM_DIR))
end



