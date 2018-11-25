#==============================================================================
# ■ Game_BattleAction
#------------------------------------------------------------------------------
# 處理行動 (戰鬥中的行動) 的類別。使用在 Game_Battler 類別的內部。
#==============================================================================

class Game_BattleAction
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_accessor :speed                    # 速度
  attr_accessor :kind                     # 種類 (基本 / 特技 / 物品)
  attr_accessor :basic                    # 基本 (攻擊 / 防禦 / 逃跑)
  attr_accessor :skill_id                 # 特技 ID
  attr_accessor :item_id                  # 物品 ID
  attr_accessor :target_index             # 目標索引
  attr_accessor :forcing                  # 強制標誌
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #--------------------------------------------------------------------------
  def initialize
    clear
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    @speed = 0
    @kind = 0
    @basic = 3
    @skill_id = 0
    @item_id = 0
    @target_index = -1
    @forcing = false
  end
  #--------------------------------------------------------------------------
  # ● 有效判斷
  #--------------------------------------------------------------------------
  def valid?
    return (not (@kind == 0 and @basic == 3))
  end
  #--------------------------------------------------------------------------
  # ● 我方單人使用判斷
  #--------------------------------------------------------------------------
  def for_one_friend?
    # 種類為特級、效果範圍是我方單人 (包含 HP 0) 的情況
    if @kind == 1 and [3, 5].include?($data_skills[@skill_id].scope)
      return true
    end
    # 種類為物品、效果範圍是我方單人 (包含 HP 0) 的情況
    if @kind == 2 and [3, 5].include?($data_items[@item_id].scope)
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 我方單人用 (HP 0) 判斷
  #--------------------------------------------------------------------------
  def for_one_friend_hp0?
    # 種類為特級、效果範圍是我方單人 (HP 0) 的情況
    if @kind == 1 and [5].include?($data_skills[@skill_id].scope)
      return true
    end
    # 種類為物品、效果範圍是我方單人 (HP 0) 的情況
    if @kind == 2 and [5].include?($data_items[@item_id].scope)
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 隨機目標 (角色用)
  #--------------------------------------------------------------------------
  def decide_random_target_for_actor
    # 效果範圍的分歧
    if for_one_friend_hp0?
      battler = $game_party.random_target_actor_hp0
    elsif for_one_friend?
      battler = $game_party.random_target_actor
    else
      battler = $game_troop.random_target_enemy
    end
    # 目標存在的話取得索引、目標不存在的情況下清除行動
    if battler != nil
      @target_index = battler.index
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 隨機目標 (敵人用)
  #--------------------------------------------------------------------------
  def decide_random_target_for_enemy
    # 效果範圍的分歧
    if for_one_friend_hp0?
      battler = $game_troop.random_target_enemy_hp0
    elsif for_one_friend?
      battler = $game_troop.random_target_enemy
    else
      battler = $game_party.random_target_actor
    end
    # 目標存在的話取得索引、目標不存在的情況下清除行動
    if battler != nil
      @target_index = battler.index
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 最後的目標 (角色用)
  #--------------------------------------------------------------------------
  def decide_last_target_for_actor
    # 效果範圍是我方單人以及行動者、以外的的敵人
    if @target_index == -1
      battler = nil
    elsif for_one_friend?
      battler = $game_party.actors[@target_index]
    else
      battler = $game_troop.enemies[@target_index]
    end
    # 目標不存在的情況下清除行動
    if battler == nil or not battler.exist?
      clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 最後的目標 (敵人用)
  #--------------------------------------------------------------------------
  def decide_last_target_for_enemy
    # 效果範圍是我方單人以敵人、以外的的角色
    if @target_index == -1
      battler = nil
    elsif for_one_friend?
      battler = $game_troop.enemies[@target_index]
    else
      battler = $game_party.actors[@target_index]
    end
    # 目標不存在的情況下清除行動
    if battler == nil or not battler.exist?
      clear
    end
  end
end
