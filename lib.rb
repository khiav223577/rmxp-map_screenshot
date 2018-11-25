# encoding: utf-8
Encoding.default_internal = 'utf-8'
Encoding.default_external = 'utf-8'
require 'json'
require 'yaml'
require 'zlib'
require 'base64'
require './rgss/rpg'
require './rgss/table'
require './rgss/tone'
require './rgss/color'
def get_path(*args)
  return File.expand_path(File.join(*args), __FILE__).encode("utf-8")
end
#----------------------------------------
#  記錄檔名對應的counter
#----------------------------------------
def save_path(data, *args)
  path = get_path(*args)
  puts "Save: #{path}"
  File.open(path, "wb"){|f| Marshal.dump(data, f) }
end
def load_path(*args)
  path = get_path(*args)
  return nil if not File.exist?(path)
  puts "Load: #{path}"
  File.open(path, "rb"){|f| return Marshal.load(f) }
end
def load_echo_data(*args)
  a = Zlib::Inflate.inflate(Base64.decode64(load_path(*args)))
  a.force_encoding('utf-8')
  return a
end
def save_echo_data(data, *args)
  save_path(Base64.encode64(Zlib::Deflate.deflate(data)), *args)
end
class HashEncoding
  def initialize()
    @hash = {}         #記錄key對應到的counter
    @value_hash = {}   #記錄key中儲存的資料
    @invert_array = [] #記錄counter對應到的key
    @counter = 0
  end
#-------------------------------
#  encode/decode
#-------------------------------
  def encode(data)
    idx = (@hash[data] ||= (@counter += 1))
    @invert_array[idx] = data
    return idx
  end
  def decode(idx)
    return @invert_array[idx]
  end
#-------------------------------
#  儲存
#-------------------------------
  def save(*args)
    save_path([@hash, @counter, @value_hash], *args)
    return self
  end
  def load(*args)
    data = load_path(*args)
    @hash, @counter, @value_hash = data if data
    @invert_array = @hash.to_a.map(&:first).unshift(nil)
    @value_hash ||= {}
    return self
  end
  def each_keys
    @invert_array.each{|data| yield(data) }
  end
#-------------------------------
#  儲存資料在key內
#-------------------------------
  def [](key)
    return @value_hash[key]
  end
  def []=(key, value)
    return (@value_hash[key] = value)
  end
end


