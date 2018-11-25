#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 處理選單畫面的類別。
#==============================================================================

class Scene_Menu
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #     menu_index : 命令游標的初期位置
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 製作命令視窗
    s1 = $data_system.words.item
    s2 = $data_system.words.skill
    s3 = $data_system.words.equip
    s4 = "狀態"
    s5 = "存檔"
    s6 = "結束遊戲"
    @command_window = Window_Command.new(160, [s1, s2, s3, s4, s5, s6])
    @command_window.index = @menu_index
    # 同伴人數為 0 的情況下
    if $game_party.actors.size == 0
      # 物品、特技、裝備、狀態無效化
      @command_window.disable_item(0)
      @command_window.disable_item(1)
      @command_window.disable_item(2)
      @command_window.disable_item(3)
    end
    # 禁止存檔的情況下
    if $game_system.save_disabled
      # 存檔無效
      @command_window.disable_item(4)
    end
    # 製作遊戲時間視窗
    @playtime_window = Window_PlayTime.new
    @playtime_window.x = 0
    @playtime_window.y = 224
    # 製作步數視窗
    @steps_window = Window_Steps.new
    @steps_window.x = 0
    @steps_window.y = 320
    # 製作金錢視窗
    @gold_window = Window_Gold.new
    @gold_window.x = 0
    @gold_window.y = 416
    # 製作狀態視窗
    @status_window = Window_MenuStatus.new
    @status_window.x = 160
    @status_window.y = 0
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
      # 如果切換畫面就中斷循環
      if $scene != self
        break
      end
    end
    # 準備過渡
    Graphics.freeze
    # 釋放視窗所佔的記憶體空間
    @command_window.dispose
    @playtime_window.dispose
    @steps_window.dispose
    @gold_window.dispose
    @status_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 更新視窗
    @command_window.update
    @playtime_window.update
    @steps_window.update
    @gold_window.update
    @status_window.update
    # 命令視窗被啟動的情況下: 取用 update_command
    if @command_window.active
      update_command
      return
    end
    # 狀態視窗被啟動的情況下: 取用 update_status
    if @status_window.active
      update_status
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (命令視窗被啟動的情況下)
  #--------------------------------------------------------------------------
  def update_command
    # 按下 B 鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切換的地圖畫面
      $scene = Scene_Map.new
      return
    end
    # 按下 C 鍵的情況下
    if Input.trigger?(Input::C)
      # 同伴人數為 0、存檔、遊戲結束以外的場合
      if $game_party.actors.size == 0 and @command_window.index < 4
        # 演奏凍結 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 命令視窗的游標位置分支
      case @command_window.index
      when 0  # 物品
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 切換到物品畫面
        $scene = Scene_Item.new
      when 1  # 特技
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 啟動狀態視窗
        @command_window.active = false
        @status_window.active = true
        @status_window.index = 0
      when 2  # 裝備
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 啟動狀態視窗
        @command_window.active = false
        @status_window.active = true
        @status_window.index = 0
      when 3  # 狀態
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 啟動狀態視窗
        @command_window.active = false
        @status_window.active = true
        @status_window.index = 0
      when 4  # 存檔
        # 禁止存檔的情況下
        if $game_system.save_disabled
          # 演奏凍結 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 切換到存檔畫面
        $scene = Scene_Save.new
      when 5  # 遊戲結束
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 切換到遊戲結束畫面
        $scene = Scene_End.new
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (狀態視窗被啟動的情況下)
  #--------------------------------------------------------------------------
  def update_status
    # 按下 B 鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 啟動命令視窗
      @command_window.active = true
      @status_window.active = false
      @status_window.index = -1
      return
    end
    # 按下 C 鍵的情況下
    if Input.trigger?(Input::C)
      # 命令視窗的游標位置分支
      case @command_window.index
      when 1  # 特技
        # 本角色的行動限制在 2 以上的情況下
        if $game_party.actors[@status_window.index].restriction >= 2
          # 演奏凍結 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 切換到特技畫面
        $scene = Scene_Skill.new(@status_window.index)
      when 2  # 裝備
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 切換的裝備畫面
        $scene = Scene_Equip.new(@status_window.index)
      when 3  # 狀態
        # 演奏確定 SE
        $game_system.se_play($data_system.decision_se)
        # 切換到狀態畫面
        $scene = Scene_Status.new(@status_window.index)
      end
      return
    end
  end
end
