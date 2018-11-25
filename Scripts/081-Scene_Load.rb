#==============================================================================
# ■ Scene_Load
#------------------------------------------------------------------------------
# 處理讀檔畫面的類別。
#==============================================================================

class Scene_Load < Scene_File
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #--------------------------------------------------------------------------
  def initialize
    # 再製作臨時目標
    $game_temp = Game_Temp.new
    # 選擇存檔時間最新的文件
    $game_temp.last_file_index = 0
    latest_time = Time.at(0)
    for i in 0..3
      filename = make_filename(i)
      if FileTest.exist?(filename)
        file = File.open(filename, "r")
        if file.mtime > latest_time
          latest_time = file.mtime
          $game_temp.last_file_index = i
        end
        file.close
      end
    end
    super("要載入哪個文件？")
  end
  #--------------------------------------------------------------------------
  # ● 確定時的處理
  #--------------------------------------------------------------------------
  def on_decision(filename)
    # 文件不存在的情況下
    unless FileTest.exist?(filename)
      # 演奏循環 SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # 演奏讀檔 SE
    $game_system.se_play($data_system.load_se)
    # 寫入存檔資料
    file = File.open(filename, "rb")
    read_save_data(file)
    file.close
    # 還原 BGM、BGS
    $game_system.bgm_play($game_system.playing_bgm)
    $game_system.bgs_play($game_system.playing_bgs)
    # 更新地圖 (執行平行事件)
    $game_map.update
    # 切換到地圖畫面
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● 取消時的處理
  #--------------------------------------------------------------------------
  def on_cancel
    # 演奏取消 SE
    $game_system.se_play($data_system.cancel_se)
    # 切換到標題畫面
    $scene = Scene_Title.new
  end
  #--------------------------------------------------------------------------
  # ● 讀取存檔資料
  #     file : 讀取用文件目標 (已經打開)
  #--------------------------------------------------------------------------
  def read_save_data(file)
    # 讀取選用存檔文件用的角色資料
    characters = Marshal.load(file)
    # 讀取測量遊戲時間用畫面計時數值
    Graphics.frame_count = Marshal.load(file)
    # 讀取各種遊戲目標
    $game_system        = Marshal.load(file)
    $game_switches      = Marshal.load(file)
    $game_variables     = Marshal.load(file)
    $game_self_switches = Marshal.load(file)
    $game_screen        = Marshal.load(file)
    $game_actors        = Marshal.load(file)
    $game_party         = Marshal.load(file)
    $game_troop         = Marshal.load(file)
    $game_map           = Marshal.load(file)
    $game_player        = Marshal.load(file)
    # 魔法編號與保存時有差異的情況下
    # (加入編輯器編輯過的資料)
    if $game_system.magic_number != $data_system.magic_number
      # 重新載入地圖
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
    # 更新同伴成員
    $game_party.refresh
  end
end
