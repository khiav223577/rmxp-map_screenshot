#==============================================================================
# ■ Interpreter (第一部份)
#------------------------------------------------------------------------------
# 執行事件命令的編譯器。使用在 Game_System 類別與 Game_Event 類別的內部。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 初始化標誌
  #     depth : 事件的深度
  #     main  : 主標誌
  #--------------------------------------------------------------------------
  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    # 深度超過 100 級
    if depth > 100
      print("取用共通事件超過了限制。")
      exit
    end
    # 清除編譯器的內部狀態
    clear
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @map_id = 0                       # 啟動時的地圖 ID
    @event_id = 0                     # 事件 ID
    @message_waiting = false          # 等待訊息結束
    @move_route_waiting = false       # 等待移動結束
    @button_input_variable_id = 0     # 輸入按鈕 變量 ID
    @wait_count = 0                   # 視窗計時數值
    @child_interpreter = nil          # 子編譯器
    @branch = {}                      # 分歧資料
  end
  #--------------------------------------------------------------------------
  # ● 設定事件
  #     list     : 執行內容
  #     event_id : 事件 ID
  #--------------------------------------------------------------------------
  def setup(list, event_id)
    # 清除編譯器的內部狀態
    clear
    # 記憶地圖 ID
    @map_id = $game_map.map_id
    # 記憶事件 ID
    @event_id = event_id
    # 記憶執行內容
    @list = list
    # 初始化索引
    @index = 0
    # 清除雜湊表的分歧資料
    @branch.clear
  end
  #--------------------------------------------------------------------------
  # ● 執行中判斷
  #--------------------------------------------------------------------------
  def running?
    return @list != nil
  end
  #--------------------------------------------------------------------------
  # ● 設定啟動中事件
  #--------------------------------------------------------------------------
  def setup_starting_event
    # 更新必要的地圖
    if $game_map.need_refresh
      $game_map.refresh
    end
    # 如果取用的共通事件被預定的情況下
    if $game_temp.common_event_id > 0
      # 設定事件
      setup($data_common_events[$game_temp.common_event_id].list, 0)
      # 解除預定
      $game_temp.common_event_id = 0
      return
    end
    # 循環 (地圖事件)
    for event in $game_map.events.values
      # 如果找到了啟動中的事件
      if event.starting
        # 如果不是自動執行
        if event.trigger < 3
          # 清除啟動中標誌
          event.clear_starting
          # 鎖定
          event.lock
        end
        # 設定事件
        setup(event.list, event.id)
        return
      end
    end
    # 循環(共通事件)
    for common_event in $data_common_events.compact
      # 目標的自動執行開關為 ON 的情況下
      if common_event.trigger == 1 and
         $game_switches[common_event.switch_id] == true
        # 設定事件
        setup(common_event.list, 0)
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 初始化循環計時數值
    @loop_count = 0
    # 循環
    loop do
      # 循環計時數值加 1
      @loop_count += 1
      # 如果執行了 100 個事件指令
      if @loop_count > 100
        # 為了防止系統停止、取用 Graphics.update
        Graphics.update
        @loop_count = 0
      end
      # 如果地圖與事件啟動有差異
      if $game_map.map_id != @map_id
        # 事件 ID 設定為 0
        @event_id = 0
      end
      # 子編譯器存在的情況下
      if @child_interpreter != nil
        # 更新子編譯器
        @child_interpreter.update
        # 子編譯器執行結束的情況下
        unless @child_interpreter.running?
          # 刪除子編譯器
          @child_interpreter = nil
        end
        # 如果子編譯器還存在
        if @child_interpreter != nil
          return
        end
      end
      # 訊息結束待機的情況下
      if @message_waiting
        return
      end
      # 移動結束待機的情況下
      if @move_route_waiting
        # 強制主角移動路線的情況下
        if $game_player.move_route_forcing
          return
        end
        # 循環 (地圖事件)
        for event in $game_map.events.values
          # 本事件為強制移動路線的情況下
          if event.move_route_forcing
            return
          end
        end
        # 清除移動結束待機中的標誌
        @move_route_waiting = false
      end
      # 輸入按鈕待機中的情況下
      if @button_input_variable_id > 0
        # 執行按鈕輸入處理
        input_button
        return
      end
      # 等待中的情況下
      if @wait_count > 0
        # 減少等待計時數值
        @wait_count -= 1
        return
      end
      # 如果被強制行動的戰鬥者存在
      if $game_temp.forcing_battler != nil
        return
      end
      # 如果各畫面的取用標誌已經被設定
      if $game_temp.battle_calling or
         $game_temp.shop_calling or
         $game_temp.name_calling or
         $game_temp.menu_calling or
         $game_temp.save_calling or
         $game_temp.gameover
        return
      end
      # 執行內容列表為空的情況下
      if @list == nil
        # 主地圖事件的情況下
        if @main
          # 設定啟動中的事件
          setup_starting_event
        end
        # 什麼都沒有設定的情況下
        if @list == nil
          return
        end
      end
      # 嘗試執行事件列表、返回值為錯誤(false)的情況下
      if execute_command == false
        return
      end
      # 推進索引
      @index += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 輸入按鈕
  #--------------------------------------------------------------------------
  def input_button
    # 判斷按下的按鈕
    n = 0
    for i in 1..18
      if Input.trigger?(i)
        n = i
      end
    end
    # 按下按鈕的情況下
    if n > 0
      # 更改變量值
      $game_variables[@button_input_variable_id] = n
      $game_map.need_refresh = true
      # 輸入按鍵結束
      @button_input_variable_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 設定選擇項目
  #--------------------------------------------------------------------------
  def setup_choices(parameters)
    # choice_max 為設定選擇項目的數量
    $game_temp.choice_max = parameters[0].size
    # message_text 為設定選擇項目
    for text in parameters[0]
      $game_temp.message_text += text + "\n"
    end
    # 設定取消的情況的處理
    $game_temp.choice_cancel_type = parameters[1]
    # 返回取用設定
    current_indent = @list[@index].indent
    $game_temp.choice_proc = Proc.new { |n| @branch[current_indent] = n }
  end
  #--------------------------------------------------------------------------
  # ● 角色用 itereta (考慮全體同伴)
  #     parameter : 1 以上為 ID、0 為全體
  #--------------------------------------------------------------------------
  def iterate_actor(parameter)
    # 全體同伴的情況下
    if parameter == 0
      # 同伴全體循環
      for actor in $game_party.actors
        # 評估區塊
        yield actor
      end
    # 單人角色的情況下
    else
      # 取得角色
      actor = $game_actors[parameter]
      # 取得角色
      yield actor if actor != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 敵人用 itereta (考慮隊伍全體)
  #     parameter : 0 為索引、-1 為全體
  #--------------------------------------------------------------------------
  def iterate_enemy(parameter)
    # 隊伍全體的情況下
    if parameter == -1
      # 隊伍全體循環
      for enemy in $game_troop.enemies
        # 評估區塊
        yield enemy
      end
    # 敵方單人的情況下
    else
      # 取得敵人
      enemy = $game_troop.enemies[parameter]
      # 評估區塊
      yield enemy if enemy != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥者用 itereta (要考慮全體隊伍、全體同伴)
  #     parameter1 : 0 為敵人、1 為角色
  #     parameter2 : 0 以上為索引、-1 為全體
  #--------------------------------------------------------------------------
  def iterate_battler(parameter1, parameter2)
    # 敵人的情況下
    if parameter1 == 0
      # 取用敵人的 itereta
      iterate_enemy(parameter2) do |enemy|
        yield enemy
      end
    # 角色的情況下
    else
      # 全體同伴的情況下
      if parameter2 == -1
        # 同伴全體循環
        for actor in $game_party.actors
          # 評估區塊
          yield actor
        end
      # 角色單人 (N 個人) 的情況下
      else
        # 取得角色
        actor = $game_party.actors[parameter2]
        # 評估區塊
        yield actor if actor != nil
      end
    end
  end
end
