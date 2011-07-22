require "rubygems"
require "mp3info"
require 'find'
require 'fileutils'
WORKING_DIR = '.'


SORTED_DIR = "sorted"

def find_playlist(release_name)
  playlists = Dir.glob("#{WORKING_DIR}/*.m3u")
  playlists.each do |playlist|
    puts playlist
    IO.readlines(playlist).each do |playlist_line|
      unless playlist_line.strip!['#']
        if File.exists?(File.join(WORKING_DIR, playlist_line))# and !File.exist?(File.join(SORTED_DIR, release_name, playlist_line))
          puts "moving.."
          #FileUtils.mv(File.join(WORKING_DIR, playlist_line), (File.join(SORTED_DIR, release_name, playlist_line)))
        end
      end
    end
  end
end

files_sorted_by_time = Dir['*'].sort_by{ |f| File.ctime(f) }

files_sorted_by_time.each do |file|
  if File.fnmatch('*.par2', file) # par found, best case
    release_name = file.sub(/\.vol[0-9]{3}\+[0-9]{2}.*/, '')
    release_name = release_name.sub(/\.par2/, '')
    puts release_name
    FileUtils.mkdir(File.join(SORTED_DIR, release_name)) if ! File.exists?(File.join(SORTED_DIR, release_name))
    #FileUtils.mv(Dir.glob("#{release_name}*"), File.join(SORTED_DIR, "#{release_name}/"))
    #release_artist = #Afrojack_Feat_Eva_Simons
    #release_album = #Take_Over_Control__Incl_Ian_Carey_Remix
    find_playlist(release_name)
  elsif File.fnmatch('.mp3', file)
    Mp3Info.open(file) do |mp3|
      puts "#{file}"
      puts "    title #{mp3.tag.title}"
      puts "    artist #{mp3.tag.artist}"
      puts "    album #{mp3.tag.album}"
      puts "    tracknum #{mp3.tag.tracknum}"
    end
  end
end
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
