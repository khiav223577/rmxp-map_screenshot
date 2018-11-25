#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 處理事件的類別。使用在條件判斷、事件頁的切換、平行處理、執行事件功能等
# Game_Map 類別的內部。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :trigger                  # 目標
  attr_reader   :list                     # 執行內容
  attr_reader   :starting                 # 啟動中標誌
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #     map_id : 地圖 ID
  #     event  : 事件 (RPG::Event)
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @through = true
    # 初期位置的移動
    moveto(@event.x, @event.y)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 清除移動中標誌
  #--------------------------------------------------------------------------
  def clear_starting
    @starting = false
  end
  #--------------------------------------------------------------------------
  # ● 越過目標判斷 (不能將相同位置作為啟動條件)
  #--------------------------------------------------------------------------
  def over_trigger?
    # 沒有開啟穿越座標的描述情況下
    if @character_name != "" and not @through
      # 啟動判斷是正面
      return false
    end
    # 地圖上的這個位置不能通行的情況下
    unless $game_map.passable?(@x, @y, 0)
      # 啟動判斷是正面
      return false
    end
    # 啟動判斷在同位置
    return true
  end
  #--------------------------------------------------------------------------
  # ● 啟動事件
  #--------------------------------------------------------------------------
  def start
    # 執行內容不為空的情況下
    if @list.size > 1
      @starting = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 暫時消失
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def refresh
    # 初始化本地變量 new_page
    new_page = nil
    # 如果不暫時清除
    unless @erased
      # 從編號大的事件頁按順序調查
      for page in @event.pages.reverse
        # 可以參考事件條件 c
        c = page.condition
        # 確認開關條件 1 
        if c.switch1_valid
          if $game_switches[c.switch1_id] == false
            next
          end
        end
        # 確認開關條件 2 
        if c.switch2_valid
          if $game_switches[c.switch2_id] == false
            next
          end
        end
        # 確認變量條件
        if c.variable_valid
          if $game_variables[c.variable_id] < c.variable_value
            next
          end
        end
        # 確認獨立開關條件
        if c.self_switch_valid
          key = [@map_id, @event.id, c.self_switch_ch]
          if $game_self_switches[key] != true
            next
          end
        end
        # 設定本地變量 new_page
        new_page = page
        # 放棄循環
        break
      end
    end
    # 與上次同一事件頁的情況下
    if new_page == @page
      # 過程結束
      return
    end
    # @page 設置為現在的事件頁
    @page = new_page
    # 清除啟動中標誌
    clear_starting
    # 沒有滿足條件的頁面的時候
    if @page == nil
      # 設定各實例變量
      @tile_id = 0
      @character_name = ""
      @character_hue = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
      # 過程結束
      return
    end
    # 設定各實例變量
    @tile_id = @page.graphic.tile_id
    @character_name = @page.graphic.character_name
    @character_hue = @page.graphic.character_hue
    if @original_direction != @page.graphic.direction
      @direction = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern = @page.graphic.pattern
      @original_pattern = @pattern
    end
    @opacity = @page.graphic.opacity
    @blend_type = @page.graphic.blend_type
    @move_type = @page.move_type
    @move_speed = @page.move_speed
    @move_frequency = @page.move_frequency
    @move_route = @page.move_route
    @move_route_index = 0
    @move_route_forcing = false
    @walk_anime = @page.walk_anime
    @step_anime = @page.step_anime
    @direction_fix = @page.direction_fix
    @through = @page.through
    @always_on_top = @page.always_on_top
    @trigger = @page.trigger
    @list = @page.list
    @interpreter = nil
    # 目標是 [平行處理] 的情況下
    if @trigger == 4
      # 生成平行處理用編譯器
      @interpreter = Interpreter.new
    end
    # 自動事件啟動判斷
    check_event_trigger_auto
  end
  #--------------------------------------------------------------------------
  # ● 接觸事件啟動判斷
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    # 事件執行中的情況下
    if $game_system.map_interpreter.running?
      return
    end
    # 目標為 [與事件接觸] 以及和主角座標一致的情況下
    if @trigger == 2 and x == $game_player.x and y == $game_player.y
      # 除跳躍中以外的情況、啟動判斷就是正面的事件
      if not jumping? and not over_trigger?
        start
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 自動事件啟動判斷
  #--------------------------------------------------------------------------
  def check_event_trigger_auto
    # 目標為 [與事件接觸] 以及和主角座標一致的情況下
    if @trigger == 2 and @x == $game_player.x and @y == $game_player.y
      # 除跳躍中以外的情況、啟動判斷就是同位置的事件
      if not jumping? and over_trigger?
        start
      end
    end
    # 目標是 [自動執行] 的情況下
    if @trigger == 3
      start
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    # 自動啟動事件判斷
    check_event_trigger_auto
    # 平行處理有效的情況下
    if @interpreter != nil
      # 不在執行中的場合的情況下
      unless @interpreter.running?
        # 設定事件
        @interpreter.setup(@list, @event.id)
      end
      # 更新編譯器
      @interpreter.update
    end
  end
end
