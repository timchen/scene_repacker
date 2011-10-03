require "rubygems"
require "mp3info"
require 'find'
require 'fileutils'
require 'yaml'
require 'set'

WORKING_DIR = "/Volumes/Media/Music/RSS"

def strip_numerical_genre(genre_s)
  genre_s = "Unknown" if genre_s.nil? or genre_s == ""
  genre_s.gsub(/\([0-9]+\)/, '')
end

genres = [ 
        "Blues", "Classic Rock", "Country", "Dance", "Disco", "Funk", 
        "Grunge", "Hip-Hop", "Jazz", "Metal", "New Age", "Oldies", "Other", 
        "Pop", "R&B", "Rap", "Reggae", "Rock", "Techno", "Industrial", 
        "Alternative", "Ska", "Death Metal", "Pranks", "Soundtrack", 
        "Euro-Techno", "Ambient", "Trip-Hop", "Vocal", "Jazz+Funk", "Fusion", 
        "Trance", "Classical", "Instrumental", "Acid", "House", "Game", 
        "Sound Clip", "Gospel", "Noise", "Alt. Rock", "Bass", "Soul", 
        "Punk", "Space", "Meditative", "Instrum. Pop", "Instrum. Rock", 
        "Ethnic", "Gothic", "Darkwave", "Techno-Indust.", "Electronic", 
        "Pop-Folk", "Eurodance", "Dream", "Southern Rock", "Comedy", 
        "Cult", "Gangsta", "Top 40", "Christian Rap", "Pop/Funk", "Jungle", 
        "Native American", "Cabaret", "New Wave", "Psychadelic", "Rave", 
        "Showtunes", "Trailer", "Lo-Fi", "Tribal", "Acid Punk", "Acid Jazz", 
        "Polka", "Retro", "Musical", "Rock & Roll", "Hard Rock", "Folk", 
        "Folk/Rock", "National Folk", "Swing", "Fusion", "Bebob", "Latin", 
        "Revival", "Celtic", "Bluegrass", "Avantgarde", "Gothic Rock", 
        "Progress. Rock", "Psychadel. Rock", "Symphonic Rock", "Slow Rock", 
        "Big Band", "Chorus", "Easy Listening", "Acoustic", "Humour", 
        "Speech", "Chanson", "Opera", "Chamber Music", "Sonata", "Symphony", 
        "Booty Bass", "Primus", "Porn Groove", "Satire", "Slow Jam", 
        "Club", "Tango", "Samba", "Folklore", "Ballad", "Power Ballad", 
        "Rhythmic Soul", "Freestyle", "Duet", "Punk Rock", "Drum Solo", 
        "A Capella", "Euro-House", "Dance Hall", "Goa", "Drum & Bass", 
        "Club-House", "Hardcore", "Terror", "Indie", "BritPop", "Negerpunk", 
        "Polsk Punk", "Beat", "Christian Gangsta Rap", "Heavy Metal", 
        "Black Metal", "Crossover", "Contemporary Christian", "Christian Rock",
        "Merengue", "Salsa", "Thrash Metal", "Anime", "Jpop", "Synthpop" 
        ]

genre_hash = Hash.new(0)
genre_hash_of_sets = {}# = Hash.new(Set.new)

genre = "Unknown"
ctr = 0

Dir.foreach(WORKING_DIR) do |dir|
  next if dir == '.' or dir == '..' or dir == '.DS_Store'
  #break if ctr == 200
  puts "still going...#{ctr}" if ctr % 1000 == 0
  genre_found = false

  Dir.foreach(File.join(WORKING_DIR, dir)) do |file|
    next if file == '.' or file == '..' or file == '.DS_Store'
    next if genre_found

    if File.fnmatch('*.mp3', File.basename(file)) and not genre_found
      begin
        Mp3Info.open(File.join(WORKING_DIR, dir, file)) do |mp3|
          #puts dir
          #puts "#{File.basename(file)}"
          #puts "   #{strip_numerical_genre(mp3.tag.genre_s)}"
          genre_found = true
          genre = strip_numerical_genre(mp3.tag.genre_s).gsub(/\w+/) { |s| s.capitalize }
          #puts genre
          break
        end
      rescue
        puts "Problem reading tag info for: #{File.join(dir, file)}"
        genre_found = true
        genre = "Unknown"
        break
      end
    end

    if genre_found 
      genre_hash["#{genre}"] = genre_hash["#{genre}"] + 1
      if genre_hash_of_sets["#{genre}"].nil?
        genre_hash_of_sets["#{genre}"] = Set.new("#{dir}") 
      else
        genre_hash_of_sets["#{genre}"].add("#{dir}")
      end
    end
  end
  ctr = ctr + 1
end


genre_hash_of_sets.each do |genre, dirs|
  puts "#{genre}"
  dirs.each do |dir|
    puts "    #{dir}"
  end
#    dir.each do |wtf|
#      puts "        #{wtf}"
#    end
end

puts genre_hash.to_yaml
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

