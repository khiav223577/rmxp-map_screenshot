#==============================================================================
# ■ Window_Command
#------------------------------------------------------------------------------
# 一般命令選擇行的視窗。
#==============================================================================

class Window_Command < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #     width    : 視窗的寬度
  #     commands : 命令字串序列
  #--------------------------------------------------------------------------
  def initialize(width, commands)
    # 由命令的個數計算出視窗的高度
    super(0, 0, width, commands.size * 32 + 32)
    @item_max = commands.size
    @commands = commands
    self.contents = Bitmap.new(width - 32, @item_max * 32)
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i, normal_color)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描繪項目
  #     index : 項目編號
  #     color : 文字色
  #--------------------------------------------------------------------------
  def draw_item(index, color)
    self.contents.font.color = color
    rect = Rect.new(4, 32 * index, self.contents.width - 8, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index])
  end
  #--------------------------------------------------------------------------
  # ● 項目無效化
  #     index : 項目編號
  #--------------------------------------------------------------------------
  def disable_item(index)
    draw_item(index, disabled_color)
  end
end
