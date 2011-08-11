require "rubygems"
require "mp3info"
require 'find'
require 'fileutils'
WORKING_DIR = '.'


SORTED_DIR = "sorted"


files_sorted_by_time = Dir['*'].sort_by{ |f| File.ctime(f) }
    # release_artist = #Afrojack_Feat_Eva_Simons
    # release_album = #Take_Over_Control__Incl_Ian_Carey_Remix
#
###### PAR2 STRATEGY #####
#files_sorted_by_time.each do |file|
Dir['*/'].each do |dir| # par found, best case
  puts dir
  #puts "par2 found: #{file}"

#  FileUtils.mv(Dir.glob("*#{release_name}*"), File.join(SORTED_DIR, "#{release_name}/"))
 # FileUtils.mv(Dir.glob("*#{strip_to_basics(release_name).downcase}*"), File.join(SORTED_DIR, "#{release_name}/"))
end


