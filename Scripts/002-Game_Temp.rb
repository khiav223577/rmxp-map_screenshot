#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 在沒有存檔的情況下，處理臨時資料的類別。這個類別的實例請參考 $game_temp。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_accessor :map_bgm                  # 地圖畫面 BGM (戰鬥時記憶用)
  attr_accessor :message_text             # 訊息文字
  attr_accessor :message_proc             # 訊息 返回取用 (Proc)
  attr_accessor :choice_start             # 選擇項目 開始首行
  attr_accessor :choice_max               # 選擇項目 項目數
  attr_accessor :choice_cancel_type       # 選擇項目 取消的情況
  attr_accessor :choice_proc              # 選擇項目 返回取用 (Proc)
  attr_accessor :num_input_start          # 輸入數值 開始首行
  attr_accessor :num_input_variable_id    # 輸入數值 變量 ID
  attr_accessor :num_input_digits_max     # 輸入數值 位數
  attr_accessor :message_window_showing   # 顯示訊息視窗
  attr_accessor :common_event_id          # 共通事件 ID
  attr_accessor :in_battle                # 戰鬥中的標誌
  attr_accessor :battle_calling           # 取用戰鬥的標誌
  attr_accessor :battle_troop_id          # 戰鬥 隊伍 ID
  attr_accessor :battle_can_escape        # 戰鬥中 允許逃跑 ID
  attr_accessor :battle_can_lose          # 戰鬥中 允許失敗 ID
  attr_accessor :battle_proc              # 戰鬥 返回取用 (Proc)
  attr_accessor :battle_turn              # 戰鬥 回合數
  attr_accessor :battle_event_flags       # 戰鬥 事件執行執行完畢的標誌
  attr_accessor :battle_abort             # 戰鬥 中斷標誌
  attr_accessor :battle_main_phase        # 戰鬥 狀態標誌
  attr_accessor :battleback_name          # 戰鬥背景 檔案名稱
  attr_accessor :forcing_battler          # 強制行動的戰鬥者
  attr_accessor :shop_calling             # 取用商店的標誌
  attr_accessor :shop_goods               # 商店 商品列表
  attr_accessor :name_calling             # 輸入名稱 取用標誌
  attr_accessor :name_actor_id            # 輸入名稱 角色 ID
  attr_accessor :name_max_char            # 輸入名稱 最大字數
  attr_accessor :menu_calling             # 選單 取用標誌
  attr_accessor :menu_beep                # 選單 SE 演奏標誌
  attr_accessor :save_calling             # 存檔 取用標誌
  attr_accessor :debug_calling            # 除錯 取用標誌
  attr_accessor :player_transferring      # 主角 場所移動標誌
  attr_accessor :player_new_map_id        # 主角 移動目標地圖 ID
  attr_accessor :player_new_x             # 主角 移動目標 X 座標
  attr_accessor :player_new_y             # 主角 移動目標 Y 座標
  attr_accessor :player_new_direction     # 主角 移動目標 面向
  attr_accessor :transition_processing    # 轉變處理中標誌
  attr_accessor :transition_name          # 轉變 檔案名稱
  attr_accessor :gameover                 # 遊戲結束標誌
  attr_accessor :to_title                 # 返回標題畫面標誌
  attr_accessor :last_file_index          # 最後存檔的文件編號
  attr_accessor :debug_top_row            # 除錯畫面 保存狀態用
  attr_accessor :debug_index              # 除錯畫面 保存狀態用
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #--------------------------------------------------------------------------
  def initialize
    @map_bgm = nil
    @message_text = nil
    @message_proc = nil
    @choice_start = 99
    @choice_max = 0
    @choice_cancel_type = 0
    @choice_proc = nil
    @num_input_start = 99
    @num_input_variable_id = 0
    @num_input_digits_max = 0
    @message_window_showing = false
    @common_event_id = 0
    @in_battle = false
    @battle_calling = false
    @battle_troop_id = 0
    @battle_can_escape = false
    @battle_can_lose = false
    @battle_proc = nil
    @battle_turn = 0
    @battle_event_flags = {}
    @battle_abort = false
    @battle_main_phase = false
    @battleback_name = ''
    @forcing_battler = nil
    @shop_calling = false
    @shop_id = 0
    @name_calling = false
    @name_actor_id = 0
    @name_max_char = 0
    @menu_calling = false
    @menu_beep = false
    @save_calling = false
    @debug_calling = false
    @player_transferring = false
    @player_new_map_id = 0
    @player_new_x = 0
    @player_new_y = 0
    @player_new_direction = 0
    @transition_processing = false
    @transition_name = ""
    @gameover = false
    @to_title = false
    @last_file_index = 0
    @debug_top_row = 0
    @debug_index = 0
  end
end
