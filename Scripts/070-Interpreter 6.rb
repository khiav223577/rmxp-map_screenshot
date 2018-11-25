#==============================================================================
# ■ Interpreter (第六部份)
#------------------------------------------------------------------------------
# 執行事件命令的編譯器。使用在 Game_System 類別和 Game_Event 類別的內部。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 戰鬥處理
  #--------------------------------------------------------------------------
  def command_301
    # 如果不是無效的隊伍
    if $data_troops[@parameters[0]] != nil
      # 設定中斷戰鬥的標誌
      $game_temp.battle_abort = true
      # 設定戰鬥取用的標誌
      $game_temp.battle_calling = true
      $game_temp.battle_troop_id = @parameters[0]
      $game_temp.battle_can_escape = @parameters[1]
      $game_temp.battle_can_lose = @parameters[2]
      # 設定返回取用
      current_indent = @list[@index].indent
      $game_temp.battle_proc = Proc.new { |n| @branch[current_indent] = n }
    end
    # 推進索引
    @index += 1
    # 結束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 勝利的情況下
  #--------------------------------------------------------------------------
  def command_601
    # 戰鬥結果為勝利的情況下
    if @branch[@list[@index].indent] == 0
      # 刪除分歧資料
      @branch.delete(@list[@index].indent)
      # 繼續
      return true
    end
    # 不符合條件的情況下 : 指令略過
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 逃跑的情況下
  #--------------------------------------------------------------------------
  def command_602
    # 戰鬥結果為逃跑的情況下
    if @branch[@list[@index].indent] == 1
      # 刪除分歧資料
      @branch.delete(@list[@index].indent)
      # 繼續
      return true
    end
    # 不符合條件的情況下 : 指令略過
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 失敗的情況下
  #--------------------------------------------------------------------------
  def command_603
    # 戰鬥結果為失敗的情況下
    if @branch[@list[@index].indent] == 2
      # 刪除分歧資料
      @branch.delete(@list[@index].indent)
      # 繼續
      return true
    end
    # 不符合條件的情況下 : 指令略過
    return command_skip
  end
  #--------------------------------------------------------------------------
  # ● 商店的處理
  #--------------------------------------------------------------------------
  def command_302
    # 設定戰鬥中斷的標誌
    $game_temp.battle_abort = true
    # 設定商店取用的標誌
    $game_temp.shop_calling = true
    # 設定商品列表的新項目
    $game_temp.shop_goods = [@parameters]
    # 循環
    loop do
      # 推進索引
      @index += 1
      # 如果下個事件指令的第二行(含以上)出現商店的情況下
      if @list[@index].code == 605
        # 在商品列表中添加新項目
        $game_temp.shop_goods.push(@list[@index].parameters)
      # 如果下個事件指令的第二行(含以上)沒有出現商店的情況下
      else
        # 結束
        return false
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 名稱輸入處理
  #--------------------------------------------------------------------------
  def command_303
    # 如果不是無效的角色
    if $data_actors[@parameters[0]] != nil
      # 設定戰鬥中斷的標誌
      $game_temp.battle_abort = true
      # 設定名稱輸入取用的標誌
      $game_temp.name_calling = true
      $game_temp.name_actor_id = @parameters[0]
      $game_temp.name_max_char = @parameters[1]
    end
    # 推進索引
    @index += 1
    # 結束
    return false
  end
  #--------------------------------------------------------------------------
  # ● 增減 HP
  #--------------------------------------------------------------------------
  def command_311
    # 取得管理數值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 處理重複
    iterate_actor(@parameters[0]) do |actor|
      # HP 不為 0 的情況下
      if actor.hp > 0
        # 變更 HP (如果死亡不被允許，就設定HP為1)
        if @parameters[4] == false and actor.hp + value <= 0
          actor.hp = 1
        else
          actor.hp += value
        end
      end
    end
    # 遊戲結束判斷
    $game_temp.gameover = $game_party.all_dead?
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增減 SP
  #--------------------------------------------------------------------------
  def command_312
    # 取得管理數值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 處理重複
    iterate_actor(@parameters[0]) do |actor|
      # 變更角色的 SP
      actor.sp += value
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 變更狀態
  #--------------------------------------------------------------------------
  def command_313
    # 處理重複
    iterate_actor(@parameters[0]) do |actor|
      # 變更狀態
      if @parameters[1] == 0
        actor.add_state(@parameters[2])
      else
        actor.remove_state(@parameters[2])
      end
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 全回復
  #--------------------------------------------------------------------------
  def command_314
    # 處理重複
    iterate_actor(@parameters[0]) do |actor|
      # 角色全回復
      actor.recover_all
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增減 EXP
  #--------------------------------------------------------------------------
  def command_315
    # 取得管理數值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 處理重複
    iterate_actor(@parameters[0]) do |actor|
      # 變更角色 EXP
      actor.exp += value
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增減等級
  #--------------------------------------------------------------------------
  def command_316
    # 取得管理數值
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 處理重複
    iterate_actor(@parameters[0]) do |actor|
      # 變更角色的等級
      actor.level += value
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增減能力值
  #--------------------------------------------------------------------------
  def command_317
    # 取得管理數值
    value = operate_value(@parameters[2], @parameters[3], @parameters[4])
    # 取得角色
    actor = $game_actors[@parameters[0]]
    # 變更能力值
    if actor != nil
      case @parameters[1]
      when 0  # MaxHP
        actor.maxhp += value
      when 1  # MaxSP
        actor.maxsp += value
      when 2  # 力量
        actor.str += value
      when 3  # 靈巧
        actor.dex += value
      when 4  # 速度
        actor.agi += value
      when 5  # 魔力
        actor.int += value
      end
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 增減特技
  #--------------------------------------------------------------------------
  def command_318
    # 取得角色
    actor = $game_actors[@parameters[0]]
    # 增減特技
    if actor != nil
      if @parameters[1] == 0
        actor.learn_skill(@parameters[2])
      else
        actor.forget_skill(@parameters[2])
      end
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 變更裝備
  #--------------------------------------------------------------------------
  def command_319
    # 取得角色
    actor = $game_actors[@parameters[0]]
    # 變更角色
    if actor != nil
      actor.equip(@parameters[1], @parameters[2])
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 變更角色的名字
  #--------------------------------------------------------------------------
  def command_320
    # 取得角色
    actor = $game_actors[@parameters[0]]
    # 變更名字
    if actor != nil
      actor.name = @parameters[1]
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 變更角色的職業
  #--------------------------------------------------------------------------
  def command_321
    # 取得角色
    actor = $game_actors[@parameters[0]]
    # 變更職業
    if actor != nil
      actor.class_id = @parameters[1]
    end
    # 繼續
    return true
  end
  #--------------------------------------------------------------------------
  # ● 變更角色的圖形
  #--------------------------------------------------------------------------
  def command_322
    # 取得角色
    actor = $game_actors[@parameters[0]]
    # 變更圖形
    if actor != nil
      actor.set_graphic(@parameters[1], @parameters[2],
        @parameters[3], @parameters[4])
    end
    # 更新角色
    $game_player.refresh
    # 繼續
    return true
  end
end
