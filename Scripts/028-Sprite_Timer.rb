#==============================================================================
# ■ Sprite_Timer
#------------------------------------------------------------------------------
# 顯示計時器用的活動區塊。監視 $game_system、活動區塊狀態的自動變化。
#==============================================================================

class Sprite_Timer < Sprite
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #--------------------------------------------------------------------------
  def initialize
    super
    self.bitmap = Bitmap.new(88, 48)
    self.bitmap.font.name = "Arial"
    self.bitmap.font.size = 32
    self.x = 640 - self.bitmap.width
    self.y = 0
    self.z = 500
    update
  end
  #--------------------------------------------------------------------------
  # ● 釋放所佔的記憶體空間
  #--------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    # 設定計時器執行中為可見
    self.visible = $game_system.timer_working
    # 如果有必要就再次描繪計時器
    if $game_system.timer / Graphics.frame_rate != @total_sec
      # 清除視窗內容
      self.bitmap.clear
      # 計算總計秒數
      @total_sec = $game_system.timer / Graphics.frame_rate
      # 製作計時器顯示用字串
      min = @total_sec / 60
      sec = @total_sec % 60
      text = sprintf("%02d:%02d", min, sec)
      # 描繪計時器
      self.bitmap.font.color.set(255, 255, 255)
      self.bitmap.draw_text(self.bitmap.rect, text, 1)
    end
  end
end
