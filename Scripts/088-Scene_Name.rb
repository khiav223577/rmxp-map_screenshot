#==============================================================================
# ■ Scene_Name
#------------------------------------------------------------------------------
# 處理名稱輸入畫面的類別。
#==============================================================================

class Scene_Name
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 取得角色
    @actor = $game_actors[$game_temp.name_actor_id]
    # 製作視窗
    @edit_window = Window_NameEdit.new(@actor, $game_temp.name_max_char)
    @input_window = Window_NameInput.new
    # 執行過渡
    Graphics.transition
    # 主循環
    loop do
      # 更新遊戲畫面
      Graphics.update
      # 更新輸入訊息
      Input.update
      # 更新畫面
      update
      # 如果畫面切換就中斷循環
      if $scene != self
        break
      end
    end
    # 準備過渡
    Graphics.freeze
    # 釋放視窗所佔的記憶體空間
    @edit_window.dispose
    @input_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 更新視窗
    @edit_window.update
    @input_window.update
    # 按下 B 鍵的情況下
    if Input.repeat?(Input::B)
      # 游標位置為 0 的情況下
      if @edit_window.index == 0
        return
      end
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 刪除文字
      @edit_window.back
      return
    end
    # 按下 C 鍵的情況下
    if Input.trigger?(Input::C)
      # 光標位置為 [確定] 的情況下
      if @input_window.character == nil
        # 名稱為空的情況下
        if @edit_window.name == ""
          # 還原為預設名稱
          @edit_window.restore_default
          # 名稱為空的情況下
          if @edit_window.name == ""
            # 演奏凍結 SE
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          # 演奏確定 SE
          $game_system.se_play($data_system.decision_se)
          return
        end
        # 更改角色名稱
        @actor.name = @edit_window.name
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 切換到地圖畫面
        $scene = Scene_Map.new
        return
      end
      # 游標位置為最大的情況下
      if @edit_window.index == $game_temp.name_max_char
        # 演奏凍結 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 文字為空的情況下
      if @input_window.character == ""
        # 演奏凍結 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 添加文字
      @edit_window.add(@input_window.character)
      return
    end
  end
end
