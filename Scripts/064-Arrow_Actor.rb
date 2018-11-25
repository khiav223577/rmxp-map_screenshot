#==============================================================================
# ■ Arrow_Actor
#------------------------------------------------------------------------------
# 選擇角色的箭頭游標。本類別由 Arrow_Base 類別取得。
#==============================================================================

class Arrow_Actor < Arrow_Base
  #--------------------------------------------------------------------------
  # ● 取得游標指定的角色
  #--------------------------------------------------------------------------
  def actor
    return $game_party.actors[@index]
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    # 游標右鍵
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      @index += 1
      @index %= $game_party.actors.size
    end
    # 游標左鍵
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      @index += $game_party.actors.size - 1
      @index %= $game_party.actors.size
    end
    # 設定活動區塊座標
    if self.actor != nil
      self.x = self.actor.screen_x
      self.y = self.actor.screen_y
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新提示內容
  #--------------------------------------------------------------------------
  def update_help
    # 顯示角色狀態的提示視窗
    @help_window.set_actor(self.actor)
  end
end
