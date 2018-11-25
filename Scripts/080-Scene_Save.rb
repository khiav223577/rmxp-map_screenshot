#==============================================================================
# ■ Scene_Save
#------------------------------------------------------------------------------
# 處理存檔畫面的類別。
#==============================================================================

class Scene_Save < Scene_File
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #--------------------------------------------------------------------------
  def initialize
    super("要保存到這個文件嗎？")
  end
  #--------------------------------------------------------------------------
  # ● 確定時的處理
  #--------------------------------------------------------------------------
  def on_decision(filename)
    # 演奏存檔 SE
    $game_system.se_play($data_system.save_se)
    # 寫入存檔資料
    file = File.open(filename, "wb")
    write_save_data(file)
    file.close
    # 如果被事件取用
    if $game_temp.save_calling
      # 清除存檔取用標誌
      $game_temp.save_calling = false
      # 切換到地圖畫面
      $scene = Scene_Map.new
      return
    end
    # 切換到選單畫面
    $scene = Scene_Menu.new(4)
  end
  #--------------------------------------------------------------------------
  # ● 取消時的處理
  #--------------------------------------------------------------------------
  def on_cancel
    # 演奏取消 SE
    $game_system.se_play($data_system.cancel_se)
    # 如果被事件取用
    if $game_temp.save_calling
      # 清除存檔取用標誌
      $game_temp.save_calling = false
      # 切換到地圖畫面
      $scene = Scene_Map.new
      return
    end
    # 切換到選單畫面
    $scene = Scene_Menu.new(4)
  end
  #--------------------------------------------------------------------------
  # ● 寫入存檔資料
  #     file : 寫入用文件目標 (已經打開)
  #--------------------------------------------------------------------------
  def write_save_data(file)
    # 製作描繪存檔文件用的角色圖形
    characters = []
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      characters.push([actor.character_name, actor.character_hue])
    end
    # 寫入描繪存檔文件用的角色資料
    Marshal.dump(characters, file)
    # 寫入測量遊戲時間用畫面計數
    Marshal.dump(Graphics.frame_count, file)
    # 增加 1 次存檔次數
    $game_system.save_count += 1
    # 保存魔法編號
    # (將編輯器保存的值以隨機值替換)
    $game_system.magic_number = $data_system.magic_number
    # 寫入各種遊戲目標
    Marshal.dump($game_system, file)
    Marshal.dump($game_switches, file)
    Marshal.dump($game_variables, file)
    Marshal.dump($game_self_switches, file)
    Marshal.dump($game_screen, file)
    Marshal.dump($game_actors, file)
    Marshal.dump($game_party, file)
    Marshal.dump($game_troop, file)
    Marshal.dump($game_map, file)
    Marshal.dump($game_player, file)
  end
end
