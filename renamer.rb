require "rubygems"
require "mp3info"
require 'find'
require 'fileutils'
WORKING_DIR = '/Volumes/Data/Music/#RSS_MOM'
NON_MUSIC_DIR = '/Volumes/Data/Music/NON_MUSIC'
REALMOM_NFO_MISSING_DIR = '/Volumes/Data/Music/NFO_MISSING'

SORTED_DIR = "/Volumes/Data/Music/MOM_SORTED"


files_sorted_by_time = Dir['*'].sort_by{ |f| File.ctime(f) }
    # release_artist = #Afrojack_Feat_Eva_Simons
    # release_album = #Take_Over_Control__Incl_Ian_Carey_Remix
#
###### PAR2 STRATEGY #####
#files_sorted_by_time.each do |file|

Dir["#{WORKING_DIR}/*/"].each do |dir| # par found, best case
  puts dir

  mp3s = Dir.glob("#{dir}/*.mp3")

  if mp3s.count == 0
    puts "    NO MP3S"
    FileUtils.mv(dir, File.join(NON_MUSIC_DIR, File.basename(dir)))
    next 
  end

  realmom_nfos = Dir.glob("#{dir}/*__www.realmom.info__.nfo")

  if realmom_nfos.count == 0
    puts "    NO INFO"
    FileUtils.mv(dir, File.join(REALMOM_NFO_MISSING_DIR, File.basename(dir)))
    next 
  end
 
  Dir["#{dir}*__www.realmom.info__.nfo"].each do |realmom_nfo|
    #puts "   #{File.basename(release_dir)}

    nfo = File.basename(realmom_nfo).sub('__www.realmom.info__.nfo', '')
    #break if nfo.nil?
    #puts "   #{nfo}"
    File.delete(realmom_nfo)
    FileUtils.mv(dir, File.join(SORTED_DIR, nfo))
  end

  #puts "par2 found: #{file}"

#  FileUtils.mv(Dir.glob("*#{release_name}*"), File.join(SORTED_DIR, "#{release_name}/"))
 # FileUtils.mv(Dir.glob("*#{strip_to_basics(release_name).downcase}*"), File.join(SORTED_DIR, "#{release_name}/"))
end


