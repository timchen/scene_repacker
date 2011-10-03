require "rubygems"
require "mp3info"
require 'find'
require 'fileutils'
WORKING_DIR = '/Volumes/Media/RSS_WIP/mukki'
NON_MUSIC_DIR = '/Volumes/Media/RSS_WIP/non_music'
REALMOM_NFO_MISSING_DIR = '/Volumes/Media/RSS_WIP/nfo_missing'

SORTED_DIR = "/Volumes/Media/Music/RSS"
DUPES_DIR= "/Volumes/Media/RSS_WIP/dupes"


#files_sorted_by_time = Dir['*'].sort_by{ |f| File.ctime(f) }

Dir["#{WORKING_DIR}/*/"].each do |dir|
  puts File.basename(dir)

  mp3s = Dir.glob("#{dir}/*.mp3")

  if mp3s.count == 0
    puts "....NO MP3S"
    FileUtils.mv(dir, File.join(NON_MUSIC_DIR, File.basename(dir)))
    next 
  end

  realmom_nfos = Dir.glob("#{dir}/*__www.realmom.info__.nfo")

  if realmom_nfos.count == 0
    puts "....NO INFO"
    FileUtils.mv(dir, File.join(REALMOM_NFO_MISSING_DIR, File.basename(dir)))
    next 
  end
 
  Dir["#{dir}*__www.realmom.info__.nfo"].each do |realmom_nfo|
    #puts "   #{File.basename(release_dir)}

    nfo = File.basename(realmom_nfo).sub('__www.realmom.info__.nfo', '')

    begin
      if File.directory?(File.join(SORTED_DIR, nfo))
        puts "....DUPE"
        FileUtils.mv(Dir.glob("#{dir}/*"), File.join(SORTED_DIR, nfo, "/"))
        File.delete(File.join(SORTED_DIR, nfo, File.basename(realmom_nfo)))
        FileUtils.mv(dir, File.join(DUPES_DIR, nfo))
      else
        FileUtils.mv(dir, File.join(SORTED_DIR, nfo))
        File.delete(File.join(SORTED_DIR, nfo, File.basename(realmom_nfo)))
      end
    rescue SystemCallError => e
      puts "....FAILED TO MOVE"
    end

  end
end


