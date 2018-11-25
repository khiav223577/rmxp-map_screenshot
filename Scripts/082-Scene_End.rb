#==============================================================================
# ■ Scene_End
#------------------------------------------------------------------------------
# 處理遊戲結束畫面的類別。
#==============================================================================

class Scene_End
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 製作命令視窗
    s1 = "返回標題畫面"
    s2 = "退出"
    s3 = "取消"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 240 - @command_window.height / 2
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
      # 如果畫面切換的話就中斷循環
      if $scene != self
        break
      end
    end
    # 準備轉變
    Graphics.freeze
    # 釋放視窗
    @command_window.dispose
    # 如果在標題畫面切換中的情況下
    if $scene.is_a?(Scene_Title)
      # 淡入淡出畫面
      Graphics.transition
      Graphics.freeze
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 更新命令視窗
    @command_window.update
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切換到選單畫面
      $scene = Scene_Menu.new(5)
      return
    end
    # 按下C鍵的場合下
    if Input.trigger?(Input::C)
      # 命令視窗游標位置分歧
      case @command_window.index
      when 0  # 返回標題畫面
        command_to_title
      when 1  # 退出
        command_shutdown
      when 2  # 取消
        command_cancel
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 選擇命令[返回標題畫面]時的處理
  #--------------------------------------------------------------------------
  def command_to_title
    # 演奏確定 SE
    $game_system.se_play($data_system.decision_se)
    # 淡入淡出 BGM、BGS、ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 切換到標題畫面
    $scene = Scene_Title.new
  end
  #--------------------------------------------------------------------------
  # ● 選擇命令[退出]時的處理
  #--------------------------------------------------------------------------
  def command_shutdown
    # 演奏確定 SE
    $game_system.se_play($data_system.decision_se)
    # 淡入淡出 BGM、BGS、ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 退出
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # ● 選擇命令[取消]時的處理
  #--------------------------------------------------------------------------
  def command_cancel
    # 演奏確定 SE
    $game_system.se_play($data_system.decision_se)
    # 切換到選單畫面
    $scene = Scene_Menu.new(5)
  end
end
