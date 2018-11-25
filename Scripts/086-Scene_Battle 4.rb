#==============================================================================
# ■ Scene_Battle (第四部份)
#------------------------------------------------------------------------------
# 處理戰鬥畫面的類別。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● 開始主回合
  #--------------------------------------------------------------------------
  def start_phase4
    # 轉移到回合4
    @phase = 4
    # 回合數計時數值
    $game_temp.battle_turn += 1
    # 搜索全頁的戰鬥事件
    for index in 0...$data_troops[@troop_id].pages.size
      # 取得事件頁
      page = $data_troops[@troop_id].pages[index]
      # 本頁的範圍是[回合]的情況下
      if page.span == 1
        # 設定已經執行標誌
        $game_temp.battle_event_flags[index] = false
      end
    end
    # 設定角色為非選擇狀態
    @actor_index = -1
    @active_battler = nil
    # 停止同伴指令視窗
    @party_command_window.active = false
    @party_command_window.visible = false
    # 停止角色指令視窗
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # 設定主回合標誌
    $game_temp.battle_main_phase = true
    # 製作敵人行動
    for enemy in $game_troop.enemies
      enemy.make_action
    end
    # 製作行動順序
    make_action_orders
    # 移動到步驟1
    @phase4_step = 1
  end
  #--------------------------------------------------------------------------
  # ● 製作行動循序
  #--------------------------------------------------------------------------
  def make_action_orders
    # 初始化序列 @action_battlers
    @action_battlers = []
    # 添加敵人到 @action_battlers 序列
    for enemy in $game_troop.enemies
      @action_battlers.push(enemy)
    end
    # 添加角色到 @action_battlers 序列
    for actor in $game_party.actors
      @action_battlers.push(actor)
    end
    # 確定全體的行動速度
    for battler in @action_battlers
      battler.make_action_speed
    end
    # 按照行動速度從大到小排列
    @action_battlers.sort! {|a,b|
      b.current_action.speed - a.current_action.speed }
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (主回合)
  #--------------------------------------------------------------------------
  def update_phase4
    case @phase4_step
    when 1
      update_phase4_step1
    when 2
      update_phase4_step2
    when 3
      update_phase4_step3
    when 4
      update_phase4_step4
    when 5
      update_phase4_step5
    when 6
      update_phase4_step6
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (主回合步驟 1 : 準備行動)
  #--------------------------------------------------------------------------
  def update_phase4_step1
    # 隱藏提示視窗
    @help_window.visible = false
    # 判斷勝敗
    if judge
      # 勝利或者失敗的情況下 : 過程結束
      return
    end
    # 強制行動的戰鬥者不存在的情況下
    if $game_temp.forcing_battler == nil
      # 設定戰鬥事件
      setup_battle_event
      # 執行戰鬥事件中的情況下
      if $game_system.battle_interpreter.running?
        return
      end
    end
    # 強制行動的戰鬥者存在的情況下
    if $game_temp.forcing_battler != nil
      # 加入前端後移動
      @action_battlers.delete($game_temp.forcing_battler)
      @action_battlers.unshift($game_temp.forcing_battler)
    end
    # 未行動的戰鬥者不存在的情況下 (全員已經行動)
    if @action_battlers.size == 0
      # 開始同伴命令回合
      start_phase2
      return
    end
    # 初始化動畫 ID 和共通事件 ID
    @animation1_id = 0
    @animation2_id = 0
    @common_event_id = 0
    # 未行動的戰鬥者移動到序列的前端
    @active_battler = @action_battlers.shift
    # 如果已經在戰鬥之外的情況下
    if @active_battler.index == nil
      return
    end
    # 連續傷害
    if @active_battler.hp > 0 and @active_battler.slip_damage?
      @active_battler.slip_damage_effect
      @active_battler.damage_pop = true
    end
    # 自然解除狀態
    @active_battler.remove_states_auto
    # 更新狀態視窗
    @status_window.refresh
    # 移至步驟2
    @phase4_step = 2
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (主回合步驟 2 : 開始行動)
  #--------------------------------------------------------------------------
  def update_phase4_step2
    # 如果不是強制行動
    unless @active_battler.current_action.forcing
      # 限制為[敵人為普通攻擊]或[我方為普通攻擊]的情況下
      if @active_battler.restriction == 2 or @active_battler.restriction == 3
        # 設定行動為攻擊
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
      end
      # 限制為[不能行動]的情況下
      if @active_battler.restriction == 4
        # 清除行動強制目標的戰鬥者
        $game_temp.forcing_battler = nil
        # 移至步驟1
        @phase4_step = 1
        return
      end
    end
    # 清除目標戰鬥者
    @target_battlers = []
    # 行動種類分歧
    case @active_battler.current_action.kind
    when 0  # 基本
      make_basic_action_result
    when 1  # 特技
      make_skill_action_result
    when 2  # 物品
      make_item_action_result
    end
    # 移至步驟3
    if @phase4_step == 2
      @phase4_step = 3
    end
  end
  #--------------------------------------------------------------------------
  # ● 製作基本行動結果
  #--------------------------------------------------------------------------
  def make_basic_action_result
    # 攻擊的情況下
    if @active_battler.current_action.basic == 0
      # 設定攻擊 ID
      @animation1_id = @active_battler.animation1_id
      @animation2_id = @active_battler.animation2_id
      # 行動方的戰鬥者是敵人的情況下
      if @active_battler.is_a?(Game_Enemy)
        if @active_battler.restriction == 3
          target = $game_troop.random_target_enemy
        elsif @active_battler.restriction == 2
          target = $game_party.random_target_actor
        else
          index = @active_battler.current_action.target_index
          target = $game_party.smooth_target_actor(index)
        end
      end
      # 行動方的戰鬥者是角色的情況下
      if @active_battler.is_a?(Game_Actor)
        if @active_battler.restriction == 3
          target = $game_party.random_target_actor
        elsif @active_battler.restriction == 2
          target = $game_troop.random_target_enemy
        else
          index = @active_battler.current_action.target_index
          target = $game_troop.smooth_target_enemy(index)
        end
      end
      # 設定目標方的戰鬥者序列
      @target_battlers = [target]
      # 應用通常攻擊效果
      for target in @target_battlers
        target.attack_effect(@active_battler)
      end
      return
    end
    # 防禦的情況下
    if @active_battler.current_action.basic == 1
      # 提示視窗顯示"防禦"
      @help_window.set_text($data_system.words.guard, 1)
      return
    end
    # 逃跑的情況下
    if @active_battler.is_a?(Game_Enemy) and
       @active_battler.current_action.basic == 2
      # 提示視窗顯示"逃跑"
      @help_window.set_text("逃跑", 1)
      # 逃跑
      @active_battler.escape
      return
    end
    # 什麼也不做的情況下
    if @active_battler.current_action.basic == 3
      # 清除強制行動目標的戰鬥者
      $game_temp.forcing_battler = nil
      # 移至步驟1
      @phase4_step = 1
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 設定物品或特技目標方的戰鬥者
  #     scope : 特技或者是物品的範圍
  #--------------------------------------------------------------------------
  def set_target_battlers(scope)
    # 行動方的戰鬥者是敵人的情況下
    if @active_battler.is_a?(Game_Enemy)
      # 效果範圍分歧
      case scope
      when 1  # 敵方單人
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 2  # 敵方全體
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 3  # 我方單人
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 4  # 我方全體
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 5  # 我方單人 (HP 0) 
        index = @active_battler.current_action.target_index
        enemy = $game_troop.enemies[index]
        if enemy != nil and enemy.hp0?
          @target_battlers.push(enemy)
        end
      when 6  # 我方全體 (HP 0) 
        for enemy in $game_troop.enemies
          if enemy != nil and enemy.hp0?
            @target_battlers.push(enemy)
          end
        end
      when 7  # 使用者
        @target_battlers.push(@active_battler)
      end
    end
    # 行動方的戰鬥者是角色的情況下
    if @active_battler.is_a?(Game_Actor)
      # 效果範圍分歧
      case scope
      when 1  # 敵方單人
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 2  # 敵方全體
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 3  # 我方單人
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 4  # 我方全體
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 5  # 我方單人 (HP 0) 
        index = @active_battler.current_action.target_index
        actor = $game_party.actors[index]
        if actor != nil and actor.hp0?
          @target_battlers.push(actor)
        end
      when 6  # 我方全體 (HP 0) 
        for actor in $game_party.actors
          if actor != nil and actor.hp0?
            @target_battlers.push(actor)
          end
        end
      when 7  # 使用者
        @target_battlers.push(@active_battler)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 製作特技行動結果
  #--------------------------------------------------------------------------
  def make_skill_action_result
    # 取得特技
    @skill = $data_skills[@active_battler.current_action.skill_id]
    # 如果不是強制行動
    unless @active_battler.current_action.forcing
      # 因為SP耗盡而無法使用的情況下
      unless @active_battler.skill_can_use?(@skill.id)
        # 清除強制行動目標的戰鬥者
        $game_temp.forcing_battler = nil
        # 移至步驟1
        @phase4_step = 1
        return
      end
    end
    # 消耗SP
    @active_battler.sp -= @skill.sp_cost
    # 更新狀態視窗
    @status_window.refresh
    # 在提示視窗顯示特技名稱
    @help_window.set_text(@skill.name, 1)
    # 設定動畫 ID
    @animation1_id = @skill.animation1_id
    @animation2_id = @skill.animation2_id
    # 設定共通事件 ID
    @common_event_id = @skill.common_event_id
    # 設定目標側戰鬥者
    set_target_battlers(@skill.scope)
    # 應用特技效果
    for target in @target_battlers
      target.skill_effect(@active_battler, @skill)
    end
  end
  #--------------------------------------------------------------------------
  # ● 製作物品行動結果
  #--------------------------------------------------------------------------
  def make_item_action_result
    # 取得物品
    @item = $data_items[@active_battler.current_action.item_id]
    # 因為物品耗盡而無法使用的情況下
    unless $game_party.item_can_use?(@item.id)
      # 移至步驟1
      @phase4_step = 1
      return
    end
    # 消耗品的情況下
    if @item.consumable
      # 使用的物品減1
      $game_party.lose_item(@item.id, 1)
    end
    # 在提示視窗顯示物品名稱
    @help_window.set_text(@item.name, 1)
    # 設定動畫 ID
    @animation1_id = @item.animation1_id
    @animation2_id = @item.animation2_id
    # 設定共通事件 ID
    @common_event_id = @item.common_event_id
    # 確定目標
    index = @active_battler.current_action.target_index
    target = $game_party.smooth_target_actor(index)
    # 設定目標側戰鬥者
    set_target_battlers(@item.scope)
    # 應用物品效果
    for target in @target_battlers
      target.item_effect(@item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (主回合步驟 3 : 行動方動畫)
  #--------------------------------------------------------------------------
  def update_phase4_step3
    # 行動方動畫 (ID 為 0 的情況下是白色閃爍)
    if @animation1_id == 0
      @active_battler.white_flash = true
    else
      @active_battler.animation_id = @animation1_id
      @active_battler.animation_hit = true
    end
    # 移至步驟4
    @phase4_step = 4
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (主回合步驟 4 : 對像方動畫)
  #--------------------------------------------------------------------------
  def update_phase4_step4
    # 目標方動畫
    for target in @target_battlers
      target.animation_id = @animation2_id
      target.animation_hit = (target.damage != "Miss")
    end
    # 限制動畫長度、最低8幅畫面
    @wait_count = 8
    # 移至步驟5
    @phase4_step = 5
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (主回合步驟 5 : 顯示傷害)
  #--------------------------------------------------------------------------
  def update_phase4_step5
    # 隱藏提示視窗
    @help_window.visible = false
    # 更新狀態視窗
    @status_window.refresh
    # 顯示傷害
    for target in @target_battlers
      if target.damage != nil
        target.damage_pop = true
      end
    end
    # 移至步驟6
    @phase4_step = 6
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (主回合步驟 6 : 更新)
  #--------------------------------------------------------------------------
  def update_phase4_step6
    # 清除強制行動目標的戰鬥者
    $game_temp.forcing_battler = nil
    # 共通事件 ID 有效的情況下
    if @common_event_id > 0
      # 設定事件
      common_event = $data_common_events[@common_event_id]
      $game_system.battle_interpreter.setup(common_event.list, 0)
    end
    # 移至步驟1
    @phase4_step = 1
  end
end
