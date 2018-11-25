#==============================================================================
# ■ Game_Battler (第二部份)
#------------------------------------------------------------------------------
# 處理戰鬥者的類別。這個類別作為 Game_Actor 類別與 Game_Enemy 類別總綱來使用。
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ● 檢查狀態
  #     state_id : 狀態 ID
  #--------------------------------------------------------------------------
  def state?(state_id)
    # 如果可用的狀態設定已加入就返回 true
    return @states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● 判斷狀態是否為 full
  #     state_id : 狀態 ID
  #--------------------------------------------------------------------------
  def state_full?(state_id)
    # 如果可用的狀態設定未加入就返回 false
    unless self.state?(state_id)
      return false
    end
    # 如果持續回合數為 -1 (自動狀態) 就返回 true
    if @states_turn[state_id] == -1
      return true
    end
    # 如果持續回合數等於自然解除回合數的最低點時就返回 ture
    return @states_turn[state_id] == $data_states[state_id].hold_turn
  end
  #--------------------------------------------------------------------------
  # ● 附加狀態
  #     state_id : 狀態 ID
  #     force    : 強制附加標誌 (處理自動狀態時使用)
  #--------------------------------------------------------------------------
  def add_state(state_id, force = false)
    # 無效狀態的情況下
    if $data_states[state_id] == nil
      # 過程結束
      return
    end
    # 無法強制附加的情況下
    unless force
      # 循環已存在的狀態
      for i in @states
        # 新的狀態和已經存在的狀態 (-) 同時包含的情況下、
        # 本狀態不包含改變為新狀態的狀態變化 (-) 
        # (ex : 角色死亡無法戰鬥後又中毒時)
        if $data_states[i].minus_state_set.include?(state_id) and
           not $data_states[state_id].minus_state_set.include?(i)
          # 過程結束
          return
        end
      end
    end
    # 無法附加本狀態的情況下
    unless state?(state_id)
      # 狀態 ID 追加到 @states 序列中
      @states.push(state_id)
      # 選項 [當作 HP 0 的狀態] 的有效情況下
      if $data_states[state_id].zero_hp
        # HP 更改為 0
        @hp = 0
      end
      # 循環所有的狀態
      for i in 1...$data_states.size
        # 狀態變化 (+) 處理
        if $data_states[state_id].plus_state_set.include?(i)
          add_state(i)
        end
        # 狀態變化 (-) 處理
        if $data_states[state_id].minus_state_set.include?(i)
          remove_state(i)
        end
      end
      # 由大數值開始排序 (數值相等的情況下按照強度排序)
      @states.sort! do |a, b|
        state_a = $data_states[a]
        state_b = $data_states[b]
        if state_a.rating > state_b.rating
          -1
        elsif state_a.rating < state_b.rating
          +1
        elsif state_a.restriction > state_b.restriction
          -1
        elsif state_a.restriction < state_b.restriction
          +1
        else
          a <=> b
        end
      end
    end
    # 強制附加的場合
    if force
      # 設定為自然解除的最低回合數為 -1 (無效)
      @states_turn[state_id] = -1
    end
    # 不能強制附加的場合
    unless  @states_turn[state_id] == -1
      # 設定為自然解除的最低回合數
      @states_turn[state_id] = $data_states[state_id].hold_turn
    end
    # 無法行動的場合
    unless movable?
      # 清除行動
      @current_action.clear
    end
    # 檢查 HP 及 SP 的最大值
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  #--------------------------------------------------------------------------
  # ● 解除狀態
  #     state_id : 狀態 ID
  #     force    : 強制解除標誌 (處理自動狀態時使用)
  #--------------------------------------------------------------------------
  def remove_state(state_id, force = false)
    # 無法附加本狀態的情況下
    if state?(state_id)
      # 被強制附加的狀態、並不是強制解除的情況下
      if @states_turn[state_id] == -1 and not force
        # 過程結束
        return
      end
      # 現在的 HP 為 0 當作選項 [當作 HP 0 的狀態] 的有效場合
      if @hp == 0 and $data_states[state_id].zero_hp
        # 判斷是否有另外的 [當作 HP 0 的狀態] 狀態
        zero_hp = false
        for i in @states
          if i != state_id and $data_states[i].zero_hp
            zero_hp = true
          end
        end
        # 如果可以解除戰鬥不能、將 HP 更改為 1
        if zero_hp == false
          @hp = 1
        end
      end
      # 將狀態 ID 從 @states 隊列和 @states_turn hash 中刪除 
      @states.delete(state_id)
      @states_turn.delete(state_id)
    end
    # 檢查 HP 及 SP 的最大值
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  #--------------------------------------------------------------------------
  # ● 取得狀態的動畫 ID
  #--------------------------------------------------------------------------
  def state_animation_id
    # 無狀態附加的情況下
    if @states.size == 0
      return 0
    end
    # 返回機率最大狀態的動畫 ID
    return $data_states[@states[0]].animation_id
  end
  #--------------------------------------------------------------------------
  # ● 取得限制
  #--------------------------------------------------------------------------
  def restriction
    restriction_max = 0
    # 從目前附加的狀態中取得最大的限制(restriction) 
    for i in @states
      if $data_states[i].restriction >= restriction_max
        restriction_max = $data_states[i].restriction
      end
    end
    return restriction_max
  end
  #--------------------------------------------------------------------------
  # ● 判斷狀態 [無法獲得 EXP]
  #--------------------------------------------------------------------------
  def cant_get_exp?
    for i in @states
      if $data_states[i].cant_get_exp
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 判斷狀態 [無法迴避攻擊]
  #--------------------------------------------------------------------------
  def cant_evade?
    for i in @states
      if $data_states[i].cant_evade
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 判斷狀態 [連續傷害]
  #--------------------------------------------------------------------------
  def slip_damage?
    for i in @states
      if $data_states[i].slip_damage
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 解除戰鬥用狀態 (戰鬥結束時取出)
  #--------------------------------------------------------------------------
  def remove_states_battle
    for i in @states.clone
      if $data_states[i].battle_only
        remove_state(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 狀態自然解除 (回合改變時取出)
  #--------------------------------------------------------------------------
  def remove_states_auto
    for i in @states_turn.keys.clone
      if @states_turn[i] > 0
        @states_turn[i] -= 1
      elsif rand(100) < $data_states[i].auto_release_prob
        remove_state(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 狀態攻擊解除 (受到物理傷害時取用)
  #--------------------------------------------------------------------------
  def remove_states_shock
    for i in @states.clone
      if rand(100) < $data_states[i].shock_release_prob
        remove_state(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 狀態變化 (+) 的運用
  #     plus_state_set  : 狀態變化 (+)
  #--------------------------------------------------------------------------
  def states_plus(plus_state_set)
    # 清除有效標誌
    effective = false
    # 循環 (附加狀態)
    for i in plus_state_set
      # 無法防禦本狀態的情況下
      unless self.state_guard?(i)
        # 這個狀態如果不是 full 的話就設定有效標誌
        effective |= self.state_full?(i) == false
        # 狀態為 [不能抵抗] 的情況下
        if $data_states[i].nonresistance
          # 設定狀態變化標誌
          @state_changed = true
          # 附加狀態
          add_state(i)
        # 這個狀態不是 full 的情況下
        elsif self.state_full?(i) == false
          # 將狀態的有效率變換為機率、與隨機數值作比較
          if rand(100) < [0,100,80,60,40,20,0][self.state_ranks[i]]
            # 設定狀態變化標誌
            @state_changed = true
            # 附加狀態
            add_state(i)
          end
        end
      end
    end
    # 過程結束
    return effective
  end
  #--------------------------------------------------------------------------
  # ● 狀態變化 (-) 的應用
  #     minus_state_set : 狀態變化 (-)
  #--------------------------------------------------------------------------
  def states_minus(minus_state_set)
    # 清除有效標誌
    effective = false
    # 循環 (解除狀態)
    for i in minus_state_set
      # 如果這個狀態被附加則設定有效標誌
      effective |= self.state?(i)
      # 設置狀態變化標誌
      @state_changed = true
      # 解除狀態
      remove_state(i)
    end
    # 過程結束
    return effective
  end
end
