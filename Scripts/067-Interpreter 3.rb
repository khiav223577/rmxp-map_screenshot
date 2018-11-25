#==============================================================================
# ■ Interpreter (第三部份)
#------------------------------------------------------------------------------
# 執行事件指令的解釋器。使用在 Game_System 類別和 Game_Event 類別的內部。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 顯示文字
  #--------------------------------------------------------------------------
  def command_101
    # 另外的文字已經設定過 message_text 的情況下
    if $game_temp.message_text != nil
      # 結束
      return false
    end
    # 設定訊息結束後待機和返回取用標誌
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # message_text 設定為 1 行
    $game_temp.message_text = @list[@index].parameters[0] + "\n"
    line_count = 1
    # 循環
    loop do
      # 下一個事件指令為文字兩行以上的情況
      if @list[@index+1].code == 401
        # message_text 添加到第 2 行以下
        $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
        line_count += 1
      # 事件指令不在文字兩行以下的情況
      else
        # 下一個事件指令為顯示選擇項目的情況下
        if @list[@index+1].code == 102
          # 如果選擇項目能收納在畫面裡
          if @list[@index+1].parameters[0].size <= 4 - line_count
            # 推進索引
            @index += 1
            # 設定選擇項目
            $game_temp.choice_start = line_count
            setup_choices(@list[@index].parameters)
          end
        # 下一個事件指令為處理輸入數值的情況下
        elsif @list[@index+1].code == 103
          # 如果數值輸入視窗能收納在畫面裡
          if line_count < 4
            # 推進索引
            @index += 1
            # 設定輸入數值
            $game_temp.num_input_start = line_count
            $game_temp.num_input_variable_id = @list[@index].parameters[0]
            $game_temp.num_input_digits_max = @list[@index].parameters[1]
          end
        end
        # 繼續
        return true
      end
      # 推進索引
      @index += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 顯示選擇項目
  #--------------------------------------------------------------------------
  def command_102
    # 文字已經設定過 message_text 的情況下
    if $game_temp.message_text != nil
      # 結束
      return false
    end
    # 設定訊息結束後待機和返回取用標誌
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # 設定選擇項目
    $game_temp.message_text = ""
    $game_temp.choice_start = 0
    setup_choices(@parameters)
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● [**] 的情況下
  #--------------------------------------------------------------------------
  def command_402
    # 如果符合的選擇項目被選擇
    if @branch[@list[@index].indent] == @parameters[0]
      # 刪除分歧資料
      @branch.delete(@list[@index].indent)
      # 繼續
      return true
    end
    # 不符合條件的情況下 : 指令跳轉
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 取消的情況下
  #--------------------------------------------------------------------------
  def command_403
    # 如果選擇了選擇項目取消
    if @branch[@list[@index].indent] == 4
      # 刪除分歧資料
      @branch.delete(@list[@index].indent)
      # 繼續
      return true
    end
    # 不符合條件的情況下 : 指令跳轉
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 處理數值輸入
  #--------------------------------------------------------------------------
  def command_103
    # 文字已經設定過 message_text 的情況下
    if $game_temp.message_text != nil
      # 結束
      return false
    end
    # 設定訊息結束後待機和返回取用標誌
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # 設定數值輸入
    $game_temp.message_text = ""
    $game_temp.num_input_start = 0
    $game_temp.num_input_variable_id = @parameters[0]
    $game_temp.num_input_digits_max = @parameters[1]
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 更改文字選項
  #--------------------------------------------------------------------------
  def command_104
    # 正在顯示訊息的情況下
    if $game_temp.message_window_showing
      # 結束
      return false
    end
    # 更改各個選項
    $game_system.message_position = @parameters[0]
    $game_system.message_frame = @parameters[1]
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 處理按鍵輸入
  #--------------------------------------------------------------------------
  def command_105
    # 設定按鍵輸入用變數 ID
    @button_input_variable_id = @parameters[0]
    # 推進索引
    @index += 1
    # 結束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 等待
  #--------------------------------------------------------------------------
  def command_106
    # 設定等待計時數值
    @wait_count = @parameters[0] * 2
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 條件分歧
  #--------------------------------------------------------------------------
  def command_111
    # 初始化本地變數 result
    result = false
    # 條件判斷
    case @parameters[0]
    when 0  # 開關
      result = ($game_switches[@parameters[1]] == (@parameters[2] == 0))
    when 1  # 變數
      value1 = $game_variables[@parameters[1]]
      if @parameters[2] == 0
        value2 = @parameters[3]
      else
        value2 = $game_variables[@parameters[3]]
      end
      case @parameters[4]
      when 0  # 等於
        result = (value1 == value2)
      when 1  # 以上
        result = (value1 >= value2)
      when 2  # 以下
        result = (value1 <= value2)
      when 3  # 超過
        result = (value1 > value2)
      when 4  # 未滿
        result = (value1 < value2)
      when 5  # 以外
        result = (value1 != value2)
      end
    when 2  # 獨立開關
      if @event_id > 0
        key = [$game_map.map_id, @event_id, @parameters[1]]
        if @parameters[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  # 計時器
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @parameters[2] == 0
          result = (sec >= @parameters[1])
        else
          result = (sec <= @parameters[1])
        end
      end
    when 4  # 角色
      actor = $game_actors[@parameters[1]]
      if actor != nil
        case @parameters[2]
        when 0  # 同伴
          result = ($game_party.actors.include?(actor))
        when 1  # 名稱
          result = (actor.name == @parameters[3])
        when 2  # 特技
          result = (actor.skill_learn?(@parameters[3]))
        when 3  # 武器
          result = (actor.weapon_id == @parameters[3])
        when 4  # 防具
  result = (actor.armor1_id == @parameters[3] or
                    actor.armor2_id == @parameters[3] or
                    actor.armor3_id == @parameters[3] or
                    actor.armor4_id == @parameters[3])
        when 5  # 狀態
          result = (actor.state?(@parameters[3]))
        end
      end
    when 5  # 敵人
      enemy = $game_troop.enemies[@parameters[1]]
      if enemy != nil
        case @parameters[2]
        when 0  # 出現
          result = (enemy.exist?)
        when 1  # 狀態
          result = (enemy.state?(@parameters[3]))
        end
      end
    when 6  # 角色
      character = get_character(@parameters[1])
      if character != nil
        result = (character.direction == @parameters[2])
      end
    when 7  # 金錢
      if @parameters[2] == 0
        result = ($game_party.gold >= @parameters[1])
      else
        result = ($game_party.gold <= @parameters[1])
      end
    when 8  # 物品
      result = ($game_party.item_number(@parameters[1]) > 0)
    when 9  # 武器
      result = ($game_party.weapon_number(@parameters[1]) > 0)
    when 10  # 防具
      result = ($game_party.armor_number(@parameters[1]) > 0)
    when 11  # 按鈕
      result = (Input.press?(@parameters[1]))
    when 12  # 活動區塊
      result = eval(@parameters[1])
    end
    # 判斷結果保存在雜湊表中
    @branch[@list[@index].indent] = result
    # 判斷結果為正確(true)的情況下
    if @branch[@list[@index].indent] == true
      # 刪除分歧資料
      @branch.delete(@list[@index].indent)
      # 繼續
      return true
    end
    # 不符合條件的情況下 : 指令跳轉
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 這以外的情況
  #--------------------------------------------------------------------------
  def command_411
    # 判斷結果為錯誤(false)的情況下
    if @branch[@list[@index].indent] == false
      # 刪除分歧資料
      @branch.delete(@list[@index].indent)
      # 繼續
      return true
    end
    # 不符合條件的情況下 : 指令跳轉
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 循環
  #--------------------------------------------------------------------------
  def command_112
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 循環上次
  #--------------------------------------------------------------------------
  def command_413
    # 取得複本
    indent = @list[@index].indent
    # 循環
    loop do
      # 推進索引
      @index -= 1
      # 本事件指令是同等級的複本的情況下
      if @list[@index].indent == indent
        # 繼續
        return true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 中斷循環
  #--------------------------------------------------------------------------
  def command_113
    # 取得複本
    indent = @list[@index].indent
    # 將複本複製到臨時變數中
    temp_index = @index
    # 循環
    loop do
      # 推進索引
      temp_index += 1
      # 沒找到符合的循環的情況下
      if temp_index >= @list.size-1
        # 繼續
        return true
      end
      # 本事件命令為 [重複上次] 複本的情況下
      if @list[temp_index].code == 413 and @list[temp_index].indent < indent
        # 更新索引
        @index = temp_index
        # 繼續
        return true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 中斷事件處理
  #--------------------------------------------------------------------------
  def command_115
    # 結束事件
    command_end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 事件暫時刪除
  #--------------------------------------------------------------------------
  def command_116
    # 事件 ID 有效的情況下
    if @event_id > 0
      # 刪除事件
      $game_map.events[@event_id].erase
    end
    # 推進索引
    @index += 1
    # 繼續
    return false
  end
  #--------------------------------------------------------------------------
  # ● 共通事件
  #--------------------------------------------------------------------------
  def command_117
    # 取得共通事件
    common_event = $data_common_events[@parameters[0]]
    # 共通事件有效的情況下
    if common_event != nil
      # 製作子編譯器
      @child_interpreter = Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 標籤
  #--------------------------------------------------------------------------
  def command_118
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 標籤跳轉
  #--------------------------------------------------------------------------
  def command_119
    # 取得標籤名
    label_name = @parameters[0]
    # 初始化臨時變數
    temp_index = 0
    # 循環
    loop do
      # 沒找到符合的標籤的情況下
      if temp_index >= @list.size-1
        # 繼續
        return true
      end
      # 本事件指令為指定的標籤的名稱的情況下
      if @list[temp_index].code == 118 and
         @list[temp_index].parameters[0] == label_name
        # 更新索引
        @index = temp_index
        # 繼續
        return true
      end
      # 推進索引
      temp_index += 1
    end
  end
end
