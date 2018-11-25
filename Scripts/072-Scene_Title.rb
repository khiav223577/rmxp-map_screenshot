#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 處理標題畫面的類別。
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 戰鬥測試的情況下
    if $BTEST
      battle_test
      return
    end
    # 載入資料庫
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    # 製作系統目標
    $game_system = Game_System.new
    # 製作標題圖形
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    # 製作命令視窗
    s1 = "開始新遊戲"
    s2 = " 讀取進度 "
    s3 = " 離開遊戲 "
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.back_opacity = 160
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 288
    # 判定繼續的有效性
    # 存檔文件一個也不存在的時候也調查
    # 有效為 @continue_enabled 為 true、無效為 false
    @continue_enabled = false
    for i in 0..3
      if FileTest.exist?("Save#{i+1}.rxdata")
        @continue_enabled = true
      end
    end
    # 繼續為有效的情況下、游標停止在繼續上
    # 無效的情況下、繼續的文字顯示為灰色
    if @continue_enabled
      @command_window.index = 1
    else
      @command_window.disable_item(1)
    end
    # 演奏標題 BGM
    $game_system.bgm_play($data_system.title_bgm)
    # 停止演奏 ME、BGS
    Audio.me_stop
    Audio.bgs_stop
    # 執行過渡
    Graphics.transition
    # 主循環
    loop do
      # 更新遊戲畫面
      Graphics.update
      # 更新輸入訊息
      Input.update
      # 更新畫面
      update
      # 如果畫面被切換就中斷循環
      if $scene != self
        break
      end
    end
    # 裝備過渡
    Graphics.freeze
    # 釋放命令視窗所佔的記憶體空間
    @command_window.dispose
    # 釋放標題圖形所佔的記憶體空間
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 更新命令視窗
    @command_window.update
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 命令視窗的游標位置的分支
      case @command_window.index
      when 0  # 新遊戲
        command_new_game
      when 1  # 繼續
        command_continue
      when 2  # 退出
        command_shutdown
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 命令 : 新遊戲
  #--------------------------------------------------------------------------
  def command_new_game
    # 演奏確定 SE
    $game_system.se_play($data_system.decision_se)
    # 停止 BGM
    Audio.bgm_stop
    # 重置測量遊戲時間用的畫面計數器
    Graphics.frame_count = 0
    # 製作各種遊戲目標
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # 設定初期同伴位置
    $game_party.setup_starting_members
    # 設定初期位置的地圖
    $game_map.setup($data_system.start_map_id)
    # 主角向初期位置移動
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    # 更新主角
    $game_player.refresh
    # 執行地圖設定的 BGM 與 BGS 的自動切換
    $game_map.autoplay
    # 更新地圖 (執行平行事件)
    $game_map.update
    # 切換地圖畫面
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● 命令 : 繼續
  #--------------------------------------------------------------------------
  def command_continue
    # 繼續無效的情況下
    unless @continue_enabled
      # 演奏無效 SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # 演奏確定 SE
    $game_system.se_play($data_system.decision_se)
    # 切換到讀檔畫面
    $scene = Scene_Load.new
  end
  #--------------------------------------------------------------------------
  # ● 命令 : 退出
  #--------------------------------------------------------------------------
  def command_shutdown
    # 演奏確定 SE
    $game_system.se_play($data_system.decision_se)
    # BGM、BGS、ME 的淡入淡出
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 退出
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥測試
  #--------------------------------------------------------------------------
  def battle_test
    # 載入資料庫 (戰鬥測試用)
    $data_actors        = load_data("Data/BT_Actors.rxdata")
    $data_classes       = load_data("Data/BT_Classes.rxdata")
    $data_skills        = load_data("Data/BT_Skills.rxdata")
    $data_items         = load_data("Data/BT_Items.rxdata")
    $data_weapons       = load_data("Data/BT_Weapons.rxdata")
    $data_armors        = load_data("Data/BT_Armors.rxdata")
    $data_enemies       = load_data("Data/BT_Enemies.rxdata")
    $data_troops        = load_data("Data/BT_Troops.rxdata")
    $data_states        = load_data("Data/BT_States.rxdata")
    $data_animations    = load_data("Data/BT_Animations.rxdata")
    $data_tilesets      = load_data("Data/BT_Tilesets.rxdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rxdata")
    $data_system        = load_data("Data/BT_System.rxdata")
    # 重置測量遊戲時間用的畫面計數器
    Graphics.frame_count = 0
    # 製作各種遊戲目標
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # 設定戰鬥測試用同伴
    $game_party.setup_battle_test_members
    # 設定隊伍 ID、可以逃走標誌、戰鬥背景
    $game_temp.battle_troop_id = $data_system.test_troop_id
    $game_temp.battle_can_escape = true
    $game_map.battleback_name = $data_system.battleback_name
    # 演奏戰鬥開始 BGM
    $game_system.se_play($data_system.battle_start_se)
    # 演奏戰鬥 BGM
    $game_system.bgm_play($game_system.battle_bgm)
    # 切換到戰鬥畫面
    $scene = Scene_Battle.new
  end
end
