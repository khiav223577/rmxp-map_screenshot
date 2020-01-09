class Game_Character
#--------------------------------------------------------------------------
# ●  設定自定屬性
#--------------------------------------------------------------------------
  def set_custom_attr(type)
    case type
    when "樹樁"
      @spe_triggerer_range   = [ 0.0, 0.0, 1.0, 0.0]
    when "洞穴-碎石堆"
      @tile_event_flag = true
      @spe_triggerer_range   = [ 0.0, 0.0, 2.0, 0.0]
    when "半透明樹"
      @spe_triggerer_range   = [-0.5, 0.0, 0.0, 0.0]
      @tile_event_flag = true
      @opacity_trigger_range = {:rect => [-1.5,-4.5, 1.5,-0.5], :opacity => [128, 255]}
    when "半透明樹2"
      @spe_triggerer_range   = [-1.0, -1.5, 1.0, -0.5]
      @tile_event_flag = true
      @opacity_trigger_range = {:rect => [-3.0,-7.0, 3.0,-2.0], :opacity => [128, 255]}
    when "湖畔巨樹"
      @spe_triggerer_range   = [-1.0, -1.0, 1.0, -0.5]
      @tile_event_flag = true
      @opacity_trigger_range = {:rect => [-3.5, -7.5, 3.5, -1.0], :opacity => [128, 255]}
    when "瀑布花園BGS"
      @axy_trigger_func_tmp1 = nil
      @axy_trigger_func = :trigger_fallsGarden
    when "Fountain"
      @spe_triggerer_range   = [-1.0,-1.5, 1.0, 0.0]
      @tile_event_flag = true
    when "後院屋頂"
      @through = true
      @tile_event_flag = true
      @opacity_trigger_range = {:rect => [-3.0,-4.5, 3.0, 1.5], :opacity => [128, 255]}
    when "木柵欄"
      @spe_triggerer_range   = [-0.5, 0.0, 0.5, 0.0]
    when "瞬鏡"
      @opacity_trigger_range = {:circle => 3, :opacity => [255, 0]}
    when "調查點"
      @opacity_trigger_range = {:circle => 7, :opacity => [255, 0]}
    else 
      raise RuntimeError "Unknown type = #{type} in set_custom_attr"
    end
  end
end
