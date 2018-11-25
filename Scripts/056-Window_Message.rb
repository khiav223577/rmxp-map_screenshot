#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 顯示文字訊息的視窗。
#==============================================================================

class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化狀態
  #--------------------------------------------------------------------------
  def initialize
    super(80, 304, 480, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.visible = false
    self.z = 9998
    @fade_in = false
    @fade_out = false
    @contents_showing = false
    @cursor_width = 0
    self.active = false
    self.index = -1
  end
  #--------------------------------------------------------------------------
  # ● 釋放
  #--------------------------------------------------------------------------
  def dispose
    terminate_message
    $game_temp.message_window_showing = false
    if @input_number_window != nil
      @input_number_window.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 處理訊息結束
  #--------------------------------------------------------------------------
  def terminate_message
    self.active = false
    self.pause = false
    self.index = -1
    self.contents.clear
    # 清除顯示中標誌
    @contents_showing = false
    # 呼叫訊息取用
    if $game_temp.message_proc != nil
      $game_temp.message_proc.call
    end
    # 清除文字、選擇項目、輸入數值的相關變量
    $game_temp.message_text = nil
    $game_temp.message_proc = nil
    $game_temp.choice_start = 99
    $game_temp.choice_max = 0
    $game_temp.choice_cancel_type = 0
    $game_temp.choice_proc = nil
    $game_temp.num_input_start = 99
    $game_temp.num_input_variable_id = 0
    $game_temp.num_input_digits_max = 0
    # 釋放金錢視窗
    if @gold_window != nil
      @gold_window.dispose
      @gold_window = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    x = y = 0
    @cursor_width = 0
    # 到選擇項目的下一行字
    if $game_temp.choice_start == 0
      x = 8
    end
    # 有等待顯示文字的情況下
    if $game_temp.message_text != nil
      text = $game_temp.message_text
      # 限制文字處理
      begin
        last_text = text.clone
        text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
      end until text == last_text
      text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end
      # 為了方便、將 "\\\\" 變換為 "\000" 
      text.gsub!(/\\\\/) { "\000" }
      # "\\C" 變為 "\001" 、"\\G" 變為 "\002"
      text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      text.gsub!(/\\[Gg]/) { "\002" }
      # c 取得 1 個字 (如果不能取得文字就循環)
      while ((c = text.slice!(/./m)) != nil)
        # \\ 的情況下
        if c == "\000"
          # 還原為本來的文字
          c = "\\"
        end
        # \C[n] 的情況下
        if c == "\001"
          # 更改文字色
          text.sub!(/\[([0-9]+)\]/, "")
          color = $1.to_i
          if color >= 0 and color <= 7
            self.contents.font.color = text_color(color)
          end
          # 下面的文字
          next
        end
        # \G 的情況下
        if c == "\002"
          # 製作金錢視窗
          if @gold_window == nil
            @gold_window = Window_Gold.new
            @gold_window.x = 560 - @gold_window.width
            if $game_temp.in_battle
              @gold_window.y = 192
            else
              @gold_window.y = self.y >= 128 ? 32 : 384
            end
            @gold_window.opacity = self.opacity
            @gold_window.back_opacity = self.back_opacity
          end
          # 下面的文字
          next
        end
        # 另起一行文字的情況下
        if c == "\n"
          # 更新選擇項目及游標的高度
          if y >= $game_temp.choice_start
            @cursor_width = [@cursor_width, x].max
          end
          # y 加 1
          y += 1
          x = 0
          # 移動到選擇項目的下一行
          if y >= $game_temp.choice_start
            x = 8
          end
          # 下面的文字
          next
        end
        # 描繪文字
        self.contents.draw_text(4 + x, 32 * y, 40, 32, c)
        # x 為要描繪文字的加法運算
        x += self.contents.text_size(c).width
      end
    end
    # 選擇項目的情況
    if $game_temp.choice_max > 0
      @item_max = $game_temp.choice_max
      self.active = true
      self.index = 0
    end
    # 輸入數值的情況
    if $game_temp.num_input_variable_id > 0
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @input_number_window = Window_InputNumber.new(digits_max)
      @input_number_window.number = number
      @input_number_window.x = self.x + 8
      @input_number_window.y = self.y + $game_temp.num_input_start * 32
    end
  end
  #--------------------------------------------------------------------------
  # ● 設定視窗位置與不透明度
  #--------------------------------------------------------------------------
  def reset_window
    if $game_temp.in_battle
      self.y = 16
    else
      case $game_system.message_position
      when 0  # 上
        self.y = 16
      when 1  # 中
        self.y = 160
      when 2  # 下
        self.y = 304
      end
    end
    if $game_system.message_frame == 0
      self.opacity = 255
    else
      self.opacity = 0
    end
    self.back_opacity = 160
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    # 轉變的情況下
    if @fade_in
      self.contents_opacity += 24
      if @input_number_window != nil
        @input_number_window.contents_opacity += 24
      end
      if self.contents_opacity == 255
        @fade_in = false
      end
      return
    end
    # 輸入數值的情況下
    if @input_number_window != nil
      @input_number_window.update
      # 確定
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] =
          @input_number_window.number
        $game_map.need_refresh = true
        # 釋放輸入數值的視窗
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
      end
      return
    end
    # 顯示訊息中的情況下
    if @contents_showing
      # 如果不是在顯示選擇項目中就顯示暫停標誌
      if $game_temp.choice_max == 0
        self.pause = true
      end
      # 取消
      if Input.trigger?(Input::B)
        if $game_temp.choice_max > 0 and $game_temp.choice_cancel_type > 0
          $game_system.se_play($data_system.cancel_se)
          $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
          terminate_message
        end
      end
      # 確定
      if Input.trigger?(Input::C)
        if $game_temp.choice_max > 0
          $game_system.se_play($data_system.decision_se)
          $game_temp.choice_proc.call(self.index)
        end
        terminate_message
      end
      return
    end
    # 在轉變以外的狀態下有等待顯示的訊息與選擇項目的場合
    if @fade_out == false and $game_temp.message_text != nil
      @contents_showing = true
      $game_temp.message_window_showing = true
      reset_window
      refresh
      Graphics.frame_reset
      self.visible = true
      self.contents_opacity = 0
      if @input_number_window != nil
        @input_number_window.contents_opacity = 0
      end
      @fade_in = true
      return
    end
    # 沒有可以顯示的訊息、但是視窗為可見的情況下
    if self.visible
      @fade_out = true
      self.opacity -= 48
      if self.opacity == 0
        self.visible = false
        @fade_out = false
        $game_temp.message_window_showing = false
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新游標矩形
  #--------------------------------------------------------------------------
  def update_cursor_rect
    if @index >= 0
      n = $game_temp.choice_start + @index
      self.cursor_rect.set(8, n * 32, @cursor_width, 32)
    else
      self.cursor_rect.empty
    end
  end
end
