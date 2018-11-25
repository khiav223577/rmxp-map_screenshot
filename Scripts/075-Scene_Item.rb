#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 處理物品畫面的類別。
#==============================================================================

class Scene_Item
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 製作提示視窗、物品視窗
    @help_window = Window_Help.new
    @item_window = Window_Item.new
    # 聯結提示視窗
    @item_window.help_window = @help_window
    # 製作目標視窗 (設定為不可視/不活動)
    @target_window = Window_Target.new
    @target_window.visible = false
    @target_window.active = false
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
      # 如果畫面切換就中斷循環
      if $scene != self
        break
      end
    end
    # 裝備轉變
    Graphics.freeze
    # 釋放視窗
    @help_window.dispose
    @item_window.dispose
    @target_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 更新視窗
    @help_window.update
    @item_window.update
    @target_window.update
    # 物品視窗被更新的情況下: 取用 update_item
    if @item_window.active
      update_item
      return
    end
    # 目標視窗被更新的情況下: 取用 update_target
    if @target_window.active
      update_target
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (物品視窗被激活的情況下)
  #--------------------------------------------------------------------------
  def update_item
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切換到選單畫面
      $scene = Scene_Menu.new(0)
      return
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 取得目前物品視窗選中的物品資料
      @item = @item_window.item
      # 不使用物品的情況下
      unless @item.is_a?(RPG::Item)
        # 演奏循環 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 不能使用的情況下
      unless $game_party.item_can_use?(@item.id)
        # 演奏循環 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 效果範圍是我方的情況下
      if @item.scope >= 3
        # 更新目標視窗
        @item_window.active = false
        @target_window.x = (@item_window.index + 1) % 2 * 304
        @target_window.visible = true
        @target_window.active = true
        # 設定效果範圍(單人/全體)的對應游標位置
        if @item.scope == 4 || @item.scope == 6
          @target_window.index = -1
        else
          @target_window.index = 0
        end
      # 效果在我方以外的情況下
      else
        # 共通事件 ID 有效的情況下
        if @item.common_event_id > 0
          # 預約取用共通事件
          $game_temp.common_event_id = @item.common_event_id
          # 演奏物品使用時的 SE
          $game_system.se_play(@item.menu_se)
          # 消耗物品的情況下
          if @item.consumable
            # 使用的物品數減1
            $game_party.lose_item(@item.id, 1)
            # 再取出物品視窗的項目
            @item_window.draw_item(@item_window.index)
          end
          # 切換到地圖畫面
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (目標視窗被更新的情況下)
  #--------------------------------------------------------------------------
  def update_target
    # 按下B鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 由於物品用完而不能使用的場合
      unless $game_party.item_can_use?(@item.id)
        # 再次製作物品視窗的內容
        @item_window.refresh
      end
      # 刪除目標視窗
      @item_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    # 按下C鍵的情況下
    if Input.trigger?(Input::C)
      # 如果物品用完的情況下
      if $game_party.item_number(@item.id) == 0
        # 演奏循環 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 目標是全體的情況下
      if @target_window.index == -1
        # 對同伴全體套用物品的使用效果
        used = false
        for i in $game_party.actors
          used |= i.item_effect(@item)
        end
      end
      # 目標是單體的情況下
      if @target_window.index >= 0
        # 對目標角色套用物品的使用效果
        target = $game_party.actors[@target_window.index]
        used = target.item_effect(@item)
      end
      # 使用物品的情況下
      if used
        # 演奏物品使用時的 SE
        $game_system.se_play(@item.menu_se)
        # 消耗物品的情況下
        if @item.consumable
          # 使用的物品數減1
          $game_party.lose_item(@item.id, 1)
          # 再取出物品視窗的項目
          @item_window.draw_item(@item_window.index)
        end
        # 再製作目標視窗的內容
        @target_window.refresh
        # 全滅的情況下
        if $game_party.all_dead?
          # 切換到遊戲結束畫面
          $scene = Scene_Gameover.new
          return
        end
        # 共通事件 ID 有效的情況下
        if @item.common_event_id > 0
          # 預約取用共通事件
          $game_temp.common_event_id = @item.common_event_id
          # 切換到地圖畫面
          $scene = Scene_Map.new
          return
        end
      end
      # 無法使用物品的情況下
      unless used
        # 演奏循環 SE
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end
