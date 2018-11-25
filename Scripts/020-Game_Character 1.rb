#==============================================================================
# ■ Game_Character (第一部份)
#------------------------------------------------------------------------------
# 處理角色的類別。本類別作為 Game_Player 類別與 Game_Event 類別的總綱來使用。
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :id                       # ID
  attr_reader   :x                        # 地圖 X 座標 (理論座標)
  attr_reader   :y                        # 地圖 Y 座標 (理論座標)
  attr_reader   :real_x                   # 地圖 X 座標 (實際座標 * 128)
  attr_reader   :real_y                   # 地圖 Y 座標 (實際座標 * 128)
  attr_reader   :tile_id                  # 元件 ID  (0 為無效)
  attr_reader   :character_name           # 角色 文件名稱
  attr_reader   :character_hue            # 角色 樣子
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # 合成方式
  attr_reader   :direction                # 面向
  attr_reader   :pattern                  # 圖案
  attr_reader   :move_route_forcing       # 移動路線強制標誌
  attr_reader   :through                  # 穿越
  attr_accessor :animation_id             # 動畫 ID
  attr_accessor :transparent              # 透明狀態
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #--------------------------------------------------------------------------
  def initialize
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_hue = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 0
    @move_route_forcing = false
    @through = false
    @animation_id = 0
    @transparent = false
    @original_direction = 2
    @original_pattern = 0
    @move_type = 0
    @move_speed = 4
    @move_frequency = 6
    @move_route = nil
    @move_route_index = 0
    @original_move_route = nil
    @original_move_route_index = 0
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @always_on_top = false
    @anime_count = 0
    @stop_count = 0
    @jump_count = 0
    @jump_peak = 0
    @wait_count = 0
    @locked = false
    @prelock_direction = 0
  end
  #--------------------------------------------------------------------------
  # ● 移動中判斷
  #--------------------------------------------------------------------------
  def moving?
    # 如果在移動中理論座標與實際座標不同
    return (@real_x != @x * 128 or @real_y != @y * 128)
  end
  #--------------------------------------------------------------------------
  # ● 跳躍中判斷
  #--------------------------------------------------------------------------
  def jumping?
    # 如果跳躍中跳躍點數比 0 大
    return @jump_count > 0
  end
  #--------------------------------------------------------------------------
  # ● 矯正位置
  #--------------------------------------------------------------------------
  def straighten
    # 移動時動畫以及停止動畫為 ON 的情況下
    if @walk_anime or @step_anime
      # 設定圖形為 0
      @pattern = 0
    end
    # 清除動畫計算數值
    @anime_count = 0
    # 清除被鎖定的面向
    @prelock_direction = 0
  end
  #--------------------------------------------------------------------------
  # ● 強制移動路線
  #     move_route : 新的移動路線
  #--------------------------------------------------------------------------
  def force_move_route(move_route)
    # 保存原來的移動路線
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    # 更改移動路線
    @move_route = move_route
    @move_route_index = 0
    # 設定強制移動路線標誌
    @move_route_forcing = true
    # 清除被鎖定的面向
    @prelock_direction = 0
    # 清除等待計算數值
    @wait_count = 0
    # 自定義移動
    move_type_custom
  end
  #--------------------------------------------------------------------------
  # ● 可以通行判斷
  #     x : X 座標
  #     y : Y 座標
  #     d : 方向 (0,2,4,6,8)  ※ 0 = 全面向不能通行的情況判斷 (跳躍用)
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    # 取得新的座標
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # 座標在地圖以外的情況
    unless $game_map.valid?(new_x, new_y)
      # 不能通行
      return false
    end
    # 穿越是 ON 的情況下
    if @through
      # 可以通行
      return true
    end
    # 移動者的元件無法來到指定面向的情況下
    unless $game_map.passable?(x, y, d, self)
      # 通行不可
      return false
    end
    # 從指定面向不能進入到移動處元件的情況下
    unless $game_map.passable?(new_x, new_y, 10 - d)
      # 不能通行
      return false
    end
    # 循環全部事件
    for event in $game_map.events.values
      # 如果事件座標與移動目的地座標一致的情況下
      if event.x == new_x and event.y == new_y
        # 穿越為 ON
        unless event.through
          # 自己就是事件的情況下
          if self != $game_player
            # 不能通行
            return false
          end
          # 自己與夥伴座標的描述
          if event.character_name != ""
            # 不能通行
            return false
          end
        end
      end
    end
    # 如果主角的座標與移動目的地座標一致的情況下
    if $game_player.x == new_x and $game_player.y == new_y
      # 穿越為 ON
      unless $game_player.through
        # 自己本身座標的描述
        if @character_name != ""
          # 不能通行
          return false
        end
      end
    end
    # 可以通行
    return true
  end
  #--------------------------------------------------------------------------
  # ● 鎖定
  #--------------------------------------------------------------------------
  def lock
    # 如果已經被鎖定的情況下
    if @locked
      # 過程結束
      return
    end
    # 保存鎖定前的面向
    @prelock_direction = @direction
    # 保存主角的面向
    turn_toward_player
    # 設定鎖定中標誌
    @locked = true
  end
  #--------------------------------------------------------------------------
  # ● 鎖定中判斷
  #--------------------------------------------------------------------------
  def lock?
    return @locked
  end
  #--------------------------------------------------------------------------
  # ● 解除鎖定
  #--------------------------------------------------------------------------
  def unlock
    # 沒有鎖定的情況下
    unless @locked
      # 過程結束
      return
    end
    # 清除鎖定中標誌
    @locked = false
    # 沒有固定面向的情況下
    unless @direction_fix
      # 如果保存了鎖定前的面向
      if @prelock_direction != 0
        # 還原為鎖定前的面向
        @direction = @prelock_direction
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 移動到指定位置
  #     x : X 座標
  #     y : Y 座標
  #--------------------------------------------------------------------------
  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end
  #--------------------------------------------------------------------------
  # ● 取得畫面 X 座標
  #--------------------------------------------------------------------------
  def screen_x
    # 通過實際座標和地圖的顯示位置來求得畫面座標
    return (@real_x - $game_map.display_x + 3) / 4 + 16
  end
  #--------------------------------------------------------------------------
  # ● 取得畫面 Y 座標
  #--------------------------------------------------------------------------
  def screen_y
    # 通過實際座標和地圖的顯示位置來求得畫面座標
    y = (@real_y - $game_map.display_y + 3) / 4 + 32
    # 取跳躍計算數值小的 Y 座標
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end
  #--------------------------------------------------------------------------
  # ● 取得畫面 Z 座標
  #     height : 角色的高度
  #--------------------------------------------------------------------------
  def screen_z(height = 0)
    # 在最前顯示的標誌為 ON 的情況下
    if @always_on_top
      # 無條件設定為 999
      return 999
    end
    # 通過實際座標和地圖的顯示位置來求得畫面座標
    z = (@real_y - $game_map.display_y + 3) / 4 + 32
    # 元件的情況下
    if @tile_id > 0
      # 優先加入元件 * 32 
      return z + $game_map.priorities[@tile_id] * 32
    # 角色的場合
    else
      # 如果高度超過 32 就判斷為滿足 31
      return z + ((height > 32) ? 31 : 0)
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得草木繁茂處的深度
  #--------------------------------------------------------------------------
  def bush_depth
    # 如果是元件、並且在最前顯示為 ON 的情況下
    if @tile_id > 0 or @always_on_top
      return 0
    end
    # 在跳躍中以外的元件屬性為 12，除此之外為 0
    if @jump_count == 0 and $game_map.bush?(@x, @y)
      return 12
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得地形標記
  #--------------------------------------------------------------------------
  def terrain_tag
    return $game_map.terrain_tag(@x, @y)
  end
end
