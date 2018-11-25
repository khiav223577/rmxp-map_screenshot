#==============================================================================
# ■ Scene_Battle (第一部份)
#------------------------------------------------------------------------------
# 處理戰鬥畫面的類別。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● 主要處理
  #--------------------------------------------------------------------------
  def main
    # 初始化戰鬥用的各種暫時資料
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # 初始化戰鬥用事件編譯器
    $game_system.battle_interpreter.setup(nil, 0)
    # 準備隊伍
    @troop_id = $game_temp.battle_troop_id
    $game_troop.setup(@troop_id)
    # 製作角色命令視窗
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    s4 = $data_system.words.item
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4])
    @actor_command_window.y = 160
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # 製作其它視窗
    @party_command_window = Window_PartyCommand.new
    @help_window = Window_Help.new
    @help_window.back_opacity = 160
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @message_window = Window_Message.new
    # 製作活動區塊
    @spriteset = Spriteset_Battle.new
    # 初始化等待計時數值
    @wait_count = 0
    # 執行轉變
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
    # 開始自由戰鬥回合
    start_phase1
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
    # 更新地圖
    $game_map.refresh
    # 準備轉變
    Graphics.freeze
    # 釋放視窗
    @actor_command_window.dispose
    @party_command_window.dispose
    @help_window.dispose
    @status_window.dispose
    @message_window.dispose
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    # 釋放活動區塊
    @spriteset.dispose
    # 標題畫面切換中的情況
    if $scene.is_a?(Scene_Title)
      # 淡入淡出畫面
      Graphics.transition
      Graphics.freeze
    end
    # 在戰鬥測試到遊戲結束以外的畫面切換情況下
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 勝負判斷
  #--------------------------------------------------------------------------
  def judge
    # 全滅判斷是事實(true)、並且同伴人數為0人的情況下
    if $game_party.all_dead? or $game_party.actors.size == 0
      # 允許失敗的情況下
      if $game_temp.battle_can_lose
        # 還原為戰鬥開始前的 BGM
        $game_system.bgm_play($game_temp.map_bgm)
        # 戰鬥結束
        battle_end(2)
        # 返回事實(true)
        return true
      end
      # 設定遊戲結束標誌
      $game_temp.gameover = true
      # 返回事實(true)
      return true
    end
    # 如果存在任何1個敵人就返回錯誤(false)
    for enemy in $game_troop.enemies
      if enemy.exist?
        return false
      end
    end
    # 開始結束戰鬥回合(勝利)
    start_phase5
    # 返回事實(true)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥結束
  #     result : 結果 (0:勝利 1:失敗 2:逃跑)
  #--------------------------------------------------------------------------
  def battle_end(result)
    # 清除戰鬥中標誌
    $game_temp.in_battle = false
    # 清除全體同伴的行動
    $game_party.clear_actions
    # 解除戰鬥用狀態
    for actor in $game_party.actors
      actor.remove_states_battle
    end
    # 清除敵人
    $game_troop.enemies.clear
    # 取用戰鬥返回呼叫
    if $game_temp.battle_proc != nil
      $game_temp.battle_proc.call(result)
      $game_temp.battle_proc = nil
    end
    # 切換到地圖畫面
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● 設定戰鬥事件
  #--------------------------------------------------------------------------
  def setup_battle_event
    # 正在執行戰鬥事件的情況下
    if $game_system.battle_interpreter.running?
      return
    end
    # 搜索全部頁面的戰鬥事件
    for index in 0...$data_troops[@troop_id].pages.size
      # 取得事件頁面
      page = $data_troops[@troop_id].pages[index]
      # 事件條件可以參考 c
      c = page.condition
      # 沒有指定任何條件的情況下轉到下一頁
      unless c.turn_valid or c.enemy_valid or
             c.actor_valid or c.switch_valid
        next
      end
      # 執行完畢的情況下轉到下一頁
      if $game_temp.battle_event_flags[index]
        next
      end
      # 確認回合條件
      if c.turn_valid
        n = $game_temp.battle_turn
        a = c.turn_a
        b = c.turn_b
        if (b == 0 and n != a) or
           (b > 0 and (n < 1 or n < a or n % b != a % b))
          next
        end
      end
      # 確認敵人條件
      if c.enemy_valid
        enemy = $game_troop.enemies[c.enemy_index]
        if enemy == nil or enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
          next
        end
      end
      # 確認角色條件
      if c.actor_valid
        actor = $game_actors[c.actor_id]
        if actor == nil or actor.hp * 100.0 / actor.maxhp > c.actor_hp
          next
        end
      end
      # 確認開關條件
      if c.switch_valid
        if $game_switches[c.switch_id] == false
          next
        end
      end
      # 設定事件
      $game_system.battle_interpreter.setup(page.list, 0)
      # 本頁的範圍是[戰鬥]或[回合]的情況下
      if page.span <= 1
        # 設定執行結束標誌
        $game_temp.battle_event_flags[index] = true
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 執行戰鬥事件中的情況下
    if $game_system.battle_interpreter.running?
      # 更新編譯器
      $game_system.battle_interpreter.update
      # 強制行動的戰鬥者不存在的情況下
      if $game_temp.forcing_battler == nil
        # 執行戰鬥事件結束的情況下
        unless $game_system.battle_interpreter.running?
          # 繼續戰鬥的情況下、再執行戰鬥事件的設定
          unless judge
            setup_battle_event
          end
        end
        # 如果不是結束戰鬥回合的情況下
        if @phase != 5
          # 更新狀態視窗
          @status_window.refresh
        end
      end
    end
    # 更新系統(計時器)和畫面
    $game_system.update
    $game_screen.update
    # 計時器為0的情況下
    if $game_system.timer_working and $game_system.timer == 0
      # 中斷戰鬥
      $game_temp.battle_abort = true
    end
    # 更新視窗
    @help_window.update
    @party_command_window.update
    @actor_command_window.update
    @status_window.update
    @message_window.update
    # 更新活動區塊
    @spriteset.update
    # 處理轉變中的情況下
    if $game_temp.transition_processing
      # 清除處理轉變中標誌
      $game_temp.transition_processing = false
      # 執行轉變
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
    # 顯示效果中的情況下
    if @spriteset.effect?
      return
    end
    # 遊戲結束的情況下
    if $game_temp.gameover
      # 切換到遊戲結束畫面
      $scene = Scene_Gameover.new
      return
    end
    # 返回標題畫面的情況下
    if $game_temp.to_title
      # 切換到標題畫面
      $scene = Scene_Title.new
      return
    end
    # 中斷戰鬥的情況下
    if $game_temp.battle_abort
      # 還原為戰鬥前的 BGM
      $game_system.bgm_play($game_temp.map_bgm)
      # 戰鬥結束
      battle_end(1)
      return
    end
    # 等待中的情況下
    if @wait_count > 0
      # 減少等待計時數值
      @wait_count -= 1
      return
    end
    # 強制行動的角色存在、
    # 並且戰鬥事件正在執行的情況下
    if $game_temp.forcing_battler == nil and
       $game_system.battle_interpreter.running?
      return
    end
    # 回合分歧
    case @phase
    when 1  # 自由戰鬥回合
      update_phase1
    when 2  # 同伴命令回合
      update_phase2
    when 3  # 角色命令回合
      update_phase3
    when 4  # 主回合
      update_phase4
    when 5  # 戰鬥結束回合
      update_phase5
    end
  end
end
