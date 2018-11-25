#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 處理地圖的類別。包含捲動以及可以通行的判斷功能。本類別實例請參考 $game_map。
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_accessor :tileset_name             # 元件 文件名稱
  attr_accessor :autotile_names           # 自動元件 文件名稱
  attr_accessor :panorama_name            # 全景 文件名稱
  attr_accessor :panorama_hue             # 全景 樣子
  attr_accessor :fog_name                 # 迷霧 文件名稱
  attr_accessor :fog_hue                  # 迷霧 樣子
  attr_accessor :fog_opacity              # 迷霧 不透明度
  attr_accessor :fog_blend_type           # 迷霧 混合方式
  attr_accessor :fog_zoom                 # 迷霧 放大率
  attr_accessor :fog_sx                   # 迷霧 SX
  attr_accessor :fog_sy                   # 迷霧 SY
  attr_accessor :battleback_name          # 戰鬥背景 文件名稱
  attr_accessor :display_x                # 顯示 X 座標 * 128
  attr_accessor :display_y                # 顯示 Y 座標 * 128
  attr_accessor :need_refresh             # 更新要求標誌
  attr_reader   :passages                 # 通行表
  attr_reader   :priorities               # 優先表
  attr_reader   :terrain_tags             # 地形標記表
  attr_reader   :events                   # 事件
  attr_reader   :fog_ox                   # 迷霧 原點 X 座標
  attr_reader   :fog_oy                   # 迷霧 原點 Y 座標
  attr_reader   :fog_tone                 # 迷霧 色調
  #--------------------------------------------------------------------------
  # ● 初始化條件
  #--------------------------------------------------------------------------
  def initialize
    @map_id = 0
    @display_x = 0
    @display_y = 0
  end
  #--------------------------------------------------------------------------
  # ● 設定
  #     map_id : 地圖 ID
  #--------------------------------------------------------------------------
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
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
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
  #--------------------------------------------------------------------------
  # ● 取得地圖 ID
  #--------------------------------------------------------------------------
  def map_id
    return @map_id
  end
  #--------------------------------------------------------------------------
  # ● 取得寬度
  #--------------------------------------------------------------------------
  def width
    return @map.width
  end
  #--------------------------------------------------------------------------
  # ● 取得高度
  #--------------------------------------------------------------------------
  def height
    return @map.height
  end
  #--------------------------------------------------------------------------
  # ● 取得遇敵列表
  #--------------------------------------------------------------------------
  def encounter_list
    return @map.encounter_list
  end
  #--------------------------------------------------------------------------
  # ● 取得遇敵步數
  #--------------------------------------------------------------------------
  def encounter_step
    return @map.encounter_step
  end
  #--------------------------------------------------------------------------
  # ● 取得地圖資料
  #--------------------------------------------------------------------------
  def data
    return @map.data
  end
  #--------------------------------------------------------------------------
  # ● BGM / BGS 自動切換
  #--------------------------------------------------------------------------
  def autoplay
    if @map.autoplay_bgm
      $game_system.bgm_play(@map.bgm)
    end
    if @map.autoplay_bgs
      $game_system.bgs_play(@map.bgs)
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def refresh
    # 地圖 ID 有效
    if @map_id > 0
      # 更新全部的地圖事件
      for event in @events.values
        event.refresh
      end
      # 更新全部的共通事件
      for common_event in @common_events.values
        common_event.refresh
      end
    end
    # 清除更新要求標誌
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # ● 向下捲動
  #     distance : 捲動距離
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    @display_y = [@display_y + distance, (self.height - 15) * 128].min
  end
  #--------------------------------------------------------------------------
  # ● 向左捲動
  #     distance : 捲動距離
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    @display_x = [@display_x - distance, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 向右捲動
  #     distance : 捲動距離
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    @display_x = [@display_x + distance, (self.width - 20) * 128].min
  end
  #--------------------------------------------------------------------------
  # ● 向上捲動
  #     distance : 捲動距離
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    @display_y = [@display_y - distance, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 有效座標判斷
  #     x          : X 座標
  #     y          : Y 座標
  #--------------------------------------------------------------------------
  def valid?(x, y)
    return (x >= 0 and x < width and y >= 0 and y < height)
  end
  #--------------------------------------------------------------------------
  # ● 可以通行判斷
  #     x          : X 座標
  #     y          : Y 座標
  #     d          : 方向 (0,2,4,6,8,10)
  #                  ※ 0,10 = 全方向不能通行的情況的判斷 (跳躍等)
  #     self_event : 自己 (判斷事件可以通行的情況下)
  #--------------------------------------------------------------------------
  def passable?(x, y, d, self_event = nil)
    # 如果求得的座標不在地圖上
    unless valid?(x, y)
      # 不能通行
      return false
    end
    # 方向 (0,2,4,6,8,10) 與障礙物接觸 (0,1,2,4,8,0) 後變換
    bit = (1 << (d / 2 - 1)) & 0x0f
    # 循環全部的事件
    for event in events.values
      # 自己以外的元件與座標相同的情況
      if event.tile_id >= 0 and event != self_event and
         event.x == x and event.y == y and not event.through
        # 如果障礙物的接觸被設定的情況下
        if @passages[event.tile_id] & bit != 0
          # 不能通行
          return false
        # 如果全方向的障礙物的接觸被設定的情況下
        elsif @passages[event.tile_id] & 0x0f == 0x0f
          # 不能通行
          return false
        # 這以外的優先度為 0 的情況下
        elsif @priorities[event.tile_id] == 0
          # 可以通行
          return true
        end
      end
    end
    # 從階層按照由上到下的順序調查循環
    for i in [2, 1, 0]
      # 取得元件 ID
      tile_id = data[x, y, i]
      # 取得元件 ID 失敗
      if tile_id == nil
        # 不能通行
        return false
      # 如果障礙物的接觸被設定的情況下
      elsif @passages[tile_id] & bit != 0
        # 不能通行
        return false
      # 如果全方向的障礙物的接觸被設定的情況下
      elsif @passages[tile_id] & 0x0f == 0x0f
        # 不能通行
        return false
      # 這以外的優先度為 0 的情況下
      elsif @priorities[tile_id] == 0
        # 可以通行
        return true
      end
    end
    # 可以通行
    return true
  end
  #--------------------------------------------------------------------------
  # ● 草木繁茂處判斷
  #     x          : X 座標
  #     y          : Y 座標
  #--------------------------------------------------------------------------
  def bush?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x40 == 0x40
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 反擊判斷
  #     x          : X 座標
  #     y          : Y 座標
  #--------------------------------------------------------------------------
  def counter?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x80 == 0x80
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 取得地形標誌
  #     x          : X 座標
  #     y          : Y 座標
  #--------------------------------------------------------------------------
  def terrain_tag(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return 0
        elsif @terrain_tags[tile_id] > 0
          return @terrain_tags[tile_id]
        end
      end
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 取得指定位置的事件 ID
  #     x          : X 座標
  #     y          : Y 座標
  #--------------------------------------------------------------------------
  def check_event(x, y)
    for event in $game_map.events.values
      if event.x == x and event.y == y
        return event.id
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 捲動開始
  #     direction : 捲動方向
  #     distance  : 捲動距離
  #     speed     : 捲動速度
  #--------------------------------------------------------------------------
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance * 128
    @scroll_speed = speed
  end
  #--------------------------------------------------------------------------
  # ● 捲動中判斷
  #--------------------------------------------------------------------------
  def scrolling?
    return @scroll_rest > 0
  end
  #--------------------------------------------------------------------------
  # ● 開始變更迷霧的色調
  #     tone     : 色調
  #     duration : 時間
  #--------------------------------------------------------------------------
  def start_fog_tone_change(tone, duration)
    @fog_tone_target = tone.clone
    @fog_tone_duration = duration
    if @fog_tone_duration == 0
      @fog_tone = @fog_tone_target.clone
    end
  end
  #--------------------------------------------------------------------------
  # ● 開始變更迷霧的不透明度
  #     opacity  : 不透明度
  #     duration : 時間
  #--------------------------------------------------------------------------
  def start_fog_opacity_change(opacity, duration)
    @fog_opacity_target = opacity * 1.0
    @fog_opacity_duration = duration
    if @fog_opacity_duration == 0
      @fog_opacity = @fog_opacity_target
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 還原必要的地圖
    if $game_map.need_refresh
      refresh
    end
    # 捲動中的情況下
    if @scroll_rest > 0
      # 捲動速度變化為地圖座標系的距離
      distance = 2 ** @scroll_speed
      # 執行捲動
      case @scroll_direction
      when 2  # 下
        scroll_down(distance)
      when 4  # 左
        scroll_left(distance)
      when 6  # 右
        scroll_right(distance)
      when 8  # 上
        scroll_up(distance)
      end
      # 捲動距離的減法運算
      @scroll_rest -= distance
    end
    # 更新地圖事件
    for event in @events.values
      event.update
    end
    # 更新共通事件
    for common_event in @common_events.values
      common_event.update
    end
    # 處理迷霧的捲動
    @fog_ox -= @fog_sx / 8.0
    @fog_oy -= @fog_sy / 8.0
    # 處理迷霧的色調變更
    if @fog_tone_duration >= 1
      d = @fog_tone_duration
      target = @fog_tone_target
      @fog_tone.red = (@fog_tone.red * (d - 1) + target.red) / d
      @fog_tone.green = (@fog_tone.green * (d - 1) + target.green) / d
      @fog_tone.blue = (@fog_tone.blue * (d - 1) + target.blue) / d
      @fog_tone.gray = (@fog_tone.gray * (d - 1) + target.gray) / d
      @fog_tone_duration -= 1
    end
    # 處理迷霧的不透明度變更
    if @fog_opacity_duration >= 1
      d = @fog_opacity_duration
      @fog_opacity = (@fog_opacity * (d - 1) + @fog_opacity_target) / d
      @fog_opacity_duration -= 1
    end
  end
end
