#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 處理主角的類別。事件啟動的判斷、以及地圖的捲動等功能。
# 本類的實例請參考 $game_player。
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● 常數
  #--------------------------------------------------------------------------
  CENTER_X = (320 - 16) * 4   # 畫面中央的 X 座標 * 4
  CENTER_Y = (240 - 16) * 4   # 畫面中央的 Y 座標 * 4
  #--------------------------------------------------------------------------
  # ● 可以通行判斷
  #     x : X 座標
  #     y : Y 座標
  #     d : 方向 (0,2,4,6,8)  ※ 0 = 全方向不能通行的情況判斷 (跳躍用)
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    # 求得新的座標
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # 如果座標不在地圖上
    unless $game_map.valid?(new_x, new_y)
      # 不能通行
      return false
    end
    # 除錯模式為 ON 並且按下 CTRL 鍵的情況下
    if $DEBUG and Input.press?(Input::CTRL)
      # 可以通行
      return true
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 像通到畫面中央一樣的設定地圖的顯示位置
  #--------------------------------------------------------------------------
  def center(x, y)
    max_x = ($game_map.width - 20) * 128
    max_y = ($game_map.height - 15) * 128
    $game_map.display_x = [0, [x * 128 - CENTER_X, max_x].min].max
    $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max
  end
  #--------------------------------------------------------------------------
  # ● 向指定的位置移動
  #     x : X 座標
  #     y : Y 座標
  #--------------------------------------------------------------------------
  def moveto(x, y)
    super
    # 自動連接
    center(x, y)
    # 製作遇敵計算數值
    make_encounter_count
  end
  #--------------------------------------------------------------------------
  # ● 增加步數
  #--------------------------------------------------------------------------
  def increase_steps
    super
    # 不是強制移動路線的場合
    unless @move_route_forcing
      # 增加步數
      $game_party.increase_steps
      # 步數是偶數的情況下
      if $game_party.steps % 2 == 0
        # 檢查連續傷害
        $game_party.check_map_slip_damage
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得遇敵計算數值
  #--------------------------------------------------------------------------
  def encounter_count
    return @encounter_count
  end
  #--------------------------------------------------------------------------
  # ● 製作遇敵計算數值
  #--------------------------------------------------------------------------
  def make_encounter_count
    # 兩種顏色震動的圖像
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def refresh
    # 同伴人數為 0 的情況下
    if $game_party.actors.size == 0
      # 清除角色的檔案名稱及目標
      @character_name = ""
      @character_hue = 0
      # 分歧結束
      return
    end
    # 取得帶頭的角色
    actor = $game_party.actors[0]
    # 設定角色的檔案名稱及目標
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    # 初始化不透明度和合成方式
    @opacity = 255
    @blend_type = 0
  end
  #--------------------------------------------------------------------------
  # ● 同位置的事件啟動判斷
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    result = false
    # 事件執行中的情況下
    if $game_system.map_interpreter.running?
      return result
    end
    # 全部事件的循環
    for event in $game_map.events.values
      # 事件座標與目標一致的情況下
      if event.x == @x and event.y == @y and triggers.include?(event.trigger)
        # 跳躍中以外的情況下、啟動判斷是同位置的事件
        if not event.jumping? and event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 正面事件的啟動判斷
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    result = false
    # 事件執行中的情況下
    if $game_system.map_interpreter.running?
      return result
    end
    # 計算正面座標
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    # 全部事件的循環
    for event in $game_map.events.values
      # 事件座標與目標一致的情況下
      if event.x == new_x and event.y == new_y and
         triggers.include?(event.trigger)
        # 跳躍中以外的情況下、啟動判斷是正面的事件
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    # 找不到符合條件的事件的情況下
    if result == false
      # 正面的元件是計算數值器的情況下
      if $game_map.counter?(new_x, new_y)
        # 計算 1 元件裡側的座標
        new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        # 全事件的循環
        for event in $game_map.events.values
          # 事件座標與目標一致的情況下
          if event.x == new_x and event.y == new_y and
             triggers.include?(event.trigger)
            # 跳躍中以外的情況下、啟動判斷是正面的事件
            if not event.jumping? and not event.over_trigger?
              event.start
              result = true
            end
          end
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 接觸事件啟動判斷
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    result = false
    # 事件執行中的情況下
    if $game_system.map_interpreter.running?
      return result
    end
    # 全事件的循環
    for event in $game_map.events.values
      # 事件座標與目標一致的情況下
      if event.x == x and event.y == y and [1,2].include?(event.trigger)
        # 跳躍中以外的情況下、啟動判斷是正面的事件
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 畫面更新
  #--------------------------------------------------------------------------
  def update
    # 本地變量記錄移動訊息
    last_moving = moving?
    # 移動中、事件執行中、強制移動路線中、
    # 訊息視窗一個也不顯示的時候
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      # 如果方向鍵被按下、主角就朝那個方向移動
      case Input.dir4
      when 2
        move_down
      when 4
        move_left
      when 6
        move_right
      when 8
        move_up
      end
    end
    # 本地變量記憶座標
    last_real_x = @real_x
    last_real_y = @real_y
    super
    # 角色向下移動、畫面上的位置在中央下方的情況下
    if @real_y > last_real_y and @real_y - $game_map.display_y > CENTER_Y
      # 畫面向下捲動
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # 角色向左移動、畫面上的位置在中央左方的情況下
    if @real_x < last_real_x and @real_x - $game_map.display_x < CENTER_X
      # 畫面向左捲動
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # 角色向右移動、畫面上的位置在中央右方的情況下
    if @real_x > last_real_x and @real_x - $game_map.display_x > CENTER_X
      # 畫面向右捲動
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # 角色向上移動、畫面上的位置在中央上方的情況下
    if @real_y < last_real_y and @real_y - $game_map.display_y < CENTER_Y
      # 畫面向上捲動
      $game_map.scroll_up(last_real_y - @real_y)
    end
    # 不在移動中的情況下
    unless moving?
      # 上次主角移動中的情況
      if last_moving
        # 與同位置的事件接觸就判斷為事件啟動
        result = check_event_trigger_here([1,2])
        # 沒有可以啟動的事件的情況下
        if result == false
          # 除錯模式為 ON 並且按下 CTRL 鍵的情況下除外
          unless $DEBUG and Input.press?(Input::CTRL)
            # 遇敵計算數值下降
            if @encounter_count > 0
              @encounter_count -= 1
            end
          end
        end
      end
      # 按下 C 鍵的情況下
      if Input.trigger?(Input::C)
        # 判斷為同位置以及正面的事件啟動
        check_event_trigger_here([0])
        check_event_trigger_there([0,1,2])
      end
    end
  end
end
