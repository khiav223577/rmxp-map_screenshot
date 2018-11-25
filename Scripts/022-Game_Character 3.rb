#==============================================================================
# ■ Game_Character (第三部份)
#------------------------------------------------------------------------------
# 處理角色的類別。本類別作為 Game_Player 類別與 Game_Event 類別的總綱來使用。
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ● 向下移動
  #     turn_enabled : 本場地位置變更許可標誌
  #--------------------------------------------------------------------------
  def move_down(turn_enabled = true)
    # 面向下
    if turn_enabled
      turn_down
    end
    # 可以通行的場合
    if passable?(@x, @y, 2)
      # 面向下
      turn_down
      # 更新座標
      @y += 1
      # 增加步數
      increase_steps
    # 不能通行的情況下
    else
      # 接觸事件的啟動判斷
      check_event_trigger_touch(@x, @y+1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 向左移動
  #     turn_enabled : 本場地位置更改許可標誌
  #--------------------------------------------------------------------------
  def move_left(turn_enabled = true)
    # 面向左
    if turn_enabled
      turn_left
    end
    # 可以通行的情況下
    if passable?(@x, @y, 4)
      # 面向左
      turn_left
      # 更新座標
      @x -= 1
      # 增加步數
      increase_steps
    # 不能通行的情況下
    else
      # 接觸事件的啟動判斷
      check_event_trigger_touch(@x-1, @y)
    end
  end
  #--------------------------------------------------------------------------
  # ● 向右移動
  #     turn_enabled : 本場地位置更改許可標誌
  #--------------------------------------------------------------------------
  def move_right(turn_enabled = true)
    # 面向右
    if turn_enabled
      turn_right
    end
    # 可以通行的場合
    if passable?(@x, @y, 6)
      # 面向右
      turn_right
      # 更新座標
      @x += 1
      # 增加步數
      increase_steps
    # 不能通行的情況下
    else
      # 接觸事件的啟動判斷
      check_event_trigger_touch(@x+1, @y)
    end
  end
  #--------------------------------------------------------------------------
  # ● 向上移動
  #     turn_enabled : 本場地位置更改許可標誌
  #--------------------------------------------------------------------------
  def move_up(turn_enabled = true)
    # 面向上
    if turn_enabled
      turn_up
    end
    # 可以通行的情況下
    if passable?(@x, @y, 8)
      # 面向上
      turn_up
      # 更新座標
      @y -= 1
      # 增加步數
      increase_steps
    # 不能通行的情況下
    else
      # 接觸事件的啟動判斷
      check_event_trigger_touch(@x, @y-1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 向左下移動
  #--------------------------------------------------------------------------
  def move_lower_left
    # 沒有固定面向的場合
    unless @direction_fix
      # 面向是右的情況下適合的面是左面、面向是上的情況下適合的面是下面
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    # 下→左、左→下 的通道可以通行的情況下
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 2))
      # 更新座標
      @x -= 1
      @y += 1
      # 增加步數
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● 向右下移動
  #--------------------------------------------------------------------------
  def move_lower_right
    # 沒有固定面向的場合
    unless @direction_fix
      # 面向是右的情況下適合的面是左面、面向是上的情況下適合的面是下面
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    # 下→右、右→下 的通道可以通行的情況下
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 2))
      # 更新座標
      @x += 1
      @y += 1
      # 增加步數
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● 向左上移動
  #--------------------------------------------------------------------------
  def move_upper_left
    # 沒有固定面向的場合
    unless @direction_fix
      # 面向是右的情況下適合的面是左面、面向是上的情況下適合的面是下面
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    # 上→左、左→上 的通道可以通行的情況下
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 8))
      # 更新座標
      @x -= 1
      @y -= 1
      # 增加步數
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● 向右上移動
  #--------------------------------------------------------------------------
  def move_upper_right
    # 沒有固定面向的場合
    unless @direction_fix
      # 面向是右的情況下適合的面是左面、面向是上的情況下適合的面是下面
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    # 上→右、右→上 的通道可以通行的情況下
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 8))
      # 更新座標
      @x += 1
      @y -= 1
      # 增加步數
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● 隨機移動
  #--------------------------------------------------------------------------
  def move_random
    case rand(4)
    when 0  # 向下移動
      move_down(false)
    when 1  # 向左移動
      move_left(false)
    when 2  # 向右移動
      move_right(false)
    when 3  # 向上移動
      move_up(false)
    end
  end
  #--------------------------------------------------------------------------
  # ● 接近主角
  #--------------------------------------------------------------------------
  def move_toward_player
    # 求得與主角的座標差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 座標相等情況下
    if sx == 0 and sy == 0
      return
    end
    # 求得差的絕對值
    abs_sx = sx.abs
    abs_sy = sy.abs
    # 橫距離與縱距離相等的情況下
    if abs_sx == abs_sy
      # 隨機將邊數增加 1
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # 橫側距離長的情況下
    if abs_sx > abs_sy
      # 左右方向優先。向主角移動
      sx > 0 ? move_left : move_right
      if not moving? and sy != 0
        sy > 0 ? move_up : move_down
      end
    # 豎側距離長的情況下
    else
      # 上下方向優先。向主角移動
      sy > 0 ? move_up : move_down
      if not moving? and sx != 0
        sx > 0 ? move_left : move_right
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 遠離主角
  #--------------------------------------------------------------------------
  def move_away_from_player
    # 求得與主角的座標差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 座標相等情況下
    if sx == 0 and sy == 0
      return
    end
    # 求得差的絕對值
    abs_sx = sx.abs
    abs_sy = sy.abs
    # 橫距離與縱距離相等的情況下
    if abs_sx == abs_sy
      # 隨機將邊數增加 1
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # 橫側距離長的情況下
    if abs_sx > abs_sy
      # 左右方向優先。遠離主角移動
      sx > 0 ? move_right : move_left
      if not moving? and sy != 0
        sy > 0 ? move_down : move_up
      end
    # 豎側距離長的情況下
    else
      # 上下方向優先。遠離主角移動
      sy > 0 ? move_down : move_up
      if not moving? and sx != 0
        sx > 0 ? move_right : move_left
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 前進一步
  #--------------------------------------------------------------------------
  def move_forward
    case @direction
    when 2
      move_down(false)
    when 4
      move_left(false)
    when 6
      move_right(false)
    when 8
      move_up(false)
    end
  end
  #--------------------------------------------------------------------------
  # ● 後退一步
  #--------------------------------------------------------------------------
  def move_backward
    # 記憶面向固定訊息
    last_direction_fix = @direction_fix
    # 強制固定面向
    @direction_fix = true
    # 面向分支
    case @direction
    when 2  # 下
      move_up(false)
    when 4  # 左
      move_right(false)
    when 6  # 右
      move_left(false)
    when 8  # 上
      move_down(false)
    end
    # 還原面向固定訊息
    @direction_fix = last_direction_fix
  end
  #--------------------------------------------------------------------------
  # ● 跳躍
  #     x_plus : X 座標增加值
  #     y_plus : Y 座標增加值
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    # 增加值不是 (0,0) 的情況下
    if x_plus != 0 or y_plus != 0
      # 橫側距離長的情況下
      if x_plus.abs > y_plus.abs
        # 變更左右方向
        x_plus < 0 ? turn_left : turn_right
      # 豎側距離長的情況下
      else
        # 變更上下方向
        y_plus < 0 ? turn_up : turn_down
      end
    end
    # 計算新的座標
    new_x = @x + x_plus
    new_y = @y + y_plus
    # 增加值為 (0,0) 的情況下、跳躍目標可以通行的場合
    if (x_plus == 0 and y_plus == 0) or passable?(new_x, new_y, 0)
      # 矯正位置
      straighten
      # 更新座標
      @x = new_x
      @y = new_y
      # 距計算距離
      distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
      # 設定跳躍計算數值
      @jump_peak = 10 + distance - @move_speed
      @jump_count = @jump_peak * 2
      # 清除停止計算數值訊息
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 面向向下
  #--------------------------------------------------------------------------
  def turn_down
    unless @direction_fix
      @direction = 2
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 面向向左
  #--------------------------------------------------------------------------
  def turn_left
    unless @direction_fix
      @direction = 4
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 面向向右
  #--------------------------------------------------------------------------
  def turn_right
    unless @direction_fix
      @direction = 6
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 面向向上
  #--------------------------------------------------------------------------
  def turn_up
    unless @direction_fix
      @direction = 8
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 向右旋轉 90 度
  #--------------------------------------------------------------------------
  def turn_right_90
    case @direction
    when 2
      turn_left
    when 4
      turn_up
    when 6
      turn_down
    when 8
      turn_right
    end
  end
  #--------------------------------------------------------------------------
  # ● 向左旋轉 90 度
  #--------------------------------------------------------------------------
  def turn_left_90
    case @direction
    when 2
      turn_right
    when 4
      turn_down
    when 6
      turn_up
    when 8
      turn_left
    end
  end
  #--------------------------------------------------------------------------
  # ● 旋轉 180 度
  #--------------------------------------------------------------------------
  def turn_180
    case @direction
    when 2
      turn_up
    when 4
      turn_right
    when 6
      turn_left
    when 8
      turn_down
    end
  end
  #--------------------------------------------------------------------------
  # ● 從右向左旋轉 90 度
  #--------------------------------------------------------------------------
  def turn_right_or_left_90
    if rand(2) == 0
      turn_right_90
    else
      turn_left_90
    end
  end
  #--------------------------------------------------------------------------
  # ● 隨機變換方向
  #--------------------------------------------------------------------------
  def turn_random
    case rand(4)
    when 0
      turn_up
    when 1
      turn_right
    when 2
      turn_left
    when 3
      turn_down
    end
  end
  #--------------------------------------------------------------------------
  # ● 接近主角的方向
  #--------------------------------------------------------------------------
  def turn_toward_player
    # 求得與主角的座標差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 座標相等的場合下
    if sx == 0 and sy == 0
      return
    end
    # 橫側距離長的情況下
    if sx.abs > sy.abs
      # 將左右方向變更為面向主角的方向
      sx > 0 ? turn_left : turn_right
    # 豎側距離長的情況下
    else
      # 將上下方向變更為面向主角的方向
      sy > 0 ? turn_up : turn_down
    end
  end
  #--------------------------------------------------------------------------
  # ● 背向主角的方向
  #--------------------------------------------------------------------------
  def turn_away_from_player
    # 求得與主角的座標差
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 座標相等的場合下
    if sx == 0 and sy == 0
      return
    end
    # 橫側距離長的情況下
    if sx.abs > sy.abs
      # 將左右方向變更為背離主角的方向
      sx > 0 ? turn_right : turn_left
    # 豎側距離長的情況下
    else
      # 將上下方向變更為背離主角的方向
      sy > 0 ? turn_down : turn_up
    end
  end
end
