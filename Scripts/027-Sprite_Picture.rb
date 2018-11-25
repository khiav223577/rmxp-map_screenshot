#==============================================================================
# ■ Sprite_Picture
#------------------------------------------------------------------------------
# 顯示圖片用的活動區塊。Game_Picture 類別的實例監視及活動區塊狀態的自動變化。
#==============================================================================

class Sprite_Picture < Sprite
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #     viewport : 顯示端口
  #     picture  : 圖片 (Game_Picture)
  #--------------------------------------------------------------------------
  def initialize(viewport, picture)
    super(viewport)
    @picture = picture
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
    # 圖片的文件名稱與當前的情況有差異的情況下
    if @picture_name != @picture.name
      # 將文件名稱記憶到實例變量
      @picture_name = @picture.name
      # 文件名稱不為空的情況下
      if @picture_name != ""
        # 取得圖片圖像
        self.bitmap = RPG::Cache.picture(@picture_name)
      end
    end
    # 文件名稱是空的情況下
    if @picture_name == ""
      # 將活動區塊設定為不可見
      self.visible = false
      return
    end
    # 將活動塊設定為可見
    self.visible = true
    # 設定傳送原點
    if @picture.origin == 0
      self.ox = 0
      self.oy = 0
    else
      self.ox = self.bitmap.width / 2
      self.oy = self.bitmap.height / 2
    end
    # 設定活動區塊的座標
    self.x = @picture.x
    self.y = @picture.y
    self.z = @picture.number
    # 設定放大率、不透明度、合成方式
    self.zoom_x = @picture.zoom_x / 100.0
    self.zoom_y = @picture.zoom_y / 100.0
    self.opacity = @picture.opacity
    self.blend_type = @picture.blend_type
    # 設定旋轉角度、色彩
    self.angle = @picture.angle
    self.tone = @picture.tone
  end
end
