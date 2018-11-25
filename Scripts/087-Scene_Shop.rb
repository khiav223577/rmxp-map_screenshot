#==============================================================================
# ■ Scene_Shop
#------------------------------------------------------------------------------
# 處理商店畫面的類別。
#==============================================================================

class Scene_Shop
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 製作提示視窗
    @help_window = Window_Help.new
    # 製作指令視窗
    @command_window = Window_ShopCommand.new
    # 製作金錢視窗
    @gold_window = Window_Gold.new
    @gold_window.x = 480
    @gold_window.y = 64
    # 製作時間視窗
    @dummy_window = Window_Base.new(0, 128, 640, 352)
    # 製作購買視窗
    @buy_window = Window_ShopBuy.new($game_temp.shop_goods)
    @buy_window.active = false
    @buy_window.visible = false
    @buy_window.help_window = @help_window
    # 製作賣出視窗
    @sell_window = Window_ShopSell.new
    @sell_window.active = false
    @sell_window.visible = false
    @sell_window.help_window = @help_window
    # 製作數量輸入視窗
    @number_window = Window_ShopNumber.new
    @number_window.active = false
    @number_window.visible = false
    # 製作狀態視窗
    @status_window = Window_ShopStatus.new
    @status_window.visible = false
    # 執行過渡
    Graphics.transition
    # 主循環
    loop do
      # 更新遊戲畫面
      Graphics.update
      # 更新輸入訊息
      Input.update
      # 更新畫面
      update
      # 如果畫面切換的話就中斷循環
      if $scene != self
        break
      end
    end
    # 準備過渡
    Graphics.freeze
    # 釋放視窗所佔的記憶體空間
    @help_window.dispose
    @command_window.dispose
    @gold_window.dispose
    @dummy_window.dispose
    @buy_window.dispose
    @sell_window.dispose
    @number_window.dispose
    @status_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 更新視窗
    @help_window.update
    @command_window.update
    @gold_window.update
    @dummy_window.update
    @buy_window.update
    @sell_window.update
    @number_window.update
    @status_window.update
    # 指令視窗啟動的情況下: 取用 update_command
    if @command_window.active
      update_command
      return
    end
    # 購買視窗啟動的情況下: 取用 update_buy
    if @buy_window.active
      update_buy
      return
    end
    # 賣出視窗啟動的情況下: 取用 update_sell
    if @sell_window.active
      update_sell
      return
    end
    # 個數輸入視窗啟動的情況下: 取用 update_number
    if @number_window.active
      update_number
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (指令視窗啟動的情況下)
  #--------------------------------------------------------------------------
  def update_command
    # 按下 B 鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切換到地圖畫面
      $scene = Scene_Map.new
      return
    end
    # 按下 C 鍵的情況下
    if Input.trigger?(Input::C)
      # 命令視窗游標位置分歧
      case @command_window.index
      when 0  # 購買
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 視窗狀態轉向購買模式
        @command_window.active = false
        @dummy_window.visible = false
        @buy_window.active = true
        @buy_window.visible = true
        @buy_window.refresh
        @status_window.visible = true
      when 1  # 賣出
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 視窗狀態轉向賣出模式
        @command_window.active = false
        @dummy_window.visible = false
        @sell_window.active = true
        @sell_window.visible = true
        @sell_window.refresh
      when 2  # 取消
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 切換到地圖畫面
        $scene = Scene_Map.new
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (購買視窗啟動的情況下)
  #--------------------------------------------------------------------------
  def update_buy
    # 設定狀態視窗的物品
    @status_window.item = @buy_window.item
    # 按下 B 鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 視窗狀態轉向初期模式
      @command_window.active = true
      @dummy_window.visible = true
      @buy_window.active = false
      @buy_window.visible = false
      @status_window.visible = false
      @status_window.item = nil
      # 刪除提示內容
      @help_window.set_text("")
      return
    end
    # 按下 C 鍵的情況下
    if Input.trigger?(Input::C)
      # 取得物品
      @item = @buy_window.item
      # 物品無效的情況下、或者價格在所持金以上的情況下
      if @item == nil or @item.price > $game_party.gold
        # 演奏凍結 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 取得物品所持數
      case @item
      when RPG::Item
        number = $game_party.item_number(@item.id)
      when RPG::Weapon
        number = $game_party.weapon_number(@item.id)
      when RPG::Armor
        number = $game_party.armor_number(@item.id)
      end
      # 如果已經擁有了 99 個情況下
      if number == 99
        # 演奏凍結 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 計算可以最多購買的數量
      max = @item.price == 0 ? 99 : $game_party.gold / @item.price
      max = [max, 99 - number].min
      # 視窗狀態轉向數值輸入模式
      @buy_window.active = false
      @buy_window.visible = false
      @number_window.set(@item, max, @item.price)
      @number_window.active = true
      @number_window.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 畫面更新 (賣出視窗啟動的情況下)
  #--------------------------------------------------------------------------
  def update_sell
    # 按下 B 鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 視窗狀態轉向初期模式
      @command_window.active = true
      @dummy_window.visible = true
      @sell_window.active = false
      @sell_window.visible = false
      @status_window.item = nil
      # 刪除提示內容
      @help_window.set_text("")
      return
    end
    # 按下 C 鍵的情況下
    if Input.trigger?(Input::C)
      # 取得物品
      @item = @sell_window.item
      # 設定狀態視窗的物品
      @status_window.item = @item
      # 物品無效的情況下、或者價格為 0 (不能賣出) 的情況下
      if @item == nil or @item.price == 0
        # 演奏凍結 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 取得物品的所持數
      case @item
      when RPG::Item
        number = $game_party.item_number(@item.id)
      when RPG::Weapon
        number = $game_party.weapon_number(@item.id)
      when RPG::Armor
        number = $game_party.armor_number(@item.id)
      end
      # 最大賣出個數 = 物品的所持數
      max = number
      # 視窗狀態轉向個數輸入模式
      @sell_window.active = false
      @sell_window.visible = false
      @number_window.set(@item, max, @item.price / 2)
      @number_window.active = true
      @number_window.visible = true
      @status_window.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (個數輸入視窗啟動的情況下)
  #--------------------------------------------------------------------------
  def update_number
    # 按下 B 鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 設定個數輸入視窗為不活動/非可視狀態
      @number_window.active = false
      @number_window.visible = false
      # 命令視窗游標位置分歧
      case @command_window.index
      when 0  # 購買
        # 視窗狀態轉向購買模式
        @buy_window.active = true
        @buy_window.visible = true
      when 1  # 賣出
        # 視窗狀態轉向賣出模式
        @sell_window.active = true
        @sell_window.visible = true
        @status_window.visible = false
      end
      return
    end
    # 按下 C 鍵的情況下
    if Input.trigger?(Input::C)
      # 演奏商店 SE
      $game_system.se_play($data_system.shop_se)
      # 設定個數輸入視窗為不活動/非可視狀態
      @number_window.active = false
      @number_window.visible = false
      # 命令視窗游標位置分歧
      case @command_window.index
      when 0  # 購買
        # 購買處理
        $game_party.lose_gold(@number_window.number * @item.price)
        case @item
        when RPG::Item
          $game_party.gain_item(@item.id, @number_window.number)
        when RPG::Weapon
          $game_party.gain_weapon(@item.id, @number_window.number)
        when RPG::Armor
          $game_party.gain_armor(@item.id, @number_window.number)
        end
        # 更新各視窗
        @gold_window.refresh
        @buy_window.refresh
        @status_window.refresh
        # 視窗狀態轉向購買模式
        @buy_window.active = true
        @buy_window.visible = true
      when 1  # 賣出
        # 賣出處理
        $game_party.gain_gold(@number_window.number * (@item.price / 2))
        case @item
        when RPG::Item
          $game_party.lose_item(@item.id, @number_window.number)
        when RPG::Weapon
          $game_party.lose_weapon(@item.id, @number_window.number)
        when RPG::Armor
          $game_party.lose_armor(@item.id, @number_window.number)
        end
        # 更新各視窗
        @gold_window.refresh
        @sell_window.refresh
        @status_window.refresh
        # 視窗狀態轉向賣出模式
        @sell_window.active = true
        @sell_window.visible = true
        @status_window.visible = false
      end
      return
    end
  end
end
