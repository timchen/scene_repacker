require "rubygems"
require "mp3info"
require 'find'
require 'fileutils'
WORKING_DIR = '.'


SORTED_DIR = "sorted"
=begin
pass 1, find all pars
if no m3u's found, use alt. strategy
if VA- don't do anything (yet)
if has spaces, don't do anything
if no playlist found, don't do anything

pass 2, find all the orphan m3us and use those
=end

def strip_release_group(release_name)
  if !release_name.rindex("-").nil?
    if !release_name[release_name.rindex("-")+1..-1].match(/\D{3}+/).nil?
      return release_name[0..release_name.rindex("-")-1]
    end
  elsif !release_name.rindex("_").nil?
    if !release_name[release_name.rindex("_")+1..-1].match(/\D{3}+/).nil?
      return release_name[0..release_name.rindex("_")-1]
    end
  end
  return release_name
end

def strip_va(release_name)
  return release_name[3..-1]
end

def strip_to_basics(release_name)
  return strip_release_group(strip_va(release_name))
end

def find_playlist(release_name)
  #puts "Searching for files matching #{release_name}"
  playlists = Dir.glob("#{WORKING_DIR}/*#{strip_to_basics(release_name).downcase}*.m3u")
  if playlists.count == 0
    puts "** no playlist matching #{strip_to_basics(release_name).downcase} found **"
    return nil
  end
  FileUtils.mkdir(File.join(SORTED_DIR, release_name)) if ! File.exists?(File.join(SORTED_DIR, release_name))

  playlists.each do |playlist|
    #puts playlist
    IO.readlines(playlist).each do |playlist_line|
      unless playlist_line.strip!['#']
        if File.exists?(File.join(WORKING_DIR, playlist_line))# and !File.exist?(File.join(SORTED_DIR, release_name, playlist_line))
          puts "  moving #{playlist_line}"
          FileUtils.mv(File.join(WORKING_DIR, playlist_line), (File.join(SORTED_DIR, release_name, playlist_line)))
        end
      end
    end
  end
end

files_sorted_by_time = Dir['*'].sort_by{ |f| File.ctime(f) }
    # release_artist = #Afrojack_Feat_Eva_Simons
    # release_album = #Take_Over_Control__Incl_Ian_Carey_Remix
#
###### PAR2 STRATEGY #####
#files_sorted_by_time.each do |file|
Dir['*.par2'].each do |file| # par found, best case
  next if File.fnmatch('* *', file) # skip files with spaces
  #puts "par2 found: #{file}"
  release_name = file.sub(/\.vol[0-9]{3}\+[0-9]{2}.*/, '')
  release_name = release_name.sub(/\.par2/, '')
  puts release_name
  next if find_playlist(release_name).nil? 

  FileUtils.mv(Dir.glob("*#{release_name}*"), File.join(SORTED_DIR, "#{release_name}/"))
  FileUtils.mv(Dir.glob("*#{strip_to_basics(release_name).downcase}*"), File.join(SORTED_DIR, "#{release_name}/"))
end

###### M3U STRATEGY #####
Dir['*.m3u'].each do |file|
  next if File.fnmatch('* *', file) # skip files with spaces 
  
end
=begin
if File.fnmatch('.mp3', file)
    Mp3Info.open(file) do |mp3|
      puts "#{file}"
      puts "    title #{mp3.tag.title}"
      puts "    artist #{mp3.tag.artist}"
      puts "    album #{mp3.tag.album}"
      puts "    tracknum #{mp3.tag.tracknum}"
    end
  end
=end
#Mp3Info.open("myfile.mp3") do |mp3|
  # you can access four letter v2 tags like this
#  puts mp3.tag2.TIT2
#  mp3.tag2.TIT2 = "new TIT2"
  # or like that
#  mp3.tag2["TIT2"]
  # at this time, only COMM tag is processed after reading and before writing
  # according to ID3v2#options hash
#  mp3.tag2.options[:lang] = "FRE"
#  mp3.tag2.COMM = "my comment in french, correctly handled when reading and writing"
#end

# tags v2 will be read and written according to the :encoding settings
#mp3 = Mp3Info.open("myfile.mp3", :encoding => 'utf-8')
