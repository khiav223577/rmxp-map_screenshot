#==============================================================================
# ■ Scene_File
#------------------------------------------------------------------------------
# 存檔畫面及讀檔畫面的超級類別。
#==============================================================================

class Scene_File
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #     help_text : 提示視窗顯示的字串
  #--------------------------------------------------------------------------
  def initialize(help_text)
    @help_text = help_text
  end
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 製作提示視窗
    @help_window = Window_Help.new
    @help_window.set_text(@help_text)
    # 製作存檔文件視窗
    @savefile_windows = []
    for i in 0..3
      @savefile_windows.push(Window_SaveFile.new(i, make_filename(i)))
    end
    # 選擇最後操作的文件
    @file_index = $game_temp.last_file_index
    @savefile_windows[@file_index].selected = true
    # 執行轉變
    Graphics.transition
    # 主循環
    loop do
      # 更新遊戲畫面
      Graphics.update
      # 更新輸入訊息
      Input.update
      # 更新畫面
      update
      # 如果畫面被切換的話就中斷循環
      if $scene != self
        break
      end
    end
    # 準備轉變
    Graphics.freeze
    # 釋放視窗
    @help_window.dispose
    for i in @savefile_windows
      i.dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 更新視窗
    @help_window.update
    for i in @savefile_windows
      i.update
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 取用過程：on_decision (由亞綱定義)
      on_decision(make_filename(@file_index))
      $game_temp.last_file_index = @file_index
      return
    end
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 取用過程：on_cancel (由亞綱定義)
      on_cancel
      return
    end
    # 按下方向鍵下的情況下
    if Input.repeat?(Input::DOWN)
      # 按下方向鍵下的狀態且不是重複按的情況下、
      # 或者游標的位置在3之前的情況下
      if Input.trigger?(Input::DOWN) or @file_index < 3
        # 演奏游標 SE
        $game_system.se_play($data_system.cursor_se)
        # 游標向下移動
        @savefile_windows[@file_index].selected = false
        @file_index = (@file_index + 1) % 4
        @savefile_windows[@file_index].selected = true
        return
      end
    end
    # 按下方向鍵上的情況下
    if Input.repeat?(Input::UP)
      # 按下方向鍵上的狀態且不是重複按的情況下、
      # 或者游標的位置在0之後的情況下
      if Input.trigger?(Input::UP) or @file_index > 0
        # 演奏游標 SE
        $game_system.se_play($data_system.cursor_se)
        # 游標向上移動
        @savefile_windows[@file_index].selected = false
        @file_index = (@file_index + 3) % 4
        @savefile_windows[@file_index].selected = true
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 製作文件名稱
  #     file_index : 文件名稱的索引 (0～3)
  #--------------------------------------------------------------------------
  def make_filename(file_index)
    return "Save#{file_index + 1}.rxdata"
  end
end
