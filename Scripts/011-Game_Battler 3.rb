#==============================================================================
# ■ Game_Battler (第三部份)
#------------------------------------------------------------------------------
# 處理戰鬥者的類別。這個類別作為 Game_Actor 類別與 Game_Enemy 類別總綱來使用。
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ● 可以使用特技的判斷
  #     skill_id : 特技 ID
  #--------------------------------------------------------------------------
  def skill_can_use?(skill_id)
    # SP 不足的情況下不能使用該技能
    if $data_skills[skill_id].sp_cost > self.sp
      return false
    end
    # 無法戰鬥的情況下不能使用
    if dead?
      return false
    end
    # 沉默狀態的情況下、只能使用物理特技
    if $data_skills[skill_id].atk_f == 0 and self.restriction == 1
      return false
    end
    # 取得可以使用的時機
    occasion = $data_skills[skill_id].occasion
    # 戰鬥中的情況下
    if $game_temp.in_battle
      # [平時] 或者是 [戰鬥中] 可以使用
      return (occasion == 0 or occasion == 1)
    # 不是戰鬥中的情況下
    else
      # [平時] 或者是 [選單中] 可以使用
      return (occasion == 0 or occasion == 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 應用通常攻擊效果
  #     attacker : 攻擊者 (battler)
  #--------------------------------------------------------------------------
  def attack_effect(attacker)
    # 清除會心一擊標誌
    self.critical = false
    # 第一命中判斷
    hit_result = (rand(100) < attacker.hit)
    # 命中的情況下
    if hit_result == true
      # 計算基本傷害
      atk = [attacker.atk - self.pdef / 2, 0].max
      self.damage = atk * (20 + attacker.str) / 20
      # 屬性修正
      self.damage *= elements_correct(attacker.element_set)
      self.damage /= 100
      # 傷害符號正確的情況下
      if self.damage > 0
        # 會心一擊修正
        if rand(100) < 4 * attacker.dex / self.agi
          self.damage *= 2
          self.critical = true
        end
        # 防禦修正
        if self.guarding?
          self.damage /= 2
        end
      end
      # 分散
      if self.damage.abs > 0
        amp = [self.damage.abs * 15 / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # 第二命中判斷
      eva = 8 * self.agi / attacker.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
    end
    # 命中的情況下
    if hit_result == true
      # 狀態衝擊解除
      remove_states_shock
      # HP 的傷害計算
      self.hp -= self.damage
      # 狀態變化
      @state_changed = false
      states_plus(attacker.plus_state_set)
      states_minus(attacker.minus_state_set)
    # Miss 的情況下
    else
      # 傷害設置為 "Miss"
      self.damage = "Miss"
      # 清除會心一擊標誌
      self.critical = false
    end
    # 過程結束
    return true
  end
  #--------------------------------------------------------------------------
  # ● 應用特技效果
  #     user  : 特技的使用者 (battler)
  #     skill : 特技
  #--------------------------------------------------------------------------
  def skill_effect(user, skill)
    # 清除會心一擊標誌
    self.critical = false
    # 特技的效果範圍是 HP 1 以上的我方、自己的 HP 為 0、
    # 或者特技的效果範圍是 HP 0 的我方、自己的 HP 為 1 以上的情況下
    if ((skill.scope == 3 or skill.scope == 4) and self.hp == 0) or
       ((skill.scope == 5 or skill.scope == 6) and self.hp >= 1)
      # 過程結束
      return false
    end
    # 清除有效標誌
    effective = false
    # 共通事件 ID 是有效的情況下,設定為有效標誌
    effective |= skill.common_event_id > 0
    # 第一命中判斷
    hit = skill.hit
    if skill.atk_f > 0
      hit *= user.hit / 100
    end
    hit_result = (rand(100) < hit)
    # 不確定特技的情況下設定為有效標誌
    effective |= hit < 100
    # 命中的情況下
    if hit_result == true
      # 計算威力
      power = skill.power + user.atk * skill.atk_f / 100
      if power > 0
        power -= self.pdef * skill.pdef_f / 200
        power -= self.mdef * skill.mdef_f / 200
        power = [power, 0].max
      end
      # 計算倍率
      rate = 20
      rate += (user.str * skill.str_f / 100)
      rate += (user.dex * skill.dex_f / 100)
      rate += (user.agi * skill.agi_f / 100)
      rate += (user.int * skill.int_f / 100)
      # 計算基本傷害
      self.damage = power * rate / 20
      # 屬性修正
      self.damage *= elements_correct(skill.element_set)
      self.damage /= 100
      # 傷害符號正確的情況下
      if self.damage > 0
        # 防禦修正
        if self.guarding?
          self.damage /= 2
        end
      end
      # 分散
      if skill.variance > 0 and self.damage.abs > 0
        amp = [self.damage.abs * skill.variance / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # 第二命中判斷
      eva = 8 * self.agi / user.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva * skill.eva_f / 100
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
      # 不確定特技的情況下設定為有效標誌
      effective |= hit < 100
    end
    # 命中的情況下
    if hit_result == true
      # 威力 0 以外的物理攻擊的情況下
      if skill.power != 0 and skill.atk_f > 0
        # 狀態衝擊解除
        remove_states_shock
        # 設定有效標誌
        effective = true
      end
      # HP 的傷害減法運算
      last_hp = self.hp
      self.hp -= self.damage
      effective |= self.hp != last_hp
      # 狀態變化
      @state_changed = false
      effective |= states_plus(skill.plus_state_set)
      effective |= states_minus(skill.minus_state_set)
      # 威力為 0 的場合
      if skill.power == 0
        # 傷害設定為空的字串
        self.damage = ""
        # 狀態沒有變化的情況下
        unless @state_changed
          # 傷害設定為 "Miss"
          self.damage = "Miss"
        end
      end
    # Miss 的情況下
    else
      # 傷害設定為 "Miss"
      self.damage = "Miss"
    end
    # 不在戰鬥中的情況下
    unless $game_temp.in_battle
      # 傷害設定為 nil
      self.damage = nil
    end
    # 過程結束
    return effective
  end
  #--------------------------------------------------------------------------
  # ● 應用物品效果
  #     item : 物品
  #--------------------------------------------------------------------------
  def item_effect(item)
    # 清除會心一擊標誌
    self.critical = false
    # 物品的效果範圍是 HP 1 以上的我方、自己的 HP 為 0、
    # 或者物品的效果範圍是 HP 0 的我方、自己的 HP 為 1 以上的情況下
    if ((item.scope == 3 or item.scope == 4) and self.hp == 0) or
       ((item.scope == 5 or item.scope == 6) and self.hp >= 1)
      # 過程結束
      return false
    end
    # 清除有效標誌
    effective = false
    # 共通事件 ID 是有效的情況下,設定為有效標誌
    effective |= item.common_event_id > 0
    # 命中判斷
    hit_result = (rand(100) < item.hit)
    # 不確定特技的情況下設定為有效標誌
    effective |= item.hit < 100
    # 命中的情況
    if hit_result == true
      # 計算回復量
      recover_hp = maxhp * item.recover_hp_rate / 100 + item.recover_hp
      recover_sp = maxsp * item.recover_sp_rate / 100 + item.recover_sp
      if recover_hp < 0
        recover_hp += self.pdef * item.pdef_f / 20
        recover_hp += self.mdef * item.mdef_f / 20
        recover_hp = [recover_hp, 0].min
      end
      # 屬性修正
      recover_hp *= elements_correct(item.element_set)
      recover_hp /= 100
      recover_sp *= elements_correct(item.element_set)
      recover_sp /= 100
      # 分散
      if item.variance > 0 and recover_hp.abs > 0
        amp = [recover_hp.abs * item.variance / 100, 1].max
        recover_hp += rand(amp+1) + rand(amp+1) - amp
      end
      if item.variance > 0 and recover_sp.abs > 0
        amp = [recover_sp.abs * item.variance / 100, 1].max
        recover_sp += rand(amp+1) + rand(amp+1) - amp
      end
      # 回復量符號為負的情況下
      if recover_hp < 0
        # 防禦修正
        if self.guarding?
          recover_hp /= 2
        end
      end
      # 設定傷害值以及扣除HP值的恢復量
      self.damage = -recover_hp
      # HP 以及 SP 的回復
      last_hp = self.hp
      last_sp = self.sp
      self.hp += recover_hp
      self.sp += recover_sp
      effective |= self.hp != last_hp
      effective |= self.sp != last_sp
      # 狀態變化
      @state_changed = false
      effective |= states_plus(item.plus_state_set)
      effective |= states_minus(item.minus_state_set)
      # 能力上升值有效的情況下
      if item.parameter_type > 0 and item.parameter_points != 0
        # 能力值的分支
        case item.parameter_type
        when 1  # MaxHP
          @maxhp_plus += item.parameter_points
        when 2  # MaxSP
          @maxsp_plus += item.parameter_points
        when 3  # 力量
          @str_plus += item.parameter_points
        when 4  # 靈巧
          @dex_plus += item.parameter_points
        when 5  # 速度
          @agi_plus += item.parameter_points
        when 6  # 魔力
          @int_plus += item.parameter_points
        end
        # 設定有效標誌
        effective = true
      end
      # HP 回復率與回復量為 0 的情況下
      if item.recover_hp_rate == 0 and item.recover_hp == 0
        # 設定傷害為空的字串
        self.damage = ""
        # SP 回復率與回復量為 0、能力上升值無效的情況下
        if item.recover_sp_rate == 0 and item.recover_sp == 0 and
           (item.parameter_type == 0 or item.parameter_points == 0)
          # 狀態沒有變化的情況下
          unless @state_changed
            # 傷害設定為 "Miss"
            self.damage = "Miss"
          end
        end
      end
    # Miss 的情況下
    else
      # 傷害設定為 "Miss"
      self.damage = "Miss"
    end
    # 不在戰鬥中的情況下
    unless $game_temp.in_battle
      # 傷害設定為零(nil)
      self.damage = nil
    end
    # 過程結束
    return effective
  end
  #--------------------------------------------------------------------------
  # ● 應用連續傷害效果
  #--------------------------------------------------------------------------
  def slip_damage_effect
    # 設定傷害
    self.damage = self.maxhp / 10
    # 分散
    if self.damage.abs > 0
      amp = [self.damage.abs * 15 / 100, 1].max
      self.damage += rand(amp+1) + rand(amp+1) - amp
    end
    # HP 的傷害減法運算
    self.hp -= self.damage
    # 過程結束
    return true
  end
  #--------------------------------------------------------------------------
  # ● 屬性修正計算
  #     element_set : 屬性
  #--------------------------------------------------------------------------
  def elements_correct(element_set)
    # 無屬性的情況
    if element_set == []
      # 返回 100
      return 100
    end
    # 返回提供的屬性中最弱的屬性
    # ※定義 element_rate 的方法是由本身、 Game_Actor 類別和 Game_Enemy 類別
    #   所定義。
    weakest = -100
    for i in element_set
      weakest = [weakest, self.element_rate(i)].max
    end
    return weakest
  end
end
