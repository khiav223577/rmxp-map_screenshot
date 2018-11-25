#==============================================================================
# ■ Scene_Battle (第二部份)
#------------------------------------------------------------------------------
# 處理戰鬥畫面的類別。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● 開始自由戰鬥回合
  #--------------------------------------------------------------------------
  def start_phase1
    # 轉移到回合1
    @phase = 1
    # 清除全體同伴的行動
    $game_party.clear_actions
    # 設定戰鬥事件
    setup_battle_event
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (自由戰鬥回合)
  #--------------------------------------------------------------------------
  def update_phase1
    # 勝敗判斷
    if judge
      # 勝利或者失敗的情況下 : 過程結束
      return
    end
    # 開始同伴命令回合
    start_phase2
  end
  #--------------------------------------------------------------------------
  # ● 開始同伴命令回合
  #--------------------------------------------------------------------------
  def start_phase2
    # 轉移到回合2
    @phase = 2
    # 設定角色為非選擇狀態
    @actor_index = -1
    @active_battler = nil
    # 啟動同伴指令視窗
    @party_command_window.active = true
    @party_command_window.visible = true
    # 停止角色指令視窗
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # 清除主回合標誌
    $game_temp.battle_main_phase = false
    # 清除全體同伴的行動
    $game_party.clear_actions
    # 不能輸入命令的情況下
    unless $game_party.inputable?
      # 開始主回合
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (同伴命令回合)
  #--------------------------------------------------------------------------
  def update_phase2
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 同伴指令視窗與游標位置的分歧
      case @party_command_window.index
      when 0  # 戰鬥
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 開始角色的命令回合
        start_phase3
      when 1  # 逃跑
        # 不能逃跑的情況下
        if $game_temp.battle_can_escape == false
          # 演奏循環 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 逃走處理
        update_phase2_escape
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 畫面更新 (同伴指令回合 : 逃跑)
  #--------------------------------------------------------------------------
  def update_phase2_escape
    # 計算敵人速度的平均值
    enemies_agi = 0
    enemies_number = 0
    for enemy in $game_troop.enemies
      if enemy.exist?
        enemies_agi += enemy.agi
        enemies_number += 1
      end
    end
    if enemies_number > 0
      enemies_agi /= enemies_number
    end
    # 計算角色速度的平均值
    actors_agi = 0
    actors_number = 0
    for actor in $game_party.actors
      if actor.exist?
        actors_agi += actor.agi
        actors_number += 1
      end
    end
    if actors_number > 0
      actors_agi /= actors_number
    end
    # 逃跑成功判斷
    success = rand(100) < 50 * actors_agi / enemies_agi
    # 成功逃跑的情況下
    if success
      # 演奏逃跑 SE
      $game_system.se_play($data_system.escape_se)
      # 還原為戰鬥開始前的 BGM
      $game_system.bgm_play($game_temp.map_bgm)
      # 戰鬥結束
      battle_end(1)
    # 逃跑失敗的情況下
    else
      # 清除全體同伴的行動
      $game_party.clear_actions
      # 開始主回合
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # ● 開始結束戰鬥回合
  #--------------------------------------------------------------------------
  def start_phase5
    # 轉移到回合5
    @phase = 5
    # 演奏戰鬥結束 ME
    $game_system.me_play($game_system.battle_end_me)
    # 還原為戰鬥開始前的 BGM
    $game_system.bgm_play($game_temp.map_bgm)
    # 初始化 EXP、金錢、寶物
    exp = 0
    gold = 0
    treasures = []
    # 循環
    for enemy in $game_troop.enemies
      # 敵人不是隱藏狀態的情況下
      unless enemy.hidden
        # 取得EXP和增加金錢
        exp += enemy.exp
        gold += enemy.gold
        # 出現寶物判斷
        if rand(100) < enemy.treasure_prob
          if enemy.item_id > 0
            treasures.push($data_items[enemy.item_id])
          end
          if enemy.weapon_id > 0
            treasures.push($data_weapons[enemy.weapon_id])
          end
          if enemy.armor_id > 0
            treasures.push($data_armors[enemy.armor_id])
          end
        end
      end
    end
    # 限制寶物數最大值為6個
    treasures = treasures[0..5]
    # 取得 EXP
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if actor.cant_get_exp? == false
        last_level = actor.level
        actor.exp += exp
        if actor.level > last_level
          @status_window.level_up(i)
        end
      end
    end
    # 取得金錢
    $game_party.gain_gold(gold)
    # 取得寶物
    for item in treasures
      case item
      when RPG::Item
        $game_party.gain_item(item.id, 1)
      when RPG::Weapon
        $game_party.gain_weapon(item.id, 1)
      when RPG::Armor
        $game_party.gain_armor(item.id, 1)
      end
    end
    # 製作戰鬥結果視窗
    @result_window = Window_BattleResult.new(exp, gold, treasures)
    # 設定等待計時數值
    @phase5_wait_count = 100
  end
  #--------------------------------------------------------------------------
  # ● 畫面更新 (結束戰鬥回合)
  #--------------------------------------------------------------------------
  def update_phase5
    # 等待計數大於0的情況下
    if @phase5_wait_count > 0
      # 減少等待計數
      @phase5_wait_count -= 1
      # 等待計時數值為0的情況下
      if @phase5_wait_count == 0
        # 顯示結果視窗
        @result_window.visible = true
        # 清除主回合標誌
        $game_temp.battle_main_phase = false
        # 更新狀態視窗
        @status_window.refresh
      end
      return
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 戰鬥結束
      battle_end(0)
    end
  end
end
