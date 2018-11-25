#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 特技、物品的說明及角色狀態顯示的視窗。
#==============================================================================

class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 640, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
  end
  #--------------------------------------------------------------------------
  # ● 設定內容
  #     text  : 視窗顯示的字串
  #     align : 對齊方式 (0..左對齊、1..中間對齊、2..右對齊)
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    # 如果文本和對齊方式的至少一方與上次的不同
    if text != @text or align != @align
      # 再描繪文本
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 40, 32, text, align)
      @text = text
      @align = align
      @actor = nil
    end
    self.visible = true
  end
  #--------------------------------------------------------------------------
  # ● 設定角色
  #     actor : 要顯示狀態的角色
  #--------------------------------------------------------------------------
  def set_actor(actor)
    if actor != @actor
      self.contents.clear
      draw_actor_name(actor, 4, 0)
      draw_actor_state(actor, 140, 0)
      draw_actor_hp(actor, 284, 0)
      draw_actor_sp(actor, 460, 0)
      @actor = actor
      @text = nil
      self.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 設定敵人
  #     enemy : 要顯示名字和狀態的敵人
  #--------------------------------------------------------------------------
  def set_enemy(enemy)
    text = enemy.name
    state_text = make_battler_state_text(enemy, 112, false)
    if state_text != ""
      text += "  " + state_text
    end
    set_text(text, 1)
  end
end
