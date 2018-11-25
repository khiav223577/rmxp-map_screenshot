require File.expand_path('../lib', __FILE__)
require 'fileutils'

#----------------------------------------
#  備份RM的資料
#----------------------------------------
def txt_dump(obj)
  vars = obj.instance_variables
  if vars.size == 0
    case obj
    when Array      ; return obj.map{|s| txt_dump(s) }
    when Hash       ; return Hash[obj.map{|k, v| [k, txt_dump(v)]}.sort_by(&:first)]  
    when NilClass   ; return obj
    when Fixnum     ; return obj
    when Float      ; return obj
    when String     ; return obj.force_encoding('utf-8')
    when FalseClass ; return obj
    when TrueClass  ; return obj
    else
      puts "error in txt_dump: #{obj.class}"
      exit
    end
  else
    return Hash[vars.map{|k| [k, txt_dump(obj.instance_variable_get(k))]}.sort_by(&:first)]  
  end
end
if ARGV.include?('-rxdata')
  FileUtils.mkdir_p('Data')
  FileUtils.mkdir_p('Scripts')
  # a = YAML.load(File.read("Data/System.yaml"))
  # save_path(a, "..", "Data", "System.rxdata")
  AVAILABLE_RX_DATA = /\A(?:Tilesets|Troops|Weapons|Map\d+|MapInfos|Skills|States|System|Actors|Animations|Armors|Classes|CommonEvents|Enemies|Items)\z/
  for path in Dir[get_path("..", "..", "Data", "*.rxdata")]
    basename = File.basename(path, '.*')
    next if not basename =~ AVAILABLE_RX_DATA
    file1_path = path
    file2_path = get_path("..", "Data", "#{basename}.rxdata")
    data1 = File.read(file1_path)
    data2 = File.read(file2_path) rescue nil
    next if data1 == data2 #no change
    is_system = (basename == 'System')
    data = txt_dump(load_path(path))
    data[:@magic_number] = 8817835 if is_system #this value will change every time RM is saved
    data = data.to_yaml
    output_path = get_path("..", "Data", "#{basename}.txt")
    prev_data = File.read(output_path) rescue nil
    next if data == prev_data #avoid System.rxdata to update
    File.open(output_path, 'w'){|f| f.write(data) }
    FileUtils.cp(file1_path, file2_path)
  end
end

#----------------------------------------
#  新增
#----------------------------------------
def write_if_changed(path, content)
  return if File.exists?(path) and File.read(path) == content
  puts "Write: #{path}"
  File.write(path, content)
end
#write_if_changed("echoskills.txt", load_echo_data("..", "..", "Data", "echoskills.rxdata")) #備份echoskills
#write_if_changed("echomonsters.txt", load_echo_data("..", "..", "Data", "echomonsters.rxdata")) #備份echomonsters
#write_if_changed("MapSet.txt", load_echo_data("..", "..", "Data", "MapSet.rxdata")) #備份MapSet
#data = Marshal.load(Zlib::Inflate.inflate(load_path("..", "..", "Data", "map_terrain_data.rxdata")))
#data = Hash[data.to_a.sort!.map!{|k,v| v.each{|k2, v2| v[k2] = Hash[v2.sort]}; [k, Hash[v.sort]] }]
#write_if_changed("map_terrain_data.txt", JSON.pretty_generate(data)) #備份map_terrain_data
$SCRIPTS = load_path("..", "..", "Data", "Scripts.rxdata")
#save_path($SCRIPTS, "..", "Scripts", "Scripts.rxdata") #備份原來的scripts.rxdata
#FileUtils.cp(get_path("..", "..", "config"), get_path("..", "config")) #備份回音編輯器的config
#%w(I18n Database).each do |type|
#  FileUtils.rm_r(get_path("..", type), :force => true) 
#  FileUtils.cp_r(get_path("..", "..", type), get_path("..", type))
#end
hash_encoding = HashEncoding.new.load('..', 'encoding_data.rxdata')

# ----------------------------------------------------------------
# ● Scripts
# ----------------------------------------------------------------
origin_scripts = Dir[get_path("..", "Scripts", "*.rb")]
current_scripts = []
$SCRIPTS.each_with_index{|(unique_number, name, script), index|
  name.force_encoding('utf-8')
  script = Zlib::Inflate.inflate(script).force_encoding('utf-8').gsub(/\r\n/, "\n")
  base_path = get_path("..", "Scripts", ' ').strip #最後一個不能用空字串否則會被忽略。而且還要strip不然mac上檔名會多一個空白＝ ＝
  base_path << '/' if base_path[-1] != '/'
  counter = hash_encoding.encode(unique_number)
  hash_encoding[unique_number] = index #記錄順序，在restore_script時需要用到
  path = ("%s%03d-%s.rb" % [base_path, counter, name])
  current_scripts << path
  write_if_changed(path, script)
}
for path in (origin_scripts - current_scripts)
  puts "Delete: " + path
  File.delete(path) # dangerous
end
hash_encoding.save('..', 'encoding_data.rxdata')
