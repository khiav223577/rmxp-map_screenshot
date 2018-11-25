#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 處理同伴的類別。包含金錢以及物品的訊息。本類別的實例請參考 $game_party。
#==============================================================================

class Game_Party
  #--------------------------------------------------------------------------
  # ● 定義實例變量
  #--------------------------------------------------------------------------
  attr_reader   :actors                   # 角色
  attr_reader   :gold                     # 金錢
  attr_reader   :steps                    # 步數
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #--------------------------------------------------------------------------
  def initialize
    # 建立角色序列
    @actors = []
    # 初始化金錢與步數
    @gold = 0
    @steps = 0
    # 製作物品、武器、防具的所持數雜湊表
    @items = {}
    @weapons = {}
    @armors = {}
  end
  #--------------------------------------------------------------------------
  # ● 設定初期同伴
  #--------------------------------------------------------------------------
  def setup_starting_members
    @actors = []
    for i in $data_system.party_members
      @actors.push($game_actors[i])
    end
  end
  #--------------------------------------------------------------------------
  # ● 設定戰鬥測試用同伴
  #--------------------------------------------------------------------------
  def setup_battle_test_members
    @actors = []
    for battler in $data_system.test_battlers
      actor = $game_actors[battler.actor_id]
      actor.level = battler.level
      gain_weapon(battler.weapon_id, 1)
      gain_armor(battler.armor1_id, 1)
      gain_armor(battler.armor2_id, 1)
      gain_armor(battler.armor3_id, 1)
      gain_armor(battler.armor4_id, 1)
      actor.equip(0, battler.weapon_id)
      actor.equip(1, battler.armor1_id)
      actor.equip(2, battler.armor2_id)
      actor.equip(3, battler.armor3_id)
      actor.equip(4, battler.armor4_id)
      actor.recover_all
      @actors.push(actor)
    end
    @items = {}
    for i in 1...$data_items.size
      if $data_items[i].name != ""
        occasion = $data_items[i].occasion
        if occasion == 0 or occasion == 1
          @items[i] = 99
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 同伴成員的還原
  #--------------------------------------------------------------------------
  def refresh
    # 遊戲資料載入後角色目標直接從 $game_actors 分離。
    # 此外迴避由於載入造成的角色再設定的問題。
    new_actors = []
    for i in 0...@actors.size
      if $data_actors[@actors[i].id] != nil
        new_actors.push($game_actors[@actors[i].id])
      end
    end
    @actors = new_actors
  end
  #--------------------------------------------------------------------------
  # ● 取得最大等級
  #--------------------------------------------------------------------------
  def max_level
    # 同伴人數為 0 人的情況下
    if @actors.size == 0
      return 0
    end
    # 初始化本地變量等級(level)
    level = 0
    # 求得同伴的最大等級
    for actor in @actors
      if level < actor.level
        level = actor.level
      end
    end
    return level
  end
  #--------------------------------------------------------------------------
  # ● 加入同伴
  #     actor_id : 角色 ID
  #--------------------------------------------------------------------------
  def add_actor(actor_id)
    # 取得角色
    actor = $game_actors[actor_id]
    # 同伴人數未滿 4 人且本角色不在隊伍中的情況下
    if @actors.size < 4 and not @actors.include?(actor)
      # 添加角色
      @actors.push(actor)
      # 還原主角
      $game_player.refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● 角色離開
  #     actor_id : 角色 ID
  #--------------------------------------------------------------------------
  def remove_actor(actor_id)
    # 刪除角色
    @actors.delete($game_actors[actor_id])
    # 還原主角
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # ● 增加金錢 (減少)
  #     n : 金額
  #--------------------------------------------------------------------------
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 9999999].min
  end
  #--------------------------------------------------------------------------
  # ● 減少金錢
  #     n : 金額
  #--------------------------------------------------------------------------
  def lose_gold(n)
    # 扣除數字的數值並且呼叫 gain_gold 
    gain_gold(-n)
  end
  #--------------------------------------------------------------------------
  # ● 增加步數
  #--------------------------------------------------------------------------
  def increase_steps
    @steps = [@steps + 1, 9999999].min
  end
  #--------------------------------------------------------------------------
  # ● 取得物品的所持數
  #     item_id : 物品 ID
  #--------------------------------------------------------------------------
  def item_number(item_id)
    # 如果雜湊表的數值不存在就返回 0
    return @items.include?(item_id) ? @items[item_id] : 0
  end
  #--------------------------------------------------------------------------
  # ● 取得武器所持數
  #     weapon_id : 武器 ID
  #--------------------------------------------------------------------------
  def weapon_number(weapon_id)
    # 如果雜湊表的數值不存在就返回 0
    return @weapons.include?(weapon_id) ? @weapons[weapon_id] : 0
  end
  #--------------------------------------------------------------------------
  # ● 取得防具所持數
  #     armor_id : 防具 ID
  #--------------------------------------------------------------------------
  def armor_number(armor_id)
    # 如果雜湊表的數值不存在就返回 0
    return @armors.include?(armor_id) ? @armors[armor_id] : 0
  end
  #--------------------------------------------------------------------------
  # ● 增加物品 (減少)
  #     item_id : 物品 ID
  #     n       : 個數
  #--------------------------------------------------------------------------
  def gain_item(item_id, n)
    # 更新雜湊表數值的資料
    if item_id > 0
      @items[item_id] = [[item_number(item_id) + n, 0].max, 99].min
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加武器 (減少)
  #     weapon_id : 武器 ID
  #     n         : 個數
  #--------------------------------------------------------------------------
  def gain_weapon(weapon_id, n)
    # 更新雜湊表數值的資料
    if weapon_id > 0
      @weapons[weapon_id] = [[weapon_number(weapon_id) + n, 0].max, 99].min
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加防具 (減少)
  #     armor_id : 防具 ID
  #     n        : 個數
  #--------------------------------------------------------------------------
  def gain_armor(armor_id, n)
    # 更新雜湊表數值的資料
    if armor_id > 0
      @armors[armor_id] = [[armor_number(armor_id) + n, 0].max, 99].min
    end
  end
  #--------------------------------------------------------------------------
  # ● 減少物品
  #     item_id : 物品 ID
  #     n       : 個數
  #--------------------------------------------------------------------------
  def lose_item(item_id, n)
    # 扣除 gain_item 的數值
    gain_item(item_id, -n)
  end
  #--------------------------------------------------------------------------
  # ● 減少武器
  #     weapon_id : 武器 ID
  #     n         : 個數
  #--------------------------------------------------------------------------
  def lose_weapon(weapon_id, n)
    # 扣除 gain_weapon 的數值
    gain_weapon(weapon_id, -n)
  end
  #--------------------------------------------------------------------------
  # ● 減少防具
  #     armor_id : 防具 ID
  #     n        : 個數
  #--------------------------------------------------------------------------
  def lose_armor(armor_id, n)
    # 扣除 gain_armor 的數值
    gain_armor(armor_id, -n)
  end
  #--------------------------------------------------------------------------
  # ● 判斷物品可以使用
  #     item_id : 物品 ID
  #--------------------------------------------------------------------------
  def item_can_use?(item_id)
    # 物品個數為 0 的情況
    if item_number(item_id) == 0
      # 不能使用
      return false
    end
    # 取得可以使用的時候
    occasion = $data_items[item_id].occasion
    # 戰鬥的情況
    if $game_temp.in_battle
      # 可以使用時為 0 (平時) 或者是 1 (戰鬥時) 可以使用
      return (occasion == 0 or occasion == 1)
    end
    # 可以使用時為 0 (平時) 或者是 2 (選單時) 可以使用
    return (occasion == 0 or occasion == 2)
  end
  #--------------------------------------------------------------------------
  # ● 清除全體的行動
  #--------------------------------------------------------------------------
  def clear_actions
    # 清除全體同伴的行為
    for actor in @actors
      actor.current_action.clear
    end
  end
  #--------------------------------------------------------------------------
  # ● 可以輸入命令的判斷
  #--------------------------------------------------------------------------
  def inputable?
    # 如果一可以輸入命令就返回 true
    for actor in @actors
      if actor.inputable?
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 全滅判斷
  #--------------------------------------------------------------------------
  def all_dead?
    # 同伴人數為 0 的情況下
    if $game_party.actors.size == 0
      return false
    end
    # 同伴中無人 HP 在 0 以上
    for actor in @actors
      if actor.hp > 0
        return false
      end
    end
    # 全滅
    return true
  end
  #--------------------------------------------------------------------------
  # ● 檢查連續傷害 (地圖用)
  #--------------------------------------------------------------------------
  def check_map_slip_damage
    for actor in @actors
      if actor.hp > 0 and actor.slip_damage?
        actor.hp -= [actor.maxhp / 100, 1].max
        if actor.hp == 0
          $game_system.se_play($data_system.actor_collapse_se)
        end
        $game_screen.start_flash(Color.new(255,0,0,128), 4)
        $game_temp.gameover = $game_party.all_dead?
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 目標角色的隨機確定
  #     hp0 : 限制為 HP 0 的角色
  #--------------------------------------------------------------------------
  def random_target_actor(hp0 = false)
    # 初始化輪流
    roulette = []
    # 循環
    for actor in @actors
      # 符合條件的場合
      if (not hp0 and actor.exist?) or (hp0 and actor.hp0?)
        # 取得角色職業的位置 [位置]
        position = $data_classes[actor.class_id].position
        # 前鋒的話 n = 4、中堅的話 n = 3、後衛的話 n = 2
        n = 4 - position
        # 添加角色的輪流 n 回
        n.times do
          roulette.push(actor)
        end
      end
    end
    # 輪流大小為 0 的情況
    if roulette.size == 0
      return nil
    end
    # 轉輪盤賭，決定角色
    return roulette[rand(roulette.size)]
  end
  #--------------------------------------------------------------------------
  # ● 目標角色的隨機確定 (HP 0)
  #--------------------------------------------------------------------------
  def random_target_actor_hp0
    return random_target_actor(true)
  end
  #--------------------------------------------------------------------------
  # ● 目標角色的順序確定
  #     actor_index : 角色索引
  #--------------------------------------------------------------------------
  def smooth_target_actor(actor_index)
    # 取得目標
    actor = @actors[actor_index]
    # 目標存在的情況下
    if actor != nil and actor.exist?
      return actor
    end
    # 循環
    for actor in @actors
      # 目標存在的情況下
      if actor.exist?
        return actor
      end
    end
  end
end
