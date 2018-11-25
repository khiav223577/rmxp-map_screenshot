class Game_Map
  def setup(map_id)
    # 地圖 ID 記錄到 @map_id 
    @map_id = map_id
    # 地圖文件裝載後、設定到 @map 
    @map = load_data(sprintf("Data/Map%03d.rxdata", @map_id))
    # 定義實例變量設定地圖元件訊息
    tileset = $data_tilesets[@map.tileset_id]
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @fog_sx = tileset.fog_sx
    @fog_sy = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    @terrain_tags = tileset.terrain_tags
    # 初始化顯示座標
    @display_x = 0
    @display_y = 0
    # 清除更新要求標誌
    @need_refresh = false
    # 設定地圖事件資料
    @events = {}
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
    end
    # 設定共通事件資料
    @common_events = {}
    #for i in 1...$data_common_events.size
    #  @common_events[i] = Game_CommonEvent.new(i)
    #end
    # 初始化迷霧的各種訊息
    @fog_ox = 0
    @fog_oy = 0
    @fog_tone = Tone.new(0, 0, 0, 0)
    @fog_tone_target = Tone.new(0, 0, 0, 0)
    @fog_tone_duration = 0
    @fog_opacity_duration = 0
    @fog_opacity_target = 0
    # 初始化捲動訊息
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
  end
end
class Spriteset_Map
  def character_sprite_of(id)
    @character_sprites.find{|s| s.character.id == id }
  end

  def screen_shot!
    mid = $game_map.map_id
    png_name = "OUTPUT/%03d-%s.png" % [mid,$map_infos[mid].name]
    return if FileTest.exist?(png_name)
    begin
      file = open(png_name, "r")
      file.close()
      return
    rescue
    end
    
    bitmap = @tilemap.bitmap
    $game_map.events.values.each do |event|
      next if (sprite = character_sprite_of(event.id)) == nil
      bitmap.blt(sprite.x, sprite.y, sprite.bitmap, sprite.src_rect)
    end

    old_time = Time.new
    bitmap.save_png(png_name)
    # bitmap.make_png("#{png_name}")
    string = "#{png_name} was created. \n" +
            "File size: width #{bitmap.width}, height #{bitmap.height}. \n" +
            "Time taken: #{Time.now - old_time} seconds."
    print("#{string}")
  end
end
#======================================
#======================================
$data_tilesets      = load_data("Data/Tilesets.rxdata")
$map_infos          = load_data("Data/MapInfos.rxdata")
# 製作各種遊戲目標
$game_temp          = Game_Temp.new
$game_system        = Game_System.new
$game_switches      = Game_Switches.new
$game_variables     = Game_Variables.new
$game_self_switches = Game_SelfSwitches.new
$game_screen        = Game_Screen.new
$game_actors        = Game_Actors.new
$game_party         = Game_Party.new
$game_troop         = Game_Troop.new
$game_map           = Game_Map.new
$game_player        = Game_Player.new
$Bitmap = Bitmap.new(640, 480)
$Bitmap.font.color = Color.new(255,0,0)
$Bitmap.font.size = 40
$Bitmap.font.name = (["微軟正黑體", "新細明體", "黑体"])
ss = Sprite.new
ss.x = 0
ss.y = 0
ss.z = 9999999
ss.bitmap = $Bitmap
#======================================
#======================================
old_time = Time.now
time1 = old_time
map_id = 0
$Bitmap.draw_text(0,240-16,640,32,"0",1)
while true
  map_id += 1
  break if not FileTest.exist?("Data/Map%03d.rxdata" % map_id)
  if (time2 = Time.now) - time1 > 0.02 #*999999999999999
    time1 = time2
    $Bitmap.clear
    $Bitmap.draw_text(0,240-16,640,32,map_id.to_s,1)
    Graphics.update
  end
  if map_id > 99999 #error detect
    raise RuntimeError, "map_id > 99999"
  end
  $game_map.setup(map_id)
  Spriteset_Map.new.screen_shot!
end
p Time.now - old_time
exit
