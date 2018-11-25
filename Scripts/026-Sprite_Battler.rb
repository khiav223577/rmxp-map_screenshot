#==============================================================================
# ■ Sprite_Battler
#------------------------------------------------------------------------------
# 戰鬥顯示用活動區塊。監視 Game_Battler 類別的實例及活動區塊的狀態。
#==============================================================================

class Sprite_Battler < RPG::Sprite
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_accessor :battler                  # 戰鬥者
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #     viewport : 顯示視口
  #     battler  : 戰鬥者 (Game_Battler)
  #--------------------------------------------------------------------------
  def initialize(viewport, battler = nil)
    super(viewport)
    @battler = battler
    @battler_visible = false
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
    # 戰鬥者為 nil 的情況下
    if @battler == nil
      self.bitmap = nil
      loop_animation(nil)
      return
    end
    # 文件名稱和色相與當前情況有差異的情況下
    if @battler.battler_name != @battler_name or
       @battler.battler_hue != @battler_hue
      # 取得並設定位圖
      @battler_name = @battler.battler_name
      @battler_hue = @battler.battler_hue
      self.bitmap = RPG::Cache.battler(@battler_name, @battler_hue)
      @width = bitmap.width
      @height = bitmap.height
      self.ox = @width / 2
      self.oy = @height
      # 如果是戰鬥不能或者是隱藏狀態就把透明度設定成 0
      if @battler.dead? or @battler.hidden
        self.opacity = 0
      end
    end
    # 動畫 ID 與當前的情況有差異的情況下
    if @battler.damage == nil and
       @battler.state_animation_id != @state_animation_id
      @state_animation_id = @battler.state_animation_id
      loop_animation($data_animations[@state_animation_id])
    end
    # 應該被顯示的角色的情況下
    if @battler.is_a?(Game_Actor) and @battler_visible
      # 不是主狀態的時候稍稍降低點透明度
      if $game_temp.battle_main_phase
        self.opacity += 3 if self.opacity < 255
      else
        self.opacity -= 3 if self.opacity > 207
      end
    end
    # 明暗
    if @battler.blink
      blink_on
    else
      blink_off
    end
    # 不可見的情況下
    unless @battler_visible
      # 出現
      if not @battler.hidden and not @battler.dead? and
         (@battler.damage == nil or @battler.damage_pop)
        appear
        @battler_visible = true
      end
    end
    # 可見的情況下
    if @battler_visible
      # 逃跑
      if @battler.hidden
        $game_system.se_play($data_system.escape_se)
        escape
        @battler_visible = false
      end
      # 白色閃爍
      if @battler.white_flash
        whiten
        @battler.white_flash = false
      end
      # 動畫
      if @battler.animation_id != 0
        animation = $data_animations[@battler.animation_id]
        animation(animation, @battler.animation_hit)
        @battler.animation_id = 0
      end
      # 傷害
      if @battler.damage_pop
        damage(@battler.damage, @battler.critical)
        @battler.damage = nil
        @battler.critical = false
        @battler.damage_pop = false
      end
      # korapusu
      if @battler.damage == nil and @battler.dead?
        if @battler.is_a?(Game_Enemy)
          $game_system.se_play($data_system.enemy_collapse_se)
        else
          $game_system.se_play($data_system.actor_collapse_se)
        end
        collapse
        @battler_visible = false
      end
    end
    # 設定活動區塊的座標
    self.x = @battler.screen_x
    self.y = @battler.screen_y
    self.z = @battler.screen_z
  end
end
