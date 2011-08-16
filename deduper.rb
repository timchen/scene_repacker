require "rubygems"
require "mp3info"
require 'find'
require 'fileutils'
RSS_DIR = '/Volumes/Data/Music/#RSS'
MOM_DIR = '/Volumes/Data/Music/MOM_SORTED'

NON_MUSIC_DIR = '/Volumes/Data/Music/NON_MUSIC'
REALMOM_NFO_MISSING_DIR = '/Volumes/Data/Music/NFO_MISSING'

SORTED_DIR = "/Volumes/Data/Music/MOM_SORTED"


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



