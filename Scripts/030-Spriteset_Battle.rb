#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
# 處理戰鬥畫面活動區塊的類別。本類別在 Scene_Battle 類別的內部使用。
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :viewport1                # 敵人方的顯示視口
  attr_reader   :viewport2                # 角色方的顯示視口
  #--------------------------------------------------------------------------
  # ● 初始化變量
  #--------------------------------------------------------------------------
  def initialize
    # 製作顯示視口
    @viewport1 = Viewport.new(0, 0, 640, 320)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport4 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 101
    @viewport3.z = 200
    @viewport4.z = 5000
    # 製作戰鬥背景活動區塊
    @battleback_sprite = Sprite.new(@viewport1)
    # 製作敵人活動區塊
    @enemy_sprites = []
    for enemy in $game_troop.enemies.reverse
      @enemy_sprites.push(Sprite_Battler.new(@viewport1, enemy))
    end
    # 製作敵人活動區塊
    @actor_sprites = []
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    @actor_sprites.push(Sprite_Battler.new(@viewport2))
    # 製作天候
    @weather = RPG::Weather.new(@viewport1)
    # 製作圖片活動區塊
    @picture_sprites = []
    for i in 51..100
      @picture_sprites.push(Sprite_Picture.new(@viewport3,
        $game_screen.pictures[i]))
    end
    # 製作計時器區塊
    @timer_sprite = Sprite_Timer.new
    # 更新畫面
    update
  end
  #--------------------------------------------------------------------------
  # ● 釋放所佔的記憶體空間
  #--------------------------------------------------------------------------
  def dispose
    # 如果戰鬥背景位圖存在的情況下就釋放所佔的記憶體空間
    if @battleback_sprite.bitmap != nil
      @battleback_sprite.bitmap.dispose
    end
    # 釋放戰鬥背景活動區塊所佔的記憶體空間
    @battleback_sprite.dispose
    # 釋放敵人活動區塊、角色活動區塊所佔的記憶體空間
    for sprite in @enemy_sprites + @actor_sprites
      sprite.dispose
    end
    # 釋放天候所佔的記憶體空間
    @weather.dispose
    # 釋放圖片活動區塊所佔的記憶體空間
    for sprite in @picture_sprites
      sprite.dispose
    end
    # 釋放計時器活動區塊所佔的記憶體空間
    @timer_sprite.dispose
    # 釋放顯示視口所佔的記憶體空間
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
    @viewport4.dispose
  end
  #--------------------------------------------------------------------------
  # ● 顯示效果中判斷
  #--------------------------------------------------------------------------
  def effect?
    # 如果是在顯示效果中的話就返回 true
    for sprite in @enemy_sprites + @actor_sprites
      return true if sprite.effect?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 更新角色的活動區塊 (對應角色的替換)
    @actor_sprites[0].battler = $game_party.actors[0]
    @actor_sprites[1].battler = $game_party.actors[1]
    @actor_sprites[2].battler = $game_party.actors[2]
    @actor_sprites[3].battler = $game_party.actors[3]
    # 戰鬥背景的文件名稱與現在情況有差異的情況下
    if @battleback_name != $game_temp.battleback_name
      @battleback_name = $game_temp.battleback_name
      if @battleback_sprite.bitmap != nil
        @battleback_sprite.bitmap.dispose
      end
      @battleback_sprite.bitmap = RPG::Cache.battleback(@battleback_name)
      @battleback_sprite.src_rect.set(0, 0, 640, 320)
    end
    # 更新戰鬥者的活動區塊
    for sprite in @enemy_sprites + @actor_sprites
      sprite.update
    end
    # 更新天氣圖像
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.update
    # 更新圖片活動區塊
    for sprite in @picture_sprites
      sprite.update
    end
    # 更新計時器活動區塊
    @timer_sprite.update
    # 設定畫面的色彩與震動位置
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    # 設定畫面的閃爍顏色
    @viewport4.color = $game_screen.flash_color
    # 更新顯示視口
    @viewport1.update
    @viewport2.update
    @viewport4.update
  end
end
