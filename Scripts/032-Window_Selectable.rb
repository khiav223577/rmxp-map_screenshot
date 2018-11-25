#==============================================================================
# ■ Window_Selectable
#------------------------------------------------------------------------------
# 擁有游標移動以及捲動功能的視窗類別。
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :index                    # 游標位置
  attr_reader   :help_window              # 提示視窗
  #--------------------------------------------------------------------------
  # ● 初始化對像
  #     x      : 視窗的 X 座標
  #     y      : 視窗的 Y 座標
  #     width  : 視窗的寬度
  #     height : 視窗的高度
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item_max = 1
    @column_max = 1
    @index = -1
  end
  #--------------------------------------------------------------------------
  # ● 設定游標的位置
  #     index : 新的游標位置
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    # 更新提示內容 (由 update_help 定義了繼承目標)
    if self.active and @help_window != nil
      update_help
    end
    # 更新游標矩形
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # ● 取得行數
  #--------------------------------------------------------------------------
  def row_max
    # 由項目數和列數計算出行數
    return (@item_max + @column_max - 1) / @column_max
  end
  #--------------------------------------------------------------------------
  # ● 取得開頭行
  #--------------------------------------------------------------------------
  def top_row
    # 將視窗內容的傳送源 Y 座標、1 行的高 32 等分
    return self.oy / 32
  end
  #--------------------------------------------------------------------------
  # ● 設定開頭行
  #     row : 顯示開頭的行
  #--------------------------------------------------------------------------
  def top_row=(row)
    # row 未滿 0 的場合更正為 0
    if row < 0
      row = 0
    end
    # row 超過 row_max - 1 的情況下更正為 row_max - 1 
    if row > row_max - 1
      row = row_max - 1
    end
    # row 1 行高的 32 倍、視窗內容的傳送源 Y 座標
    self.oy = row * 32
  end
  #--------------------------------------------------------------------------
  # ● 獲取 1 頁可以顯示的行數
  #--------------------------------------------------------------------------
  def page_row_max
    # 視窗的高度，設定畫面的高度減去 32 ，除以 1 行的高度 32 
    return (self.height - 32) / 32
  end
  #--------------------------------------------------------------------------
  # ● 獲取 1 頁可以顯示的項目數
  #--------------------------------------------------------------------------
  def page_item_max
    # 將行數 page_row_max 乘上列數 @column_max
    return page_row_max * @column_max
  end
  #--------------------------------------------------------------------------
  # ● 提示視窗的設定
  #     help_window : 新的提示視窗
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    # 更新提示文字 (由 update_help 定義了繼承的目標)
    if self.active and @help_window != nil
      update_help
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新游標矩形
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # 游標位置不滿 0 的情況下
    if @index < 0
      self.cursor_rect.empty
      return
    end
    # 取得當前的行
    row = @index / @column_max
    # 當前行被顯示開頭行前面的情況下
    if row < self.top_row
      # 從當前行向開頭行捲動
      self.top_row = row
    end
    # 當前行被顯示末尾行之後的情況下
    if row > self.top_row + (self.page_row_max - 1)
      # 從當前行向末尾捲動
      self.top_row = row - (self.page_row_max - 1)
    end
    # 計算游標的寬度
    cursor_width = self.width / @column_max - 32
    # 計算游標座標
    x = @index % @column_max * (cursor_width + 32)
    y = @index / @column_max * 32 - self.oy
    # 更新游標矩形
    self.cursor_rect.set(x, y, cursor_width, 32)
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    # 可以移動光標的情況下
    if self.active and @item_max > 0 and @index >= 0
      # 方向鍵下被按下的情況下
      if Input.repeat?(Input::DOWN)
        # 列數不是 1 並且方向鍵的下的按下狀態不是重複的情況、
        # 或游標位置在(項目數-列數)之前的情況下
        if (@column_max == 1 and Input.trigger?(Input::DOWN)) or
           @index < @item_max - @column_max
          # 游標向下移動
          $game_system.se_play($data_system.cursor_se)
          @index = (@index + @column_max) % @item_max
        end
      end
      # 方向鍵上被按下的情況下
      if Input.repeat?(Input::UP)
        # 列數不是 1 並且方向鍵的下的按下狀態不是重複的情況、
        # 或游標位置在列之後的情況下
        if (@column_max == 1 and Input.trigger?(Input::UP)) or
           @index >= @column_max
          # 游標向上移動
          $game_system.se_play($data_system.cursor_se)
          @index = (@index - @column_max + @item_max) % @item_max
        end
      end
      # 方向鍵右被按下的情況下
      if Input.repeat?(Input::RIGHT)
        # 列數為 2 以上並且、游標位置在(項目數 - 1)之前的情況下
        if @column_max >= 2 and @index < @item_max - 1
          # 游標向右移動
          $game_system.se_play($data_system.cursor_se)
          @index += 1
        end
      end
      # 方向鍵左被按下的情況下
      if Input.repeat?(Input::LEFT)
        # 列數為 2 以上並且、游標位置在 0 之後的情況下
        if @column_max >= 2 and @index > 0
          # 游標向左移動
          $game_system.se_play($data_system.cursor_se)
          @index -= 1
        end
      end
      # R 鍵被按下的情況下
      if Input.repeat?(Input::R)
        # 顯示的最後行在資料中最後行上方的情況下
        if self.top_row + (self.page_row_max - 1) < (self.row_max - 1)
          # 游標向後移動一頁
          $game_system.se_play($data_system.cursor_se)
          @index = [@index + self.page_item_max, @item_max - 1].min
          self.top_row += self.page_row_max
        end
      end
      # L 鍵被按下的情況下
      if Input.repeat?(Input::L)
        # 顯示的開頭行在位置 0 之後的情況下
        if self.top_row > 0
          # 游標向前移動一頁
          $game_system.se_play($data_system.cursor_se)
          @index = [@index - self.page_item_max, 0].max
          self.top_row -= self.page_row_max
        end
      end
    end
    # 更新提示文字 (由 update_help 定義了繼承的目標)
    if self.active and @help_window != nil
      update_help
    end
    # 更新游標矩形
    update_cursor_rect
  end
end
