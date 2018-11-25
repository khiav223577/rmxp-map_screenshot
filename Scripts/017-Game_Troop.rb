#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　處理隊伍的類別。本類別的實例請參考 $game_troop。
#==============================================================================

class Game_Troop
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #--------------------------------------------------------------------------
  def initialize
    # 建立敵人陣勢
    @enemies = []
  end
  #--------------------------------------------------------------------------
  # ● 取得敵人
  #--------------------------------------------------------------------------
  def enemies
    return @enemies
  end
  #--------------------------------------------------------------------------
  # ● 設定
  #     troop_id : 敵人 ID
  #--------------------------------------------------------------------------
  def setup(troop_id)
    # 由敵人陣勢的設定來確定隊伍的設定
    @enemies = []
    troop = $data_troops[troop_id]
    for i in 0...troop.members.size
      enemy = $data_enemies[troop.members[i].enemy_id]
      if enemy != nil
        @enemies.push(Game_Enemy.new(troop_id, i))
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 目標敵人的隨機確定
  #     hp0 : 限制 HP 0 的敵人
  #--------------------------------------------------------------------------
  def random_target_enemy(hp0 = false)
    # 初始化輪流
    roulette = []
    # 循環
    for enemy in @enemies
      # 條件符合的情況下
      if (not hp0 and enemy.exist?) or (hp0 and enemy.hp0?)
        # 添加敵人到輪流
        roulette.push(enemy)
      end
    end
    # 隨機數為 0 的情況下
    if roulette.size == 0
      return nil
    end
    # 轉輪盤賭，決定敵人
    return roulette[rand(roulette.size)]
  end
  #--------------------------------------------------------------------------
  # ● 目標敵人的隨機確定 (HP 0)
  #--------------------------------------------------------------------------
  def random_target_enemy_hp0
    return random_target_enemy(true)
  end
  #--------------------------------------------------------------------------
  # ● 目標角色的順序確定
  #     enemy_index : 敵人索引
  #--------------------------------------------------------------------------
  def smooth_target_enemy(enemy_index)
    # 取得敵人
    enemy = @enemies[enemy_index]
    # 敵人存在的場合
    if enemy != nil and enemy.exist?
      return enemy
    end
    # 循環
    for enemy in @enemies
      # 敵人存在的場合
      if enemy.exist?
        return enemy
      end
    end
  end
end
