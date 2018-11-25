#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 遊戲中全部視窗的超級類別。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 初始化目標
  #     x      : 視窗的 X 座標
  #     y      : 視窗的 Y 座標
  #     width  : 視窗的寬度
  #     height : 視窗的高度
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super()
    @windowskin_name = $game_system.windowskin_name
    self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
  end
  #--------------------------------------------------------------------------
  # ● 釋放所佔的記憶體空間
  #--------------------------------------------------------------------------
  def dispose
    # 如果視窗的內容已經被設定就釋放所佔的記憶體空間
    if self.contents != nil
      self.contents.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 取得文字色
  #     n : 文字色編號 (0～7)
  #--------------------------------------------------------------------------
  def text_color(n)
    case n
    when 0
      return Color.new(255, 255, 255, 255)
    when 1
      return Color.new(128, 128, 255, 255)
    when 2
      return Color.new(255, 128, 128, 255)
    when 3
      return Color.new(128, 255, 128, 255)
    when 4
      return Color.new(128, 255, 255, 255)
    when 5
      return Color.new(255, 128, 255, 255)
    when 6
      return Color.new(255, 255, 128, 255)
    when 7
      return Color.new(192, 192, 192, 255)
    else
      normal_color
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得普通文字色
  #--------------------------------------------------------------------------
  def normal_color
    return Color.new(255, 255, 255, 255)
  end
  #--------------------------------------------------------------------------
  # ● 取得無效文字色
  #--------------------------------------------------------------------------
  def disabled_color
    return Color.new(255, 255, 255, 128)
  end
  #--------------------------------------------------------------------------
  # ● 取得系統文字色
  #--------------------------------------------------------------------------
  def system_color
    return Color.new(192, 224, 255, 255)
  end
  #--------------------------------------------------------------------------
  # ● 取得危機文字色
  #--------------------------------------------------------------------------
  def crisis_color
    return Color.new(255, 255, 64, 255)
  end
  #--------------------------------------------------------------------------
  # ● 取得戰鬥不能文字色
  #--------------------------------------------------------------------------
  def knockout_color
    return Color.new(255, 64, 0)
  end
  #--------------------------------------------------------------------------
  # ● 更新畫面
  #--------------------------------------------------------------------------
  def update
    super
    # 如果視窗的外觀被變更的話就再次設定
    if $game_system.windowskin_name != @windowskin_name
      @windowskin_name = $game_system.windowskin_name
      self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    end
  end
  #--------------------------------------------------------------------------
  # ● 圖形的描繪
  #     actor : 角色
  #     x     : 描畫目標 X 座標
  #     y     : 描畫目標 Y 座標
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
    bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
    cw = bitmap.width / 4
    ch = bitmap.height / 4
    src_rect = Rect.new(0, 0, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #--------------------------------------------------------------------------
  # ● 名稱的描繪
  #     actor : 角色
  #     x     : 描畫目標 X 座標
  #     y     : 描畫目標 Y 座標
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 120, 32, actor.name)
  end
  #--------------------------------------------------------------------------
  # ● 職業的描繪
  #     actor : 角色
  #     x     : 描畫目標 X 座標
  #     y     : 描畫目標 Y 座標
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 236, 32, actor.class_name)
  end
  #--------------------------------------------------------------------------
  # ● 水平的描畫
  #     actor : 角色
  #     x     : 描畫目標 X 座標
  #     y     : 描畫目標 Y 座標
  #--------------------------------------------------------------------------
  def draw_actor_level(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, "Lv")
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 32, y, 24, 32, actor.level.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● 製作描繪用狀態字串
  #     actor       : 角色
  #     width       : 描畫目標的寬度
  #     need_normal : [正常] 是否為必須 (true / false)
  #--------------------------------------------------------------------------
  def make_battler_state_text(battler, width, need_normal)
    # 取得括號的寬度
    brackets_width = self.contents.text_size("[]").width
    # 製作狀態名稱字串
    text = ""
    for i in battler.states
      if $data_states[i].rating >= 1
        if text == ""
          text = $data_states[i].name
        else
          new_text = text + "/" + $data_states[i].name
          text_width = self.contents.text_size(new_text).width
          if text_width > width - brackets_width
            break
          end
          text = new_text
        end
      end
    end
    # 狀態名稱空的字串是 "[正常]" 的情況下
    if text == ""
      if need_normal
        text = "[正常]"
      end
    else
      # 加上括號
      text = "[" + text + "]"
    end
    # 返回完成後的文字類別
    return text
  end
  #--------------------------------------------------------------------------
  # ● 描繪狀態
  #     actor : 角色
  #     x     : 描畫目標 X 座標
  #     y     : 描畫目標 Y 座標
  #     width : 描畫目標的寬度
  #--------------------------------------------------------------------------
  def draw_actor_state(actor, x, y, width = 120)
    text = make_battler_state_text(actor, width, true)
    self.contents.font.color = actor.hp == 0 ? knockout_color : normal_color
    self.contents.draw_text(x, y, width, 32, text)
  end
  #--------------------------------------------------------------------------
  # ● 描畫 EXP
  #     actor : 角色
  #     x     : 描畫目標 X 座標
  #     y     : 描畫目標 Y 座標
  #--------------------------------------------------------------------------
  def draw_actor_exp(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 24, 32, "E")
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 24, y, 84, 32, actor.exp_s, 2)
    self.contents.draw_text(x + 108, y, 12, 32, "/", 1)
    self.contents.draw_text(x + 120, y, 84, 32, actor.next_exp_s)
  end
  #--------------------------------------------------------------------------
  # ● 描繪 HP
  #     actor : 角色
  #     x     : 描畫目標 X 座標
  #     y     : 描畫目標 Y 座標
  #     width : 描畫目標的寬度
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 144)
    # 描繪字串 "HP"
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, $data_system.words.hp)
    # 計算描繪 MaxHP 所需的空間 
    if width - 32 >= 108
      hp_x = x + width - 108
      flag = true
    elsif width - 32 >= 48
      hp_x = x + width - 48
      flag = false
    end
    # 描繪 HP
    self.contents.font.color = actor.hp == 0 ? knockout_color :
      actor.hp <= actor.maxhp / 4 ? crisis_color : normal_color
    self.contents.draw_text(hp_x, y, 48, 32, actor.hp.to_s, 2)
    # 描繪 MaxHP
    if flag
      self.contents.font.color = normal_color
      self.contents.draw_text(hp_x + 48, y, 12, 32, "/", 1)
      self.contents.draw_text(hp_x + 60, y, 48, 32, actor.maxhp.to_s)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描繪 SP
  #     actor : 角色
  #     x     : 描畫目標 X 座標
  #     y     : 描畫目標 Y 座標
  #     width : 描畫目標的寬度
  #--------------------------------------------------------------------------
  def draw_actor_sp(actor, x, y, width = 144)
    # 描繪字串 "SP" 
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, $data_system.words.sp)
    # 計算描繪 MaxSP 所需的空間
    if width - 32 >= 108
      sp_x = x + width - 108
      flag = true
    elsif width - 32 >= 48
      sp_x = x + width - 48
      flag = false
    end
    # 描繪 SP
    self.contents.font.color = actor.sp == 0 ? knockout_color :
      actor.sp <= actor.maxsp / 4 ? crisis_color : normal_color
    self.contents.draw_text(sp_x, y, 48, 32, actor.sp.to_s, 2)
    # 描繪 MaxSP
    if flag
      self.contents.font.color = normal_color
      self.contents.draw_text(sp_x + 48, y, 12, 32, "/", 1)
      self.contents.draw_text(sp_x + 60, y, 48, 32, actor.maxsp.to_s)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描繪能力值
  #     actor : 角色
  #     x     : 描畫目標 X 座標
  #     y     : 描畫目標 Y 座標
  #     type  : 能力值種類 (0～6)
  #--------------------------------------------------------------------------
  def draw_actor_parameter(actor, x, y, type)
    case type
    when 0
      parameter_name = $data_system.words.atk
      parameter_value = actor.atk
    when 1
      parameter_name = $data_system.words.pdef
      parameter_value = actor.pdef
    when 2
      parameter_name = $data_system.words.mdef
      parameter_value = actor.mdef
    when 3
      parameter_name = $data_system.words.str
      parameter_value = actor.str
    when 4
      parameter_name = $data_system.words.dex
      parameter_value = actor.dex
    when 5
      parameter_name = $data_system.words.agi
      parameter_value = actor.agi
    when 6
      parameter_name = $data_system.words.int
      parameter_value = actor.int
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, 32, parameter_name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 120, y, 36, 32, parameter_value.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● 描繪物品名
  #     item : 物品
  #     x    : 描畫目標 X 座標
  #     y    : 描畫目標 Y 座標
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y)
    if item == nil
      return
    end
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24))
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 28, y, 212, 32, item.name)
  end
end
