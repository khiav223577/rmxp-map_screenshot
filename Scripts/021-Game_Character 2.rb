#==============================================================================
# ■ Game_Character (第二部份)
#------------------------------------------------------------------------------
# 處理角色的類別。本類別作為 Game_Player 類別與 Game_Event 類別的總綱來使用。
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 跳躍中、移動中、停止中的分歧
    if jumping?
      update_jump
    elsif moving?
      update_move
    else
      update_stop
    end
    # 動畫計算數值超過最大值的情況下
    # ※最大值等於基本值減去移動速度 * 1 的值
    if @anime_count > 18 - @move_speed * 2
      # 停止動畫為 OFF 並且在停止中的情況下
      if not @step_anime and @stop_count > 0
        # 還原為原來的圖形
        @pattern = @original_pattern
      # 停止動畫為 ON 並且在移動中的情況下
      else
        # 更新圖形
        @pattern = (@pattern + 1) % 4
      end
      # 清除動畫計算數值
      @anime_count = 0
    end
    # 等待中的情況下
    if @wait_count > 0
      # 減少等待計算數值
      @wait_count -= 1
      return
    end
    # 強制移動路線的場合
    if @move_route_forcing
      # 自定義移動
      move_type_custom
      return
    end
    # 事件執行待機中並且為鎖定狀態的情況下
    if @starting or lock?
      # 不做規則移動
      return
    end
    # 如果停止計算數值超過了一定的值(由移動頻率算出)
    if @stop_count > (40 - @move_frequency * 2) * (6 - @move_frequency)
      # 移動類型分歧
      case @move_type
      when 1  # 隨機
        move_type_random
      when 2  # 接近
        move_type_toward_player
      when 3  # 自定義
        move_type_custom
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (跳躍)
  #--------------------------------------------------------------------------
  def update_jump
    # 跳躍計數減 1
    @jump_count -= 1
    # 計算新座標
    @real_x = (@real_x * @jump_count + @x * 128) / (@jump_count + 1)
    @real_y = (@real_y * @jump_count + @y * 128) / (@jump_count + 1)
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (移動)
  #--------------------------------------------------------------------------
  def update_move
    # 移動速度轉換為地圖座標系的移動距離
    distance = 2 ** @move_speed
    # 理論座標在實際座標下方的情況下
    if @y * 128 > @real_y
      # 向下移動
      @real_y = [@real_y + distance, @y * 128].min
    end
    # 理論座標在實際座標左方的情況下
    if @x * 128 < @real_x
      # 向左移動
      @real_x = [@real_x - distance, @x * 128].max
    end
    # 理論座標在實際座標右方的情況下
    if @x * 128 > @real_x
      # 向右移動
      @real_x = [@real_x + distance, @x * 128].min
    end
    # 理論座標在實際座標上方的情況下
    if @y * 128 < @real_y
      # 向上移動
      @real_y = [@real_y - distance, @y * 128].max
    end
    # 移動時動畫為 ON 的情況下
    if @walk_anime
      # 動畫計算數值增加 1.5
      @anime_count += 1.5
    # 移動時動畫為 OFF、停止時動畫為 ON 的情況下
    elsif @step_anime
      # 動畫計算數值增加 1
      @anime_count += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (停止)
  #--------------------------------------------------------------------------
  def update_stop
    # 停止時動畫為 ON 的情況下
    if @step_anime
      # 動畫計算數值增加 1
      @anime_count += 1
    # 停止時動畫為 OFF 並且、現在的圖像與原來的不同的情況下
    elsif @pattern != @original_pattern
      # 動畫計算數值增加 1.5
      @anime_count += 1.5
    end
    # 事件執行待機中並且不是鎖定狀態的情況下
    # ※鎖定處理並立刻停止執行中的事件
    unless @starting or lock?
      # 停止計算數值增加 1
      @stop_count += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 移動類型 : 隨機
  #--------------------------------------------------------------------------
  def move_type_random
    # 隨機 0～5 的分歧
    case rand(6)
    when 0..3  # 隨機
      move_random
    when 4  # 前進一步
      move_forward
    when 5  # 暫時停止
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 移動類型 : 接近
  #--------------------------------------------------------------------------
  def move_type_toward_player
    # 求得與主角座標的差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 求得差的絕對值
    abs_sx = sx > 0 ? sx : -sx
    abs_sy = sy > 0 ? sy : -sy
    # 如果20個元件平均分散在縱橫平面上
    if sx + sy >= 20
      # 隨機
      move_random
      return
    end
    # 隨機 0～5 的分歧
    case rand(6)
    when 0..3  # 接近主角
      move_toward_player
    when 4  # 隨機
      move_random
    when 5  # 前進一步
      move_forward
    end
  end
  #--------------------------------------------------------------------------
  # ● 移動類型 : 自定義
  #--------------------------------------------------------------------------
  def move_type_custom
    # 如果不是停止中就中斷
    if jumping? or moving?
      return
    end
    # 如果在移動指令列表最後結束還沒到達就循環執行
    while @move_route_index < @move_route.list.size
      # 取得移動指令
      command = @move_route.list[@move_route_index]
      # 指令編號 0 號 (列表最後) 的情況下
      if command.code == 0
        # 選項 [反覆動作] 為 ON 的情況下
        if @move_route.repeat
          # 還原為移動路線的最初索引
          @move_route_index = 0
        end
        # 選項 [反覆動作] 為 OFF 的情況下
        unless @move_route.repeat
          # 強制移動路線的場合
          if @move_route_forcing and not @move_route.repeat
            # 強制解除移動路線
            @move_route_forcing = false
            # 還原為原始的移動路線
            @move_route = @original_move_route
            @move_route_index = @original_move_route_index
            @original_move_route = nil
          end
          # 清除停止計算數值
          @stop_count = 0
        end
        return
      end
      # 移動系指令 (向下移動～跳躍) 的情況下
      if command.code <= 14
        # 命令編號分歧
        case command.code
        when 1  # 向下移動
          move_down
        when 2  # 向左移動
          move_left
        when 3  # 向右移動
          move_right
        when 4  # 向上移動
          move_up
        when 5  # 向左下移動
          move_lower_left
        when 6  # 向右下移動
          move_lower_right
        when 7  # 向左上移動
          move_upper_left
        when 8  # 向右上
          move_upper_right
        when 9  # 隨機移動
          move_random
        when 10  # 接近主角
          move_toward_player
        when 11  # 遠離主角
          move_away_from_player
        when 12  # 前進一步
          move_forward
        when 13  # 後退一步
          move_backward
        when 14  # 跳躍
          jump(command.parameters[0], command.parameters[1])
        end
        # 選項 [無視無法移動的情況] 為 OFF 、移動失敗的情況下
        if not @move_route.skippable and not moving? and not jumping?
          return
        end
        @move_route_index += 1
        return
      end
      # 等待的情況下
      if command.code == 15
        # 設定等待計算數值
        @wait_count = command.parameters[0] * 2 - 1
        @move_route_index += 1
        return
      end
      # 面向變更系指令的情況下
      if command.code >= 16 and command.code <= 26
        # 命令編號分歧
        case command.code
        when 16  # 面向下
          turn_down
        when 17  # 面向左
          turn_left
        when 18  # 面向右
          turn_right
        when 19  # 面向上
          turn_up
        when 20  # 向右轉 90 度
          turn_right_90
        when 21  # 向左轉 90 度
          turn_left_90
        when 22  # 旋轉 180 度
          turn_180
        when 23  # 從右向左轉 90 度
          turn_right_or_left_90
        when 24  # 隨機變換方向
          turn_random
        when 25  # 面向主角的方向
          turn_toward_player
        when 26  # 背向主角的方向
          turn_away_from_player
        end
        @move_route_index += 1
        return
      end
      # 其它指令的場合
      if command.code >= 27
        # 命令編號分歧
        case command.code
        when 27  # 開關 ON
          $game_switches[command.parameters[0]] = true
          $game_map.need_refresh = true
        when 28  # 開關 OFF
          $game_switches[command.parameters[0]] = false
          $game_map.need_refresh = true
        when 29  # 更改移動速度
          @move_speed = command.parameters[0]
        when 30  # 更改移動頻率
          @move_frequency = command.parameters[0]
        when 31  # 移動時動畫 ON
          @walk_anime = true
        when 32  # 移動時動畫 OFF
          @walk_anime = false
        when 33  # 停止時動畫 ON
          @step_anime = true
        when 34  # 停止時動畫 OFF
          @step_anime = false
        when 35  # 面向固定 ON
          @direction_fix = true
        when 36  # 面向固定 OFF
          @direction_fix = false
        when 37  # 穿越 ON
          @through = true
        when 38  # 穿越 OFF
          @through = false
        when 39  # 在最前面顯示 ON
          @always_on_top = true
        when 40  # 在最前面顯示 OFF
          @always_on_top = false
        when 41  # 更改圖形
          @tile_id = 0
          @character_name = command.parameters[0]
          @character_hue = command.parameters[1]
          if @original_direction != command.parameters[2]
            @direction = command.parameters[2]
            @original_direction = @direction
            @prelock_direction = 0
          end
          if @original_pattern != command.parameters[3]
            @pattern = command.parameters[3]
            @original_pattern = @pattern
          end
        when 42  # 不更改不透明度
          @opacity = command.parameters[0]
        when 43  # 更改合成方式
          @blend_type = command.parameters[0]
        when 44  # 演奏 SE
          $game_system.se_play(command.parameters[0])
        when 45  # 劇本
          result = eval(command.parameters[0])
        end
        @move_route_index += 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加步數
  #--------------------------------------------------------------------------
  def increase_steps
    # 清除停止步數
    @stop_count = 0
  end
end
