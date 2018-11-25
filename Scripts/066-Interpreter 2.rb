#==============================================================================
# ■ Interpreter (第二部份)
#------------------------------------------------------------------------------
# 執行時間命令的解釋器。使用在 Game_System 類別和 Game_Event 類別的內部。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 執行事件命令
  #--------------------------------------------------------------------------
  def execute_command
    # 到達執行內容列表末尾的情況下
    if @index >= @list.size - 1
      # 時間結束
      command_end
      # 繼續
      return true
    end
    # 事件命令的功能可以參考 @parameters
    @parameters = @list[@index].parameters
    # 命令代碼分歧
    case @list[@index].code
    when 101  # 文字的顯示
      return command_101
    when 102  # 顯示選擇項目
      return command_102
    when 402  # [**] 的情況下
      return command_402
    when 403  # 取消的情況下
      return command_403
    when 103  # 處理數值輸入
      return command_103
    when 104  # 更改文字選項
      return command_104
    when 105  # 處理按鍵輸入
      return command_105
    when 106  # 等待
      return command_106
    when 111  # 條件分歧
      return command_111
    when 411  # 這以外的情況
      return command_411
    when 112  # 循環
      return command_112
    when 413  # 重複上次
      return command_413
    when 113  # 中斷循環
      return command_113
    when 115  # 中斷時間處理
      return command_115
    when 116  # 暫時刪除事件
      return command_116
    when 117  # 共通事件
      return command_117
    when 118  # 標籤
      return command_118
    when 119  # 標籤跳轉
      return command_119
    when 121  # 操作開關
      return command_121
    when 122  # 操作變數
      return command_122
    when 123  # 操作獨立開關
      return command_123
    when 124  # 操作計時器
      return command_124
    when 125  # 增減金錢
      return command_125
    when 126  # 增減物品
      return command_126
    when 127  # 增減武器
      return command_127
    when 128  # 增減防具
      return command_128
    when 129  # 替換角色
      return command_129
    when 131  # 更改視窗外觀
      return command_131
    when 132  # 更改戰鬥 BGM
      return command_132
    when 133  # 更改戰鬥結束 BGS
      return command_133
    when 134  # 更改禁止保存
      return command_134
    when 135  # 更改禁止選單
      return command_135
    when 136  # 更改禁止遇敵
      return command_136
    when 201  # 場所移動
      return command_201
    when 202  # 設定事件位置
      return command_202
    when 203  # 地圖捲動
      return command_203
    when 204  # 更改地圖設定
      return command_204
    when 205  # 更改迷霧的色彩
      return command_205
    when 206  # 更改迷霧的不透明度
      return command_206
    when 207  # 顯示動畫
      return command_207
    when 208  # 更改透明狀態
      return command_208
    when 209  # 設定移動路線
      return command_209
    when 210  # 移動結束後等待
      return command_210
    when 221  # 準備轉變
      return command_221
    when 222  # 執行過渡
      return command_222
    when 223  # 更改畫面色彩
      return command_223
    when 224  # 畫面閃爍
      return command_224
    when 225  # 畫面震動
      return command_225
    when 231  # 顯示圖片
      return command_231
    when 232  # 移動圖片
      return command_232
    when 233  # 旋轉圖片
      return command_233
    when 234  # 更改色彩
      return command_234
    when 235  # 刪除圖片
      return command_235
    when 236  # 設定天候
      return command_236
    when 241  # 演奏 BGM
      return command_241
    when 242  # BGM 的淡入淡出
      return command_242
    when 245  # 演奏 BGS
      return command_245
    when 246  # BGS 的淡入淡出
      return command_246
    when 247  # 記憶 BGM / BGS
      return command_247
    when 248  # 還原 BGM / BGS
      return command_248
    when 249  # 演奏 ME
      return command_249
    when 250  # 演奏 SE
      return command_250
    when 251  # 停止 SE
      return command_251
    when 301  # 戰鬥處理
      return command_301
    when 601  # 勝利的情況
      return command_601
    when 602  # 逃跑的情況
      return command_602
    when 603  # 失敗的情況
      return command_603
    when 302  # 商店的處理
      return command_302
    when 303  # 名稱輸入的處理
      return command_303
    when 311  # 增減 HP
      return command_311
    when 312  # 增減 SP
      return command_312
    when 313  # 更改狀態
      return command_313
    when 314  # 全回復
      return command_314
    when 315  # 增減 EXP
      return command_315
    when 316  # 增減 等級
      return command_316
    when 317  # 增減 能力值
      return command_317
    when 318  # 增減特技
      return command_318
    when 319  # 變更裝備
      return command_319
    when 320  # 更改角色名字
      return command_320
    when 321  # 更改角色職業
      return command_321
    when 322  # 更改角色圖像
      return command_322
    when 331  # 增減敵人的 HP
      return command_331
    when 332  # 增減敵人的 SP
      return command_332
    when 333  # 更改敵人的狀態
      return command_333
    when 334  # 敵人出現
      return command_334
    when 335  # 敵人變身
      return command_335
    when 336  # 敵人全回復
      return command_336
    when 337  # 顯示動畫
      return command_337
    when 338  # 傷害處理
      return command_338
    when 339  # 強制行動
      return command_339
    when 340  # 戰鬥中斷
      return command_340
    when 351  # 取用選單畫面
      return command_351
    when 352  # 取用存檔畫面
      return command_352
    when 353  # 遊戲結束
      return command_353
    when 354  # 返回標題畫面
      return command_354
    when 355  # 劇本
      return command_355
    else      # 其它
      return true
    end
  end
  #--------------------------------------------------------------------------
  # ● 事件結束
  #--------------------------------------------------------------------------
  def command_end
    # 清除執行內容列表
    @list = nil
    # 主地圖事件與事件 ID 有效的情況下
    if @main and @event_id > 0
      # 解除事件鎖定
      $game_map.events[@event_id].unlock
    end
  end
  #--------------------------------------------------------------------------
  # ● 指令跳轉
  #--------------------------------------------------------------------------
  def command_skip
    # 取得複本
    indent = @list[@index].indent
    # 循環
    loop do
      # 下一個事件命令是同等級的複本情況下
      if @list[@index+1].indent == indent
        # 繼續
        return true
      end
      # 索引的下一個
      @index += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得角色
  #     parameter : 能力值
  #--------------------------------------------------------------------------
  def get_character(parameter)
    # 能力值分歧
    case parameter
    when -1  # 角色
      return $game_player
    when 0  # 本事件
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else  # 特定的事件
      events = $game_map.events
      return events == nil ? nil : events[parameter]
    end
  end
  #--------------------------------------------------------------------------
  # ● 計算操作的值
  #     operation    : 操作
  #     operand_type : 操作數類型 (0:恆量 1:變數)
  #     operand      : 操作數 (數值是變數 ID)
  #--------------------------------------------------------------------------
  def operate_value(operation, operand_type, operand)
    # 取得操作數
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    # 操作為 [減少] 的情況下反轉實際符號
    if operation == 1
      value = -value
    end
    # 返回 value
    return value
  end
end
