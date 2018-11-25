#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 處理裝備畫面的類別。
#==============================================================================

class Scene_Equip
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #     actor_index : 角色索引
  #     equip_index : 裝備索引
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
    @equip_index = equip_index
  end
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 取得角色
    @actor = $game_party.actors[@actor_index]
    # 製作視窗
    @help_window = Window_Help.new
    @left_window = Window_EquipLeft.new(@actor)
    @right_window = Window_EquipRight.new(@actor)
    @item_window1 = Window_EquipItem.new(@actor, 0)
    @item_window2 = Window_EquipItem.new(@actor, 1)
    @item_window3 = Window_EquipItem.new(@actor, 2)
    @item_window4 = Window_EquipItem.new(@actor, 3)
    @item_window5 = Window_EquipItem.new(@actor, 4)
    # 聯結提示視窗
    @right_window.help_window = @help_window
    @item_window1.help_window = @help_window
    @item_window2.help_window = @help_window
    @item_window3.help_window = @help_window
    @item_window4.help_window = @help_window
    @item_window5.help_window = @help_window
    # 設定游標位置
    @right_window.index = @equip_index
    refresh
    # 執行轉變
    Graphics.transition
    # 主循環
    loop do
      # 更新遊戲畫面
      Graphics.update
      # 更新輸入訊息
      Input.update
      # 更新畫面
      update
      # 如果畫面切換的話的就中斷循環
      if $scene != self
        break
      end
    end
    # 準備轉變
    Graphics.freeze
    # 釋放視窗
    @help_window.dispose
    @left_window.dispose
    @right_window.dispose
    @item_window1.dispose
    @item_window2.dispose
    @item_window3.dispose
    @item_window4.dispose
    @item_window5.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def refresh
    # 設定物品視窗的可視狀態
    @item_window1.visible = (@right_window.index == 0)
    @item_window2.visible = (@right_window.index == 1)
    @item_window3.visible = (@right_window.index == 2)
    @item_window4.visible = (@right_window.index == 3)
    @item_window5.visible = (@right_window.index == 4)
    # 取得當前裝備中的物品
    item1 = @right_window.item
    # 設定當前的物品視窗到 @item_window
    case @right_window.index
    when 0
      @item_window = @item_window1
    when 1
      @item_window = @item_window2
    when 2
      @item_window = @item_window3
    when 3
      @item_window = @item_window4
    when 4
      @item_window = @item_window5
    end
    # 右側視窗被更新的情況下
    if @right_window.active
      # 刪除變更裝備後的能力
      @left_window.set_new_parameters(nil, nil, nil)
    end
    # 物品視窗被更新的情況下
    if @item_window.active
      # 取得現在選中的物品
      item2 = @item_window.item
      # 變更裝備
      last_hp = @actor.hp
      last_sp = @actor.sp
      @actor.equip(@right_window.index, item2 == nil ? 0 : item2.id)
      # 取得變更裝備後的能力值
      new_atk = @actor.atk
      new_pdef = @actor.pdef
      new_mdef = @actor.mdef
      # 返回到裝備
      @actor.equip(@right_window.index, item1 == nil ? 0 : item1.id)
      @actor.hp = last_hp
      @actor.sp = last_sp
      # 取出左側視窗
      @left_window.set_new_parameters(new_atk, new_pdef, new_mdef)
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 更新視窗
    @left_window.update
    @right_window.update
    @item_window.update
    refresh
    # 右側視窗被更新的情況下: 取用 update_right
    if @right_window.active
      update_right
      return
    end
    # 物品視窗被更新的情況下: 取用 update_item
    if @item_window.active
      update_item
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (右側視窗被更新的情況下)
  #--------------------------------------------------------------------------
  def update_right
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切換到選單畫面
      $scene = Scene_Menu.new(2)
      return
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 固定裝備的情況下
      if @actor.equip_fix?(@right_window.index)
        # 演奏循環 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 更新物品視窗
      @right_window.active = false
      @item_window.active = true
      @item_window.index = 0
      return
    end
    # 按下R鍵的情況下
    if Input.trigger?(Input::R)
      # 演奏游標 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至下一位角色
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # 切換到別的裝備畫面
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
      return
    end
    # 按下L鍵的情況下
    if Input.trigger?(Input::L)
      # 演奏游標 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至上一位角色
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # 切換到別的裝備畫面
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (物品視窗被更新的情況下)
  #--------------------------------------------------------------------------
  def update_item
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 更新右側視窗
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      return
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 演奏裝備 SE
      $game_system.se_play($data_system.equip_se)
      # 取得物品視窗現在選擇的裝備資料
      item = @item_window.item
      # 變更裝備
      @actor.equip(@right_window.index, item == nil ? 0 : item.id)
      # 更新右側視窗
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      # 再次製作右側視窗、物品視窗的內容
      @right_window.refresh
      @item_window.refresh
      return
    end
  end
end
