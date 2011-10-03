require "rubygems"
require "mp3info"
require 'find'
require 'fileutils'
require 'yaml'
require 'set'

WORKING_DIR = "/Volumes/Media/Music/RSS"
LOG_FILE = 'genres.txt'
DELETION_LOG = 'deleted.txt'
UNKNOWN_DIR = "/Volumes/Media/Music/RSS_Unknown_Category"

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
        "Folk-Rock", "National Folk", "Swing", "Fusion", "Bebob", "Latin", 
        "Revival", "Celtic", "Bluegrass", "Avantgarde", "Gothic Rock", 
        "Progress. Rock", "Psychadel. Rock", "Symphonic Rock", "Slow Rock", 
        "Big Band", "Chorus", "Easy Listening", "Acoustic", "Humour", 
        "Speech", "Chanson", "Opera", "Chamber Music", "Sonata", "Symphony", 
        "Booty Bass", "Primus", "Porn Groove", "Satire", "Slow Jam", 
        "Club", "Tango", "Samba", "Folklore", "Ballad", "Power Ballad", 
        "Rhythmic Soul", "Freestyle", "Duet", "Punk Rock", "Drum Solo", 
        "A Capella", "Euro-House", "Dance Hall", "Goa", "Drum_&_Bass", 
        "Club-House", "Hardcore", "Terror", "Indie", "BritPop", "Negerpunk", 
        "Polsk Punk", "Beat", "Christian Gangsta Rap", "Heavy Metal", 
        "Black Metal", "Crossover", "Contemporary Christian", "Christian Rock",
        "Merengue", "Salsa", "Thrash Metal", "Anime", "Jpop", "Synthpop" 
        ]

genres_to_keep = [
  "Dance", "Hip-Hop", "Jazz", "Other", "Pop", "R&B", "Rap", "Techno", "Industrial", "Soundtrack",
  "Euro-Techno", "Ambient", "Trip-Hop", "Jazz+Funk", "Fusion", "Trance", "Classical", "Instrumental",
  "Acid", "House", "Game", "Bass", "Meditative", "Instrum. Pop", "Techno-Indust.", "Electronic", "Eurodance",
  "Top 40", "Pop/Funk", "Jungle", "Rave", "Lo-Fi", "Acid Punk", "Acid Jazz", "Fusion", "Acoustic", "Sonata",
  "Symphony", "Club", "Euro-House", "Dance Hall", "Goa", "Drum & Bass", "Club-House", "Hardcore", "Indie",
  "Beat", "Jpop", "Synthpop"
]

genre_partials_to_delete = [
  "country", "rock", "metal", "noise", "punk", "humour", "death", "celtic", "folk", "christian", "gospel",
  "oldies", "gothic", "blue", "funk", "soul", "acoustic", "latin", "hardcore", "chanson", "new wave",
  "disco", "rap", "reggae", "raggy", "a capella", "dance hall", "salsa", "ethnic", "comedy", "darkwave",
  "international", "musical", "polka", "tribal", "big band", "crossover", "swing", "jumpstyle"
]

release_partials_to_keep = [
  "scott_brown", "kutski", "elysium", "orbital",
  "bbc_radio1",
  "kid_kudi", "gucci_mane", "n.w.a", "chamillionaire", "talib_kweli", "t-pain", "wiz_khalifa", "j._cole",
  "lil_wayne", "lil_jon", "jill_scott", "eminem", "dj_khaled", "pitbull", "50_cent", "insane_clown_posse",
  "the_game", "nicki_minaj", "drake", "lupe_fiasco", "tyga", "shaggy",
  "blu_mar_ten", "chase_and_status",
  "avicii", "armin_van_buuren", "ferry_corsten", "laptop_symphony", "laidback_luke", "wolfgang_gartner",
  "hed_kandi", "chuckie", "carl_cox", "blank_and_jones",
  "whitelabel", "weird_al_yankovic", "limp_bizkit"
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
        genre = "Unknown"
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


File.open(LOG_FILE, 'w') do |f|
  genre_hash_of_sets.each do |genre, dirs|
    f.puts "#{genre}"
    delete_genre = false
    genre_partials_to_delete.each do |genre_partial| # check if genre is in our blacklist
      if genre.downcase.include? genre_partial
        puts "DELETING GENRE: #{genre}"
        delete_genre = true
      end
    end
    dirs.each do |dir|
      f.puts "    #{dir}"
      delete_release = true
      if delete_genre
        release_partials_to_keep.each do |release_partial| # check if release is in our whitelist
          if dir.downcase.include? release_partial
            delete_release = false
            break
          end
        end
        if delete_release
          puts "    #{dir}"
          FileUtils.rm_rf(File.join(WORKING_DIR, dir))
          genre_hash["#{genre}"] = genre_hash["#{genre}"] - 1
        end
      end
    end
  end
end

puts genre_hash.to_yaml

