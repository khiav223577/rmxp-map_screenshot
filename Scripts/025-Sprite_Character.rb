#==============================================================================
# ■ Sprite_Character
#------------------------------------------------------------------------------
# 角色顯示用劇本。監視 Game_Character 類別的實例及自動變化劇本狀態。
#==============================================================================

class Sprite_Character < RPG::Sprite
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_accessor :character                # 角色
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #     viewport  : 查看視口
  #     character : 角色 (Game_Character)
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    update
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    # 元件 ID、文件名稱、色相與現在的情況存在差異的情況下
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_hue != @character.character_hue
      # 記憶元件 ID 與文件名稱、色相
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      # 元件 ID 為有效值的情況下
      if @tile_id >= 384
        self.bitmap = RPG::Cache.tile($game_map.tileset_name,
          @tile_id, @character.character_hue)
        self.src_rect.set(0, 0, 32, 32)
        self.ox = 16
        self.oy = 32
      # 元件 ID 為無效值的情況下
      else
        hue = @character.character_hue
        name = @character.character_name
        begin
          self.bitmap = RPG::Cache.character(name, hue)
        rescue Errno::ENOENT
          self.bitmap = RPG::Cache.character('', hue)
        end
        @cw = bitmap.width / $pic_pattern_max[name]
        @ch = bitmap.height / $pic_dir_max[name]
        self.ox = @cw / 2
        self.oy = @ch
      end
    end
    # 設定可視狀態
    self.visible = (not @character.transparent)
    # 圖形是角色的情況下
    if @tile_id == 0
      # 設定傳送目標的矩形
      sx = @character.pattern * @cw
      sy = (@character.direction - 2) / 2 * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
    # 設定劇本的座標
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z(@ch)
    # 設定不透明度、合成方式、草木繁茂處
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    # 動畫
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end
