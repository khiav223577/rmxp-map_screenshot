#==============================================================================
# ■ Scene_Status
#------------------------------------------------------------------------------
# 處理狀態畫面的類別。
#==============================================================================

class Scene_Status
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #     actor_index : 角色索引
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 取得角色
    @actor = $game_party.actors[@actor_index]
    # 製作狀態視窗
    @status_window = Window_Status.new(@actor)
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
      # 如果畫面被切換的話就中斷循環
      if $scene != self
        break
      end
    end
    # 準備過渡
    Graphics.freeze
    # 釋放視窗所佔的記憶體空間
    @status_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 按下 B 鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切換到選單畫面
      $scene = Scene_Menu.new(3)
      return
    end
    # 按下 R 鍵的情況下
    if Input.trigger?(Input::R)
      # 演奏游標 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至下一位角色
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # 切換到別的狀態畫面
      $scene = Scene_Status.new(@actor_index)
      return
    end
    # 按下 L 鍵的情況下
    if Input.trigger?(Input::L)
      # 演奏游標 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至上一位角色
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # 切換到別的狀態畫面
      $scene = Scene_Status.new(@actor_index)
      return
    end
  end
end
