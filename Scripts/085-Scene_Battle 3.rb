#==============================================================================
# ■ Scene_Battle (第三部份)
#------------------------------------------------------------------------------
# 處理戰鬥畫面的類別。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● 開始角色命令回合
  #--------------------------------------------------------------------------
  def start_phase3
    # 轉移到回合3
    @phase = 3
    # 設定角色為非選擇狀態
    @actor_index = -1
    @active_battler = nil
    # 輸入下一個角色的命令
    phase3_next_actor
  end
  #--------------------------------------------------------------------------
  # ● 轉到輸入下一個角色的命令
  #--------------------------------------------------------------------------
  def phase3_next_actor
    # 循環
    begin
      # 角色的明暗效果OFF
      if @active_battler != nil
        @active_battler.blink = false
      end
      # 最後的角色的情況
      if @actor_index == $game_party.actors.size-1
        # 開始主回合
        start_phase4
        return
      end
      # 推進角色索引
      @actor_index += 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # 如果角色是在無法接受指令的狀態就再次嘗試
    end until @active_battler.inputable?
    # 設定角色的命令視窗
    phase3_setup_command_window
  end
  #--------------------------------------------------------------------------
  # ● 轉向前一個角色的命令輸入
  #--------------------------------------------------------------------------
  def phase3_prior_actor
    # 循環
    begin
      # 角色的明暗效果OFF
      if @active_battler != nil
        @active_battler.blink = false
      end
      # 最初的角色的情況下
      if @actor_index == 0
        # 開始同伴指令回合
        start_phase2
        return
      end
      # 返回角色索引
      @actor_index -= 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # 如果角色是在無法接受指令的狀態就再次嘗試
    end until @active_battler.inputable?
    # 設定角色的命令視窗
    phase3_setup_command_window
  end
  #--------------------------------------------------------------------------
  # ● 設定角色指令視窗
  #--------------------------------------------------------------------------
  def phase3_setup_command_window
    # 停止同伴指令視窗
    @party_command_window.active = false
    @party_command_window.visible = false
    # 啟動角色指令視窗
    @actor_command_window.active = true
    @actor_command_window.visible = true
    # 設定角色指令視窗的位置
    @actor_command_window.x = @actor_index * 160
    # 設定索引為0
    @actor_command_window.index = 0
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (角色命令回合)
  #--------------------------------------------------------------------------
  def update_phase3
    # 敵人游標有效的情況下
    if @enemy_arrow != nil
      update_phase3_enemy_select
    # 角色游標有效的情況下
    elsif @actor_arrow != nil
      update_phase3_actor_select
    # 特技視窗有效的情況下
    elsif @skill_window != nil
      update_phase3_skill_select
    # 物品視窗有效的情況下
    elsif @item_window != nil
      update_phase3_item_select
    # 角色指令視窗有效的情況下
    elsif @actor_command_window.active
      update_phase3_basic_command
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (角色命令回合 : 基本命令)
  #--------------------------------------------------------------------------
  def update_phase3_basic_command
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 轉向前一個角色的指令輸入
      phase3_prior_actor
      return
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 角色指令視窗與游標位置的分歧
      case @actor_command_window.index
      when 0  # 攻擊
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 設定行動
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
        # 開始選擇敵人
        start_enemy_select
      when 1  # 特技
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 設定行動
        @active_battler.current_action.kind = 1
        # 開始選擇特技
        start_skill_select
      when 2  # 防禦
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 設定行動
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 1
        # 轉向下一位角色的指令輸入
        phase3_next_actor
      when 3  # 物品
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 設定行動
        @active_battler.current_action.kind = 2
        # 開始選擇物品
        start_item_select
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (角色命令回合 : 選擇特技)
  #--------------------------------------------------------------------------
  def update_phase3_skill_select
    # 設定特技視窗為可視狀態
    @skill_window.visible = true
    # 更新特技視窗
    @skill_window.update
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 結束特技選擇
      end_skill_select
      return
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 取得特技視窗並且挑選資料
      @skill = @skill_window.skill
      # 無法使用的情況下
      if @skill == nil or not @active_battler.skill_can_use?(@skill.id)
        # 演奏循環 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 設定行動
      @active_battler.current_action.skill_id = @skill.id
      # 設定特技視窗為不可視狀態
      @skill_window.visible = false
      # 效果範圍是敵方單人的情況下
      if @skill.scope == 1
        # 開始選擇敵人
        start_enemy_select
      # 效果範圍是我方單人的情況下
      elsif @skill.scope == 3 or @skill.scope == 5
        # 開始選擇角色
        start_actor_select
      # 效果範圍不是單人的情況下
      else
        # 選擇特技結束
        end_skill_select
        # 轉到下一位角色的指令輸入
        phase3_next_actor
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (角色命令回合 : 選擇物品)
  #--------------------------------------------------------------------------
  def update_phase3_item_select
    # 設定物品視窗為可視狀態
    @item_window.visible = true
    # 更新物品視窗
    @item_window.update
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 選擇物品結束
      end_item_select
      return
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 取得物品視窗並且挑選資料
      @item = @item_window.item
      # 無法使用的情況下
      unless $game_party.item_can_use?(@item.id)
        # 演奏凍結 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 設定行動
      @active_battler.current_action.item_id = @item.id
      # 設定物品視窗為不可視狀態
      @item_window.visible = false
      # 效果範圍是敵方單人的情況下
      if @item.scope == 1
        # 開始選擇敵人
        start_enemy_select
      # 效果範圍是我方單人的情況下
      elsif @item.scope == 3 or @item.scope == 5
        # 開始選擇角色
        start_actor_select
      # 效果範圍不是單人的情況下
      else
        # 物品選擇結束
        end_item_select
        # 轉到下一位角色的指令輸入
        phase3_next_actor
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面畫面 (角色命令回合 : 選擇敵人)
  #--------------------------------------------------------------------------
  def update_phase3_enemy_select
    # 更新敵人箭頭
    @enemy_arrow.update
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 選擇敵人結束
      end_enemy_select
      return
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 設定行動
      @active_battler.current_action.target_index = @enemy_arrow.index
      # 選擇敵人結束
      end_enemy_select
      # 顯示特技視窗中的情況下
      if @skill_window != nil
        # 結束特技選擇
        end_skill_select
      end
      # 顯示物品視窗的情況下
      if @item_window != nil
        # 結束物品選擇
        end_item_select
      end
      # 轉到下一位角色的指令輸入
      phase3_next_actor
    end
  end
  #--------------------------------------------------------------------------
  # ● 畫面更新 (角色指令回合 : 選擇角色)
  #--------------------------------------------------------------------------
  def update_phase3_actor_select
    # 更新角色箭頭
    @actor_arrow.update
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 選擇角色結束
      end_actor_select
      return
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 設定行動
      @active_battler.current_action.target_index = @actor_arrow.index
      # 選擇角色結束
      end_actor_select
      # 顯示特技視窗中的情況下
      if @skill_window != nil
        # 結束特技選擇
        end_skill_select
      end
      # 顯示物品視窗的情況下
      if @item_window != nil
        # 結束物品選擇
        end_item_select
      end
      # 轉到下一位角色的指令輸入
      phase3_next_actor
    end
  end
  #--------------------------------------------------------------------------
  # ● 開始選擇敵人
  #--------------------------------------------------------------------------
  def start_enemy_select
    # 製作敵人箭頭
    @enemy_arrow = Arrow_Enemy.new(@spriteset.viewport1)
    # 聯結提示視窗
    @enemy_arrow.help_window = @help_window
    # 停止角色指令視窗
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 結束選擇敵人
  #--------------------------------------------------------------------------
  def end_enemy_select
    # 釋放敵人箭頭
    @enemy_arrow.dispose
    @enemy_arrow = nil
    # 指令為[戰鬥]的情況下
    if @actor_command_window.index == 0
      # 停止角色指令視窗
      @actor_command_window.active = true
      @actor_command_window.visible = true
      # 隱藏提示視窗
      @help_window.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 開始選擇角色
  #--------------------------------------------------------------------------
  def start_actor_select
    # 製作角色箭頭
    @actor_arrow = Arrow_Actor.new(@spriteset.viewport2)
    @actor_arrow.index = @actor_index
    # 聯結提示視窗
    @actor_arrow.help_window = @help_window
    # 停止角色指令視窗
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 結束選擇角色
  #--------------------------------------------------------------------------
  def end_actor_select
    # 釋放角色箭頭
    @actor_arrow.dispose
    @actor_arrow = nil
  end
  #--------------------------------------------------------------------------
  # ● 開始選擇特技
  #--------------------------------------------------------------------------
  def start_skill_select
    # 製作特技視窗
    @skill_window = Window_Skill.new(@active_battler)
    # 聯結提示視窗
    @skill_window.help_window = @help_window
    # 停止角色指令視窗
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 選擇特技結束
  #--------------------------------------------------------------------------
  def end_skill_select
    # 釋放特技視窗
    @skill_window.dispose
    @skill_window = nil
    # 隱藏提示視窗
    @help_window.visible = false
    # 停止角色指令視窗
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
  #--------------------------------------------------------------------------
  # ● 開始選擇物品
  #--------------------------------------------------------------------------
  def start_item_select
    # 製作物品視窗
    @item_window = Window_Item.new
    # 聯結提示視窗
    @item_window.help_window = @help_window
    # 停止角色指令視窗
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 結束選擇物品
  #--------------------------------------------------------------------------
  def end_item_select
    # 釋放物品視窗
    @item_window.dispose
    @item_window = nil
    # 隱藏提示視窗
    @help_window.visible = false
    # 停止角色指令視窗
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
end
