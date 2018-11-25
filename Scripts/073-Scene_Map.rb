#==============================================================================
# ■ Scene_Map
#------------------------------------------------------------------------------
# 處理地圖畫面的類別。
#==============================================================================

class Scene_Map
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 製作活動區塊
    @spriteset = Spriteset_Map.new
    # 製作訊息窗口
    @message_window = Window_Message.new
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
      # 如果畫面切換的話就中斷循環
      if $scene != self
        break
      end
    end
    # 準備過渡
    Graphics.freeze
    # 釋放活動區塊所佔的記憶體空間
    @spriteset.dispose
    # 釋放訊息窗口所佔的記憶體空間
    @message_window.dispose
    # 標題畫面切換中的情況下
    if $scene.is_a?(Scene_Title)
      # 淡入淡出畫面
      Graphics.transition
      Graphics.freeze
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 循環
    loop do
      # 按照地圖、實例、主角的順序更新
      # 本更新順序不會在滿足事件的執行條件下成為給角色瞬間移動機會的重要因素
      $game_map.update
      $game_system.map_interpreter.update
      $game_player.update
      # 系統 (計時器)、畫面更新
      $game_system.update
      $game_screen.update
      # 如果主角在場所移動中就中斷循環
      unless $game_temp.player_transferring
        break
      end
      # 執行場所移動
      transfer_player
      # 處理過渡中的情況下、中斷循環
      if $game_temp.transition_processing
        break
      end
    end
    # 更新活動區塊
    @spriteset.update
    # 更新訊息視窗
    @message_window.update
    # 遊戲結束的情況下
    if $game_temp.gameover
      # 切換的遊戲結束畫面
      $scene = Scene_Gameover.new
      return
    end
    # 返回標題畫面的情況下
    if $game_temp.to_title
      # 切換到標題畫面
      $scene = Scene_Title.new
      return
    end
    # 處理過渡中的情況下
    if $game_temp.transition_processing
      # 清除過渡處理中標誌
      $game_temp.transition_processing = false
      # 執行過渡
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # 顯示訊息視窗中的情況下
    if $game_temp.message_window_showing
      return
    end
    # 遇敵計數為 0 且、且遇敵列表不為空的情況下
    if $game_player.encounter_count == 0 and $game_map.encounter_list != []
      # 不是在事件執行中或者禁止遇敵中
      unless $game_system.map_interpreter.running? or
             $game_system.encounter_disabled
        # 確定隊伍
        n = rand($game_map.encounter_list.size)
        troop_id = $game_map.encounter_list[n]
        # 隊伍有效的話
        if $data_troops[troop_id] != nil
          # 設定取用戰鬥標誌
          $game_temp.battle_calling = true
          $game_temp.battle_troop_id = troop_id
          $game_temp.battle_can_escape = true
          $game_temp.battle_can_lose = false
          $game_temp.battle_proc = nil
        end
      end
    end
    # 按下 B 鍵的情況下
    if Input.trigger?(Input::B)
      # 不是在事件執行中或選單禁止中
      unless $game_system.map_interpreter.running? or
             $game_system.menu_disabled
        # 設定選單取用標誌以及 SE 演奏
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
    end
    # 除錯模式為 ON 並且按下 F9 鍵的情況下
    if $DEBUG and Input.press?(Input::F9)
      # 設定取用除錯標誌
      $game_temp.debug_calling = true
    end
    # 不在主角移動中的情況下
    unless $game_player.moving?
      # 執行各種畫面的取用
      if $game_temp.battle_calling
        call_battle
      elsif $game_temp.shop_calling
        call_shop
      elsif $game_temp.name_calling
        call_name
      elsif $game_temp.menu_calling
        call_menu
      elsif $game_temp.save_calling
        call_save
      elsif $game_temp.debug_calling
        call_debug
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 取用戰鬥
  #--------------------------------------------------------------------------
  def call_battle
    # 清除戰鬥取用標誌
    $game_temp.battle_calling = false
    # 清除選單取用標誌
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    # 製作遇敵計數
    $game_player.make_encounter_count
    # 記憶地圖 BGM 、停止 BGM
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    # 演奏戰鬥開始 SE
    $game_system.se_play($data_system.battle_start_se)
    # 演奏戰鬥 BGM
    $game_system.bgm_play($game_system.battle_bgm)
    # 矯正主角位置
    $game_player.straighten
    # 切換到戰鬥畫面
    $scene = Scene_Battle.new
  end
  #--------------------------------------------------------------------------
  # ● 取用商店
  #--------------------------------------------------------------------------
  def call_shop
    # 清除商店取用標誌
    $game_temp.shop_calling = false
    # 矯正主角位置
    $game_player.straighten
    # 切換到商店畫面
    $scene = Scene_Shop.new
  end
  #--------------------------------------------------------------------------
  # ● 取用名稱輸入
  #--------------------------------------------------------------------------
  def call_name
    # 清除商店取用名稱輸入標誌
    $game_temp.name_calling = false
    # 矯正主角位置
    $game_player.straighten
    # 切換到名稱輸入畫面
    $scene = Scene_Name.new
  end
  #--------------------------------------------------------------------------
  # ● 取用選單
  #--------------------------------------------------------------------------
  def call_menu
    # 清除商店取用選單標誌
    $game_temp.menu_calling = false
    # 已經設定了選單 SE 演奏標誌的情況下
    if $game_temp.menu_beep
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 清除選單演奏 SE 標誌
      $game_temp.menu_beep = false
    end
    # 矯正主角位置
    $game_player.straighten
    # 切換到選單畫面
    $scene = Scene_Menu.new
  end
  #--------------------------------------------------------------------------
  # ● 取用存檔
  #--------------------------------------------------------------------------
  def call_save
    # 矯正主角位置
    $game_player.straighten
    # 切換到存檔畫面
    $scene = Scene_Save.new
  end
  #--------------------------------------------------------------------------
  # ● 取用除錯
  #--------------------------------------------------------------------------
  def call_debug
    # 清除商店取用除錯標誌
    $game_temp.debug_calling = false
    # 演奏確定 SE
    $game_system.se_play($data_system.decision_se)
    # 矯正主角位置
    $game_player.straighten
    # 切換到除錯畫面
    $scene = Scene_Debug.new
  end
  #--------------------------------------------------------------------------
  # ● 主角的場所移動
  #--------------------------------------------------------------------------
  def transfer_player
    # 清除主角場所移動除錯標誌
    $game_temp.player_transferring = false
    # 移動目標與現在的地圖有差異的情況下
    if $game_map.map_id != $game_temp.player_new_map_id
      # 設定新地圖
      $game_map.setup($game_temp.player_new_map_id)
    end
    # 設定主角位置
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    # 設定主角面向
    case $game_temp.player_new_direction
    when 2  # 下
      $game_player.turn_down
    when 4  # 左
      $game_player.turn_left
    when 6  # 右
      $game_player.turn_right
    when 8  # 上
      $game_player.turn_up
    end
    # 矯正主角位置
    $game_player.straighten
    # 更新地圖 (執行平行事件)
    $game_map.update
    # 在製作活動區塊
    @spriteset.dispose
    @spriteset = Spriteset_Map.new
    # 處理過渡中的情況下
    if $game_temp.transition_processing
      # 清除過渡處理中標誌
      $game_temp.transition_processing = false
      # 執行過渡
      Graphics.transition(20)
    end
    # 執行地圖設定的 BGM、BGS 的自動切換
    $game_map.autoplay
    # 設定畫面
    Graphics.frame_reset
    # 更新輸入訊息
    Input.update
  end
end
