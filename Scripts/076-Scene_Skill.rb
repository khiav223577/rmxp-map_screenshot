#==============================================================================
# ■ Scene_Skill
#------------------------------------------------------------------------------
# 處理特技畫面的類別。
#==============================================================================

class Scene_Skill
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #     actor_index : 角色索引
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  #--------------------------------------------------------------------------
  # ● 主處理
  #--------------------------------------------------------------------------
  def main
    # 取得角色
    @actor = $game_party.actors[@actor_index]
    # 製作提示視窗、狀態視窗、特技視窗
    @help_window = Window_Help.new
    @status_window = Window_SkillStatus.new(@actor)
    @skill_window = Window_Skill.new(@actor)
    # 連結提示視窗
    @skill_window.help_window = @help_window
    # 製作目標視窗 (設定為不可見?不活動)
    @target_window = Window_Target.new
    @target_window.visible = false
    @target_window.active = false
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
    @status_window.dispose
    @skill_window.dispose
    @target_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    # 更新視窗
    @help_window.update
    @status_window.update
    @skill_window.update
    @target_window.update
    # 特技視窗被啟動的情況下: 取用 update_skill
    if @skill_window.active
      update_skill
      return
    end
    # 目標視窗被啟動的情況下: 取用 update_target
    if @target_window.active
      update_target
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (特技視窗被啟動的情況下)
  #--------------------------------------------------------------------------
  def update_skill
    # 按下 B 鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切換到選單畫面
      $scene = Scene_Menu.new(1)
      return
    end
    # 按下 C 鍵的情況下
    if Input.trigger?(Input::C)
      # 取得特技視窗現在選擇的特技的資料
      @skill = @skill_window.skill
      # 不能使用的情況下
      if @skill == nil or not @actor.skill_can_use?(@skill.id)
        # 演奏凍結 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏確定 SE
      $game_system.se_play($data_system.decision_se)
      # 效果範圍是我方的情況下
      if @skill.scope >= 3
        # 啟動目標視窗
        @skill_window.active = false
        @target_window.x = (@skill_window.index + 1) % 2 * 304
        @target_window.visible = true
        @target_window.active = true
        # 設定效果範圍 (單體/全體) 的對應游標位置
        if @skill.scope == 4 || @skill.scope == 6
          @target_window.index = -1
        elsif @skill.scope == 7
          @target_window.index = @actor_index - 10
        else
          @target_window.index = 0
        end
      # 效果在我方以外的情況下
      else
        # 共通事件 ID 有效的情況下
        if @skill.common_event_id > 0
          # 預約取用共通事件
          $game_temp.common_event_id = @skill.common_event_id
          # 演奏特技使用時的 SE
          $game_system.se_play(@skill.menu_se)
          # 消耗 SP
          @actor.sp -= @skill.sp_cost
          # 再次製作各視窗的內容
          @status_window.refresh
          @skill_window.refresh
          @target_window.refresh
          # 切換到地圖畫面
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
    # 按下 R 鍵的情況下
    if Input.trigger?(Input::R)
      # 演奏游標 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至下一位角色
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # 切換到別的特技畫面
      $scene = Scene_Skill.new(@actor_index)
      return
    end
    # 按下 L 鍵的情況下
    if Input.trigger?(Input::L)
      # 演奏游標 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至上一位角色
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # 切換到別的特技畫面
      $scene = Scene_Skill.new(@actor_index)
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面 (目標視窗被啟動的情況下)
  #--------------------------------------------------------------------------
  def update_target
    # 按下 B 鍵的情況下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 刪除目標視窗
      @skill_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    # 按下 C 鍵的情況下
    if Input.trigger?(Input::C)
      # 因為 SP 不足而無法使用的情況下
      unless @actor.skill_can_use?(@skill.id)
        # 演奏凍結 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 目標是全體的情況下
      if @target_window.index == -1
        # 對同伴全體應用特技使用效果
        used = false
        for i in $game_party.actors
          used |= i.skill_effect(@actor, @skill)
        end
      end
      # 目標是使用者的情況下
      if @target_window.index <= -2
        # 對目標角色應用特技的使用效果
        target = $game_party.actors[@target_window.index + 10]
        used = target.skill_effect(@actor, @skill)
      end
      # 目標是單體的情況下
      if @target_window.index >= 0
        # 對目標角色應用特技的使用效果
        target = $game_party.actors[@target_window.index]
        used = target.skill_effect(@actor, @skill)
      end
      # 使用特技的情況下
      if used
        # 演奏特技使用時的 SE
        $game_system.se_play(@skill.menu_se)
        # 消耗 SP
        @actor.sp -= @skill.sp_cost
        # 再次製作各視窗內容
        @status_window.refresh
        @skill_window.refresh
        @target_window.refresh
        # 全滅的情況下
        if $game_party.all_dead?
          # 切換到遊戲結束畫面
          $scene = Scene_Gameover.new
          return
        end
        # 共通事件 ID 有效的情況下
        if @skill.common_event_id > 0
          # 預約取用共通事件
          $game_temp.common_event_id = @skill.common_event_id
          # 切換到地圖畫面
          $scene = Scene_Map.new
          return
        end
      end
      # 無法使用特技的情況下
      unless used
        # 演奏凍結 SE
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end
