#==============================================================================
# ■ Interpreter (第七部份)
#------------------------------------------------------------------------------
# 執行事件命令的編譯器。使用在 Game_System 類別和 Game_Event 類別的內部。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 增減敵人的 HP
  #--------------------------------------------------------------------------
  def command_331
    # 取得管理數值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 處理循環
    iterate_enemy(@parameters[0]) do |enemy|
      # HP 不為 0 的情況下
      if enemy.hp > 0
        # 變更 HP (如果死亡不被允許，就設定HP為1)
        if @parameters[4] == false and enemy.hp + value <= 0
          enemy.hp = 1
        else
          enemy.hp += value
        end
      end
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增減敵人的 SP
  #--------------------------------------------------------------------------
  def command_332
    # 取得管理數值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 處理循環
    iterate_enemy(@parameters[0]) do |enemy|
      # 變更 SP
      enemy.sp += value
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 變更敵人的狀態
  #--------------------------------------------------------------------------
  def command_333
    # 處理循環
    iterate_enemy(@parameters[0]) do |enemy|
      # 狀態選項 [當作HP為0的狀態] 有效的情況下
      if $data_states[@parameters[2]].zero_hp
        # 清除不死身的標誌
        enemy.immortal = false
      end
      # 變更狀態
      if @parameters[1] == 0
        enemy.add_state(@parameters[2])
      else
        enemy.remove_state(@parameters[2])
      end
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 敵人的全回復
  #--------------------------------------------------------------------------
  def command_334
    # 處理循環
    iterate_enemy(@parameters[0]) do |enemy|
      # 全回復
      enemy.recover_all
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 敵人出現
  #--------------------------------------------------------------------------
  def command_335
    # 取得敵人
    enemy = $game_troop.enemies[@parameters[0]]
    # 清除隱藏的標誌
    if enemy != nil
      enemy.hidden = false
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 敵人變身
  #--------------------------------------------------------------------------
  def command_336
    # 取得敵人
    enemy = $game_troop.enemies[@parameters[0]]
    # 變身的處理
    if enemy != nil
      enemy.transform(@parameters[1])
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 顯示動畫
  #--------------------------------------------------------------------------
  def command_337
    # 處理循環
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # 戰鬥者存在的情況下
      if battler.exist?
        # 設定動畫 ID
        battler.animation_id = @parameters[2]
      end
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 傷害處理
  #--------------------------------------------------------------------------
  def command_338
    # 取得管理數值
    value = operate_value(0, @parameters[2], @parameters[3])
    # 處理循環
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # 戰鬥者存在的情況下
      if battler.exist?
        # 變更 HP
        battler.hp -= value
        # 如果在戰鬥中
        if $game_temp.in_battle
          # 設定傷害
          battler.damage = value
          battler.damage_pop = true
        end
      end
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 強制行動
  #--------------------------------------------------------------------------
  def command_339
    # 忽視是否在戰鬥中
    unless $game_temp.in_battle
      return true
    end
    # 忽視回合數為 0
    if $game_temp.battle_turn == 0
      return true
    end
    # 處理循環 (為了方便；這個步驟將不會重複)
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # 戰鬥者存在的情況下
      if battler.exist?
        # 設定行動
        battler.current_action.kind = @parameters[2]
        if battler.current_action.kind == 0
          battler.current_action.basic = @parameters[3]
        else
          battler.current_action.skill_id = @parameters[3]
        end
        # 設定行動目標
        if @parameters[4] == -2
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_last_target_for_enemy
          else
            battler.current_action.decide_last_target_for_actor
          end
        elsif @parameters[4] == -1
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_random_target_for_enemy
          else
            battler.current_action.decide_random_target_for_actor
          end
        elsif @parameters[4] >= 0
          battler.current_action.target_index = @parameters[4]
        end
        # 設定強制的標誌
        battler.current_action.forcing = true
        # 行動有效並且是 [使用立即執行] 的情況下
        if battler.current_action.valid? and @parameters[5] == 1
          # 設定強制目標的戰鬥者
          $game_temp.forcing_battler = battler
          # 推進索引
          @index += 1
          # 結束
          return false
        end
      end
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 戰鬥中斷
  #--------------------------------------------------------------------------
  def command_340
    # 設定戰鬥中斷的標誌
    $game_temp.battle_abort = true
    # 推進索引
    @index += 1
    # 結束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 取用選單畫面
  #--------------------------------------------------------------------------
  def command_351
    # 設定戰鬥中斷的標誌
    $game_temp.battle_abort = true
    # 設定取用選單的標誌
    $game_temp.menu_calling = true
    # 推進索引
    @index += 1
    # 結束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 取用存檔畫面
  #--------------------------------------------------------------------------
  def command_352
    # 設定戰鬥中斷的標誌
    $game_temp.battle_abort = true
    # 設定取用存檔的標誌
    $game_temp.save_calling = true
    # 推進索引
    @index += 1
    # 結束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 遊戲結束
  #--------------------------------------------------------------------------
  def command_353
    # 設定遊戲結束的標誌
    $game_temp.gameover = true
    # 結束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 返回標題畫面
  #--------------------------------------------------------------------------
  def command_354
    # 設定返回標題畫面的標誌
    $game_temp.to_title = true
    # 結束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 劇本
  #--------------------------------------------------------------------------
  def command_355
    # 設定劇本第一行
    script = @list[@index].parameters[0] + "\n"
    # 循環
    loop do
      # 下個事件指令在劇本第二行(含以上)的情況下
      if @list[@index+1].code == 655
        # 添加到劇本第二行(含以上)
        script += @list[@index+1].parameters[0] + "\n"
      # 如果事件指令不在劇本第二行(含以上)的情況下
      else
        # 中斷循環
        break
      end
      # 推進索引
      @index += 1
    end
    # 評估
    result = eval(script)
    # 返回數值為錯誤(false)的情況下
    if result == false
      # 結束
      return false
    end
    # 繼續
    return true
  end
end
