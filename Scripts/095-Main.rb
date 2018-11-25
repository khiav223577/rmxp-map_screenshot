#==============================================================================
# ■ Main
#------------------------------------------------------------------------------
# 各定義結束後、從這裡開始實際處理。
#==============================================================================

begin
  # 準備轉變
  Graphics.freeze
  # Set default font name
  Font.default_name = (["微軟正黑體", "新細明體", "黑体"])
  # 製作場景目標 (標題畫面)
  $scene = Scene_Title.new
  # 只要 $scene 是有效的情況下取用主要部分的方法
  while $scene != nil
    $scene.main
  end
  # 淡入淡出
  Graphics.transition(20)
rescue Errno::ENOENT
  # 補充 Errno::ENOENT 例外
  # 如果無法打開文件、顯示訊息後結束
  filename = $!.message.sub("No such file or directory - ", "")
  print("找不到文件 #{filename}。 ")
end
