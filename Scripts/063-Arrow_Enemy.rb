#==============================================================================
# ■ Arrow_Enemy
#------------------------------------------------------------------------------
# 選擇敵人的箭頭游標。本類別由 Arrow_Base 類別取得。
#==============================================================================

class Arrow_Enemy < Arrow_Base
  #--------------------------------------------------------------------------
  # ● 取得游標指定的敵人
  #--------------------------------------------------------------------------
  def enemy
    return $game_troop.enemies[@index]
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    # 如果指定的敵人不存在就離開
    $game_troop.enemies.size.times do
      break if self.enemy.exist?
      @index += 1
      @index %= $game_troop.enemies.size
    end
    # 游標右鍵
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index += 1
        @index %= $game_troop.enemies.size
        break if self.enemy.exist?
      end
    end
    # 游標左鍵
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index += $game_troop.enemies.size - 1
        @index %= $game_troop.enemies.size
        break if self.enemy.exist?
      end
    end
    # 設定活動區塊座標
    if self.enemy != nil
      self.x = self.enemy.screen_x
      self.y = self.enemy.screen_y
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新提示內容
  #--------------------------------------------------------------------------
  def update_help
    # 顯示敵人名字與狀態的提示視窗
    @help_window.set_enemy(self.enemy)
  end
end
