#==============================================================================
# ■ Scene_Debug
#------------------------------------------------------------------------------
# 處理除錯畫面的類別。
#==============================================================================

class Scene_Debug
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 製作視窗
    @left_window = Window_DebugLeft.new
    @right_window = Window_DebugRight.new
    @help_window = Window_Base.new(192, 352, 448, 128)
    @help_window.contents = Bitmap.new(406, 96)
    # 還原為上次選擇的項目
    @left_window.top_row = $game_temp.debug_top_row
    @left_window.index = $game_temp.debug_index
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    # 執行轉變
    Graphics.transition
    # 主循環
    loop do
      # 更新遊戲畫面
      Graphics.update
      # 更新輸入情報
      Input.update
      # 更新畫面
      update
      # 如果畫面被切換的話就中斷循環
      if $scene != self
        break
      end
    end
    # 更新地圖
    $game_map.refresh
    # 裝備轉變
    Graphics.freeze
    # 釋放視窗
    @left_window.dispose
    @right_window.dispose
    @help_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 更新視窗
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    @left_window.update
    @right_window.update
    # 記憶選擇中的項目
    $game_temp.debug_top_row = @left_window.top_row
    $game_temp.debug_index = @left_window.index
    # 左側視窗被更新的情況下: 取用 update_left
    if @left_window.active
      update_left
      return
    end
    # 右側視窗被更新的情況下: 取用 update_right
    if @right_window.active
      update_right
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (左側視窗被更新的情況下)
  #--------------------------------------------------------------------------
  def update_left
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切換到地圖畫面
      $scene = Scene_Map.new
      return
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 顯示提示
      if @left_window.mode == 0
        text1 = "C (Enter) : ON / OFF"
        @help_window.contents.draw_text(4, 0, 406, 32, text1)
      else
        text1 = "← : -1   → : +1"
        text2 = "L (Pageup) : -10"
        text3 = "R (Pagedown) : +10"
        @help_window.contents.draw_text(4, 0, 406, 32, text1)
        @help_window.contents.draw_text(4, 32, 406, 32, text2)
        @help_window.contents.draw_text(4, 64, 406, 32, text3)
      end
      # 更新右側視窗
      @left_window.active = false
      @right_window.active = true
      @right_window.index = 0
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (右側視窗被更新的情況下)
  #--------------------------------------------------------------------------
  def update_right
    # 按下 B 鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 更新左側視窗
      @left_window.active = true
      @right_window.active = false
      @right_window.index = -1
      # 刪除提示
      @help_window.contents.clear
      return
    end
    # 取得被選擇的開關 / 變數的 ID
    current_id = @right_window.top_id + @right_window.index
    # 開關的情況下
    if @right_window.mode == 0
      # 按下C鍵的情況下
      if Input.trigger?(Input::C)
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 變更 ON / OFF 狀態
        $game_switches[current_id] = (not $game_switches[current_id])
        @right_window.refresh
        return
      end
    end
    # 變數的情況下
    if @right_window.mode == 1
      # 按下右鍵的情況下
      if Input.repeat?(Input::RIGHT)
        # 演奏游標 SE
        $game_system.se_play($data_system.cursor_se)
        # 變數加1
        $game_variables[current_id] += 1
        # 檢查上限
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      # 按下左鍵的情況下
      if Input.repeat?(Input::LEFT)
        # 演奏游標 SE
        $game_system.se_play($data_system.cursor_se)
        # 變數減1
        $game_variables[current_id] -= 1
        # 檢查下限
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
      # 按下R鍵的情況下
      if Input.repeat?(Input::R)
        # 演奏游標 SE
        $game_system.se_play($data_system.cursor_se)
        # 變數加10
        $game_variables[current_id] += 10
        # 檢查上限
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      # 按下L鍵的情況下
      if Input.repeat?(Input::L)
        # 演奏游標 SE
        $game_system.se_play($data_system.cursor_se)
        # 變數減10
        $game_variables[current_id] -= 10
        # 檢查下限
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
    end
  end
end
