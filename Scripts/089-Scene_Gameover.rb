#==============================================================================
# ■ Scene_Gameover
#------------------------------------------------------------------------------
# 處理遊戲結束畫面的類別。
#==============================================================================

class Scene_Gameover
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 製作遊戲結束圖形
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.gameover($data_system.gameover_name)
    # 停止 BGM、BGS
    $game_system.bgm_play(nil)
    $game_system.bgs_play(nil)
    # 演奏遊戲結束 ME
    $game_system.me_play($data_system.gameover_me)
    # 執行轉變
    Graphics.transition(120)
    # 主循環
    loop do
      # 更新遊戲畫面
      Graphics.update
      # 更新輸入訊息
      Input.update
      # 更新畫面情報
      update
      # 如果畫面被切換的話就中斷循環
      if $scene != self
        break
      end
    end
    # 準備轉變
    Graphics.freeze
    # 釋放遊戲結束圖形
    @sprite.bitmap.dispose
    @sprite.dispose
    # 執行轉變
    Graphics.transition(40)
    # 準備轉變
    Graphics.freeze
    # 戰鬥測試的情況下
    if $BTEST
      $scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 切換到標題畫面
      $scene = Scene_Title.new
    end
  end
end
