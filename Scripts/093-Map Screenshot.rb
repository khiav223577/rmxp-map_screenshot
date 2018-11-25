#==============================================================================
# ** Map Screenshot
#==============================================================================
#
# - Credits: Cycleby for Bitmap to PNG
#            SephirothSpawn for Tilemap
#
#
# To take a screenshot simply be on the map and press F6. The file will be
# created in your game directory under the maps name.
#
#==============================================================================


#==============================================================================
# ** Spriteset_Map
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  alias :bit_to_png_up :update
  def update
    bit_to_png_up
    if Input.trigger?(Input::F6)
      map_infos = load_data("Data/MapInfos.rxdata")
      bit = @tilemap.bitmap
      exp_time = (bit.height * bit.width) * 0.00000664
      string = "Taking screenshot please wait.... \n" + 
              "Number of pixels: #{bit.height * bit.width} \n" +
              "Estamated time: #{exp_time} seconds."
      print("#{string}")
      old_time = Time.now
      bit.save_png("123")
      #bit.make_png("#{map_infos[$game_map.map_id].name}")
      string = "#{map_infos[$game_map.map_id].name}.png was created. \n" +
              "File size: width #{bit.width}, height #{bit.height}. \n" +
              "Time taken: #{Time.now - old_time} seconds."
      print("#{string}")
    end
  end
end

#==============================================================================
#                        Bitmap to PNG By Cycleby
#==============================================================================
#
# Direct use of the Bitmap object.
#    bitmap_obj.make_png(name[, path])
# 
# Name: Save the file name
# Path: path to save the
#
# Thanks 66, Shana, gold Guizi reminder and help!
#==============================================================================
module Zlib
  class Png_File < GzipWriter
    #--------------------------------------------------------------------------
    # ● Main
    #-------------------------------------------------------------------------- 
    def make_png(bitmap_Fx,mode)
      @mode = mode
      @bitmap_Fx = bitmap_Fx
      self.write(make_header)
      self.write(make_ihdr)
      self.write(make_idat)
      self.write(make_iend)
    end
    #--------------------------------------------------------------------------
    # ● PNG file header block
    #--------------------------------------------------------------------------
    def make_header
      return [0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a].pack("C*")
    end
    #--------------------------------------------------------------------------
    # ● PNG file data block header information (IHDR)
    #-------------------------------------------------------------------------- 
    def make_ihdr
      ih_size = [13].pack("N")
      ih_sign = "IHDR"
      ih_width = [@bitmap_Fx.width].pack("N")
      ih_height = [@bitmap_Fx.height].pack("N")
      ih_bit_depth = [8].pack("C")
      ih_color_type = [6].pack("C")
      ih_compression_method = [0].pack("C")
      ih_filter_method = [0].pack("C")
      ih_interlace_method = [0].pack("C")
      string = ih_sign + ih_width + ih_height + ih_bit_depth + ih_color_type +
              ih_compression_method + ih_filter_method + ih_interlace_method
      ih_crc = [Zlib.crc32(string)].pack("N")
      return ih_size + string + ih_crc
    end
    #--------------------------------------------------------------------------
    # ● Generated image data (IDAT)
    #-------------------------------------------------------------------------- 
    def make_idat
      header = "\x49\x44\x41\x54"
      case @mode # please 54 ~
      when 1
        data = make_bitmap_data # 1
      else
        data = make_bitmap_data
      end
      data = Zlib::Deflate.deflate(data, 8)
      crc = [Zlib.crc32(header + data)].pack("N")
      size = [data.length].pack("N")
      return size + header + data + crc
    end
    #--------------------------------------------------------------------------
    # ● Requests from the Bitmap object 54 to generate image data in mode 1 
    # (please 54 ~)
    #-------------------------------------------------------------------------- 
    def make_bitmap_data1
      w = @bitmap_Fx.width
      h = @bitmap_Fx.height
      data = []
      for y in 0...h
        data.push(0)
        for x in 0...w
          color = @bitmap_Fx.get_pixel(x, y)
          red = color.red
          green = color.green
          blue = color.blue
          alpha = color.alpha
          data.push(red)
          data.push(green)
          data.push(blue)
          data.push(alpha)
        end
      end
      return data.pack("C*")
    end
    #--------------------------------------------------------------------------
    # ● Bitmap object from the image data generated in mode 0
    #-------------------------------------------------------------------------- 
    def make_bitmap_data
      gz = Zlib::GzipWriter.open('hoge.gz')
      t_Fx = 0
      w = @bitmap_Fx.width
      h = @bitmap_Fx.height
      data = []
      for y in 0...h
        data.push(0)
        for x in 0...w
          t_Fx += 1
          if t_Fx % 10000 == 0
            Graphics.update
          end
          if t_Fx % 100000 == 0
            s = data.pack("C*")
            gz.write(s)
            data.clear
            #GC.start
          end
          color = @bitmap_Fx.get_pixel(x, y)
          red = color.red
          green = color.green
          blue = color.blue
          alpha = color.alpha
          data.push(red)
          data.push(green)
          data.push(blue)
          data.push(alpha)
        end
      end
      s = data.pack("C*")
      gz.write(s)
      gz.close    
      data.clear
      gz = Zlib::GzipReader.open('hoge.gz')
      data = gz.read
      gz.close
      File.delete('hoge.gz') 
      return data
    end
    #--------------------------------------------------------------------------
    # ● PNG end of the file data blocks (IEND)
    #-------------------------------------------------------------------------- 
    def make_iend
      ie_size = [0].pack("N")
      ie_sign = "IEND"
      ie_crc = [Zlib.crc32(ie_sign)].pack("N")
      return ie_size + ie_sign + ie_crc
    end
  end
end
#==============================================================================
# ■ Bitmap
#------------------------------------------------------------------------------
# Related to the Bitmap.
#==============================================================================
class Bitmap
  #--------------------------------------------------------------------------
  # ● Related
  #-------------------------------------------------------------------------- 
  def make_png(name="like", path="",mode=0)
    make_dir(path) if path != ""
    Zlib::Png_File.open("temp.gz") {|gz|
      gz.make_png(self,mode)
    }
    Zlib::GzipReader.open("temp.gz") {|gz|
      $read = gz.read
    }
    f = File.open(path + name + ".png","wb")
    f.write($read)
    f.close
    File.delete('temp.gz') 
    end
  #--------------------------------------------------------------------------
  # ● Save the path generated
  #-------------------------------------------------------------------------- 
  def make_dir(path)
    dir = path.split("/")
    for i in 0...dir.size
      unless dir == "."
        add_dir = dir[0..i].join("/")
        begin
          Dir.mkdir(add_dir)
        rescue
        end
      end
    end
  end
end

#==============================================================================
# ** Tilemap (Basic)
#------------------------------------------------------------------------------
# SephirothSpawn
# Version 1.0
# 2007-05-30
# SDK Version 2.2 + : Parts I & II 
#------------------------------------------------------------------------------
# * Credits :
#
#  Thanks to Trickster for conversion formula for Hexidecimal to rgb.
#  Thanks to trebor777 for helping with the priority bug from the 0.9 version.
#------------------------------------------------------------------------------
# * Description :
#
#  This script was designed to re-write the default RMXP Hidden Tileset class.
#  The script has added many features and a new "Tilemap Settings" class,
#  that can be unique if you create mini-maps using this system.
#------------------------------------------------------------------------------
# * Instructions :
#
#  Place The Script Below the SDK and Above Main.
#------------------------------------------------------------------------------
# * Syntax :
#
#  Get Autotile Tile Bitmap
#    - RPG::Cache.autotile_tile(autotile_filename, tile_id[, hue[, frame_id]])
#
#      autotile_filename : Filename of autotile
#      tile_id : ID of tile (Found from RPG::Map.data)
#      hue (Optional) : Hue for tile
#      frame_id (Optional) : Frame of tile (for animated autotiles)
#
# * Tilemap Syntax
#
#  Readable Attributes :
#    - layers : Array of Sprites (or Planes)
#
#  Readable/Writable Attributes :
#    - tileset (No long required) : Bitmap for Tileset
#    - tileset_name : Name of Bitmap
#    - autotiles (No long required) : Array of Autotile Bitmaps
#    - autotiles_name : Array of Autotile Filenames
#    - map_data : 3D Table of Tile ID Data
#    - flash_data : 3D Table of Tile Flash Data 
#                  (Should match tilemap_settings.flash_data)
#    - priorities : 3D Table of Tile Priorities
#    - Visible : Tilemap Visible Flag
#    - ox, oy : Tilemap layer offsets
#    - tilemap_settings : Unique Special Settings Object (See Below)
#    - refresh_autotiles : Refresh Autotiles on frame reset flag
#
# * Special Tilemap Settings
#
#  To make special settings easier to control for your game map and any other
#  special tilemap sprites you wish to create, a special class was created
#  to hold these settings. For your game tilemap, a Tilemap_Settings object
#  was created in $game_map ($game_map.tilemap_settings). It is advised to 
#  modify $game_map.tilemap_settings.flash_data instead of tilemap.flash_data.
#
#  Readable/Writeable Attributes :
#    - map : RPG::Map (Not required, but for additions)
#    - is_a_plane : Boolean whether layers are Sprites or Planes
#    - tone : Tone for all layers
#    - hue : Hue for all layers
#    - zoom_x, zoom_y : Zoom factor for all layers
#    - tilesize : Tilesize displayed on map
#    - flash_data : 3D Table of flash_data
#==============================================================================

#==============================================================================
# ** Tilemap_Options
#==============================================================================

module Tilemap_Options
  #--------------------------------------------------------------------------
  # * Tilemap Options
  #
  #
  #  Print Error Reports when not enough information set to tilemap
  #    - Print_Error_Logs          = true or false
  #
  #  Number of autotiles to refresh at edge of viewport
  #  Number of Frames Before Redrawing Animated Autotiles
  #    - Animated_Autotiles_Frames = 16
  #
  #    - Viewport_Padding          = n
  #
  #  When maps are switch, automatically set 
  #  $game_map.tileset_settings.flash_data (Recommended : False unless using
  #  flash_data)
  #    - Autoset_Flash_data        = true or false
  #
  #  Duration Between Flash Data Flashes
  #    - Flash_Duration            = n
  #
  #  Color of bitmap (Recommended to use low opacity value)
  #    - Flash_Bitmap_C            = Color.new(255, 255, 255, 50)
  #
  #  Update Flashtiles Default Setting
  #  Explanation : In the Flash Data Addition, because of lag, you may wish
  #  to toggle whether flash tiles flash or not. This is the default state.
  #    - Default_Update_Flashtiles = false
  #--------------------------------------------------------------------------
  Print_Error_Logs          = true
  Animated_Autotiles_Frames = 16
  Autoset_Flash_data        = true
  Viewport_Padding          = 2
  Flash_Duration            = 40
  Flash_Bitmap_C            = Color.new(255, 255, 255, 50)
  Default_Update_Flashtiles = false
end

#==============================================================================
# ** RPG::Cache
#==============================================================================
module RPG::Cache
  #--------------------------------------------------------------------------
  # * Auto-Tiles
  #
  #  Auto-Tile 48 : First Auto-Tile, Constructed of tiles 27, 28, 33, 34
  #--------------------------------------------------------------------------
  Autotiles = [
    [[27, 28, 33, 34], [ 5, 28, 33, 34], [27,  6, 33, 34], [ 5,  6, 33, 34],
    [27, 28, 33, 12], [ 5, 28, 33, 12], [27,  6, 33, 12], [ 5,  6, 33, 12]],
    [[27, 28, 11, 34], [ 5, 28, 11, 34], [27,  6, 11, 34], [ 5,  6, 11, 34],
    [27, 28, 11, 12], [ 5, 28, 11, 12], [27,  6, 11, 12], [ 5,  6, 11, 12]],
    [[25, 26, 31, 32], [25,  6, 31, 32], [25, 26, 31, 12], [25,  6, 31, 12],
    [15, 16, 21, 22], [15, 16, 21, 12], [15, 16, 11, 22], [15, 16, 11, 12]],
    [[29, 30, 35, 36], [29, 30, 11, 36], [ 5, 30, 35, 36], [ 5, 30, 11, 36],
    [39, 40, 45, 46], [ 5, 40, 45, 46], [39,  6, 45, 46], [ 5,  6, 45, 46]],
    [[25, 30, 31, 36], [15, 16, 45, 46], [13, 14, 19, 20], [13, 14, 19, 12],
    [17, 18, 23, 24], [17, 18, 11, 24], [41, 42, 47, 48], [ 5, 42, 47, 48]],
    [[37, 38, 43, 44], [37,  6, 43, 44], [13, 18, 19, 24], [13, 14, 43, 44],
    [37, 42, 43, 48], [17, 18, 47, 48], [13, 18, 43, 48], [ 1,  2,  7,  8]]
  ]
  #--------------------------------------------------------------------------
  # * Autotile Cache
  #
  #  @autotile_cache = { 
  #    filename => { [autotile_id, frame_id, hue] => bitmap, ... },
  #    ...
  #    }
  #--------------------------------------------------------------------------
  @autotile_cache = {}
  #--------------------------------------------------------------------------
  # * Autotile Tile
  #--------------------------------------------------------------------------
  def self.autotile_tile(filename, tile_id, hue = 0, frame_id = nil)
    # Gets Autotile Bitmap
    autotile = self.autotile(filename)
    # Configures Frame ID if not specified
    if frame_id.nil?
      # Animated Tiles
      frames = autotile.width / 96
      # Configures Animation Offset
      fc = Graphics.frame_count / Tilemap_Options::Animated_Autotiles_Frames
      return if frames == 0
      frame_id = (fc) % frames * 96
    end
    # Creates list if already not created
    @autotile_cache[filename] = {} unless @autotile_cache.has_key?(filename)
    # Gets Key
    key = [tile_id, frame_id, hue]
    # If Key Not Found
    unless @autotile_cache[filename].has_key?(key)
      # Reconfigure Tile ID
      tile_id %= 48
      # Creates Bitmap
      bitmap = Bitmap.new(32, 32)
      # Collects Auto-Tile Tile Layout
      tiles = Autotiles[tile_id / 8][tile_id % 8]
      # Draws Auto-Tile Rects
      for i in 0...4
        tile_position = tiles[i] - 1
        src_rect = Rect.new(tile_position % 6 * 16 + frame_id, 
          tile_position / 6 * 16, 16, 16)
        bitmap.blt(i % 2 * 16, i / 2 * 16, autotile, src_rect)
      end
      # Saves Autotile to Cache
      @autotile_cache[filename][key] = bitmap
      # Change Hue
      @autotile_cache[filename][key].hue_change(hue)
    end
    # Return Autotile
    return @autotile_cache[filename][key]
  end
end

#==============================================================================
# ** Spriteset_Map
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    # Make viewports
    @viewport1 = Viewport.new(0, 0, 640, 480)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 200
    @viewport3.z = 5000
    # Make tilemap
    # Make tilemap
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.tileset = RPG::Cache.tileset($game_map.tileset_name)
    for i in 0..6
      autotile_name = $game_map.autotile_names[i]
      @tilemap.autotiles[i] = RPG::Cache.autotile(autotile_name)
    end
    @tilemap.map_data = $game_map.data.dup
    @tilemap.priorities = $game_map.priorities
    # Set Tilemap Settings
    @tilemap.tileset_name = $game_map.tileset_name
    for i in 0..6
      @tilemap.autotiles_name[i] = $game_map.autotile_names[i]
    end
    @tilemap.tilemap_settings = $game_map.tilemap_settings
    # Setup Flash Data
    @tilemap.flash_data = $game_map.tilemap_settings.flash_data
    # Run Tilemap Setup
    @tilemap.setup
    # Make panorama plane
    @panorama = Plane.new(@viewport1)
    @panorama.z = -1000
    # Make fog plane
    @fog = Plane.new(@viewport1)
    @fog.z = 3000
    # Make character sprites
    @character_sprites = []
    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      @character_sprites.push(sprite)
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
    # Make weather
    @weather = RPG::Weather.new(@viewport1)
    # Make picture sprites
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_screen.pictures[i]))
    end
    # Make timer sprite
    @timer_sprite = Sprite_Timer.new
    # Frame update
    update 
  end
  def update
    @tilemap.ox = $game_map.display_x / 4
    @tilemap.oy = $game_map.display_y / 4
    @tilemap.update
  end
end

#==============================================================================
# ** Tilemap_Settings
#==============================================================================
class Tilemap_Settings
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :map
  attr_accessor :is_a_plane
  attr_accessor :tone
  attr_accessor :hue
  attr_accessor :zoom_x
  attr_accessor :zoom_y
  attr_accessor :tile_size
  attr_accessor :flash_data
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(map = nil)
    # Set Instance Variables
    @map, @is_a_plane, @tone, @hue, @zoom_x, @zoom_y, @tile_size, 
      @flash_data = map, false, nil, 0, 1.0, 1.0, 32, nil
  end
end

#==============================================================================
# ** Game_Map
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :tilemap_settings
  #--------------------------------------------------------------------------
  # * Alias Listings
  #--------------------------------------------------------------------------
  alias_method :seph_tilemap_gmap_init, :initialize
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    # Original Initialization
    seph_tilemap_gmap_init
    # Create Tilemap Settings
    @tilemap_settings = Tilemap_Settings.new
  end
  #--------------------------------------------------------------------------
  # * Load Map Data
  #--------------------------------------------------------------------------
  def setup_load
    # Reset Tilemap Flash Data
    if Tilemap_Options::Autoset_Flash_data
      @tilemap_settings.flash_data = Table.new(@map.width, @map.height)
    end
    @tilemap_settings.map = @map
  end
end

#==============================================================================
# ** Tilemap
#==============================================================================
class Tilemap
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader  :layers
  attr_accessor :tileset
  attr_accessor :tileset_name
  attr_accessor :autotiles
  attr_accessor :autotiles_name
  attr_accessor :map_data
  attr_accessor :flash_data
  attr_accessor :priorities
  attr_accessor :visible
  attr_accessor :ox
  attr_accessor :oy
  attr_accessor :tilemap_settings
  attr_accessor :refresh_autotiles
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(viewport)
    # Saves Viewport
    @viewport = viewport
    # Creates Blank Instance Variables
    @layers            = []    # Refers to Array of Sprites or Planes
    @tileset          = nil  # Refers to Tileset Bitmap
    @tileset_name      = ''    # Refers to Tileset Filename
    @autotiles        = []    # Refers to Array of Autotile Bitmaps
    @autotiles_name    = []    # Refers to Array of Autotile Filenames
    @map_data          = nil  # Refers to 3D Array Of Tile Settings
    @flash_data        = nil  # Refers to 3D Array of Tile Flashdata
    @priorities        = nil  # Refers to Tileset Priorities
    @visible          = true  # Refers to Tilest Visibleness
    @ox                = 0    # Bitmap Offsets          
    @oy                = 0    # Bitmap Offsets
    @tilemap_settings  = nil  # Special Tilemap Settings
    @dispose          = false # Disposed Flag
    @refresh_autotiles = true  # Refresh Autotile Flag
  end
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup
    # Print Error if Tilemap Settings not Found
    if Tilemap_Options::Print_Error_Logs
      if @tilemap_settings.nil?
        p 'Tilemap Settings have not been set. System will not crash.'
      end
      if @map_data.nil?
        p 'Map Data has not been set. System will crash.'
      end
    end
    # Creates Layers
    @layers = []
    for l in 0...3
      layer = @tilemap_settings.nil? || !@tilemap_settings.is_a_plane ?
        Sprite.new(@viewport) : Plane.new(@viewport)
      layer.bitmap = Bitmap.new(@map_data.xsize * 32, @map_data.ysize * 32)
      layer.z = l * 150
      layer.zoom_x = @tilemap_settings.nil? ? 1.0 : @tilemap_settings.zoom_x
      layer.zoom_y = @tilemap_settings.nil? ? 1.0 : @tilemap_settings.zoom_y
      unless @tilemap_settings.nil? || @tilemap_settings.tone.nil?
        layer.tone = @tilemap_settings.tone
      end
      @layers << layer
    end
    # Update Flags
    @refresh_data = nil
    @zoom_x  = @tilemap_settings.nil? ? 1.0 : @tilemap_settings.zoom_x
    @zoom_y  = @tilemap_settings.nil? ? 1.0 : @tilemap_settings.zoom_y
    @tone    = @tilemap_settings.nil? ? nil : @tilemap_settings.tone
    @hue      = @tilemap_settings.nil? ? 0  : @tilemap_settings.hue
    @tilesize = @tilemap_settings.nil? ? 32  : @tilemap_settings.tile_size
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    # Dispose Layers (Sprites)
    @layers.each { |layer| layer.dispose }
    # Set Disposed Flag to True
    @disposed = true
  end
  #--------------------------------------------------------------------------
  # * Disposed?
  #--------------------------------------------------------------------------
  def disposed?
    return @disposed
  end
  #--------------------------------------------------------------------------
  # * Viewport
  #--------------------------------------------------------------------------
  def viewport
    return @viewport
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Set Refreshed Flag to On
    needs_refresh = true
    # If Map Data, Tilesize or HueChanges
    if @map_data != @refresh_data || (@tilemap_settings != false && 
      @hue != @tilemap_settings.hue) || (@tilemap_settings != false && 
      @tilesize != @tilemap_settings.tile_size)
      # Refresh Bitmaps
      refresh
      # Turns Refresh Flag to OFF
      needs_refresh = false
    end
    # Zoom X, Zoom Y, and Tone Changes
    unless @tilemap_settings.nil?
      if @zoom_x != @tilemap_settings.zoom_x
        @zoom_x = @tilemap_settings.zoom_x
        @layers.each {|layer| layer.zoom_x = @zoom_x}
      end
      if @zoom_y != @tilemap_settings.zoom_y
        @zoom_y = @tilemap_settings.zoom_y
        @layers.each {|layer| layer.zoom_y = @zoom_y}
      end
      if @tone != @tilemap_settings.tone
        @tone = @tilemap_settings.tone.nil? ? 
          Tone.new(0, 0, 0, 0) : @tilemap_settings.tone
        @layers.each {|layer| layer.tone = @tone}
      end
    end
    # Update layer Position offsets
    for layer in @layers
      layer.ox = @ox
      layer.oy = @oy
    end
    # If Refresh Autotiles, Needs Refreshed & Autotile Reset Frame
    if @refresh_autotiles && needs_refresh && 
      Graphics.frame_count % Tilemap_Options::Animated_Autotiles_Frames == 0
      # Refresh Autotiles
      refresh_autotiles
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Saves Map Data & Tilesize
    @refresh_data = @map_data
    @hue      = @tilemap_settings.nil? ? 0  : @tilemap_settings.hue
    @tilesize = @tilemap_settings.nil? ? 32 : @tilemap_settings.tile_size
    # Passes Through Layers
    for z in 0...@map_data.zsize
      # Passes Through X Coordinates
      for x in 0...@map_data.xsize
        # Passes Through Z Coordinates
        for y in 0...@map_data.ysize
          # Collects Tile ID
          id = @map_data[x, y, z]
          # Skip if 0 tile
          next if id == 0
          # Passes Through All Priorities
          for p in 0..5
            # Skip If Priority Doesn't Match
            next unless p == @priorities[id]
            # Cap Priority to Layer 3
            p = 2 if p > 2
            # Draw Tile
            id < 384 ? draw_autotile(x, y, p, id) : draw_tile(x, y, p, id)
          end
        end
      end
    end
  end    
  #--------------------------------------------------------------------------
  # * Refresh Auto-Tiles
  #--------------------------------------------------------------------------
  def refresh_autotiles
    # Auto-Tile Locations
    autotile_locations = Table.new(@map_data.xsize, @map_data.ysize, 
      @map_data.zsize)
    # Get X Tiles
    x1 = [@ox / @tilesize - Tilemap_Options::Viewport_Padding, 0].max.round
    x2 = [@viewport.rect.width / @tilesize + 
          Tilemap_Options::Viewport_Padding, @map_data.xsize].min.round
    # Get Y Tiles
    y1 = [@oy / @tilesize - Tilemap_Options::Viewport_Padding, 0].max.round
    y2 = [@viewport.rect.height / @tilesize + 
          Tilemap_Options::Viewport_Padding, @map_data.ysize].min.round
    # Passes Through Layers
    for z in 0...@map_data.zsize
      # Passes Through X Coordinates
      for x in x1...x2
        # Passes Through Y Coordinates
        for y in y1...y2
          # Collects Tile ID
          id = @map_data[x, y, z]
          # Skip if 0 tile
          next if id == 0
          # Skip If Non-Animated Tile
          next unless @autotiles[id / 48 - 1].width / 96 > 1 if id < 384
          # Passes Through All Priorities
          for p in 0..5
            # Skip If Priority Doesn't Match
            next unless p == @priorities[id]
            # Cap Priority to Layer 3
            p = 2 if p > 2
            # If Autotile
            if id < 384
              # Draw Auto-Tile
              draw_autotile(x, y, p, id)
              # Draw Higher Tiles
              for l in 0...@map_data.zsize
                id_l = @map_data[x, y, l]
                draw_tile(x, y, p, id_l)
              end
              # Save Autotile Location
              autotile_locations[x, y, z] = 1
            # If Normal Tile
            else
              # If Autotile Drawn
              if autotile_locations[x, y, z] == 1
                # Redraw Normal Tile
                draw_tile(x, y, p, id)
                # Draw Higher Tiles
                for l in 0...@map_data.zsize
                  id_l = @map_data[x, y, l]
                  draw_tile(x, y, p, id_l)
                end
              end
            end
          end
        end
      end
    end
  end      
  #--------------------------------------------------------------------------
  # * Draw Tile
  #--------------------------------------------------------------------------
  def draw_tile(x, y, z, id)
    # Gets Tile Bitmap
    bitmap = RPG::Cache.tile(@tileset_name, id, @hue)
    # Calculates Tile Coordinates
    x *= @tilesize
    y *= @tilesize
    # Draw Tile
    if @tilesize == 32
      @layers[z].bitmap.blt(x, y, bitmap, Rect.new(0, 0, 32, 32))
    else
      rect = Rect.new(x, y, @tilesize, @tilesize)
      @layers[z].bitmap.stretch_blt(rect, bitmap, Rect.new(0, 0, 32, 32))
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Auto-Tile
  #--------------------------------------------------------------------------
  def draw_autotile(x, y, z, tile_id)
    # Gets Autotile Filename
    filename = @autotiles_name[tile_id / 48 - 1]
    # Reconfigure Tile ID
    tile_id %= 48
    # Gets Generated Autotile Bitmap Section
    bitmap = RPG::Cache.autotile_tile(filename, tile_id, @hue)
    return if bitmap == nil
    # Calculates Tile Coordinates
    x *= @tilesize
    y *= @tilesize
    # If Normal Tile
    if @tilesize == 32
      @layers[z].bitmap.blt(x, y, bitmap, Rect.new(0, 0, 32, 32))
    # If Altered Dimensions
    else
      dest_rect = Rect.new(x, y, @tilesize, @tilesize)
      @layers[z].bitmap.stretch_blt(dest_rect, bitmap, Rect.new(0, 0, 32, 32))
    end
  end
  #--------------------------------------------------------------------------
  # * Collect Bitmap
  #--------------------------------------------------------------------------
  def bitmap
    # Creates New Blank Bitmap
    bitmap = Bitmap.new(@layers[0].bitmap.width, @layers[0].bitmap.height)
    # Passes Through All Layers
    for layer in @layers
      bitmap.blt(0, 0, layer.bitmap, 
        Rect.new(0, 0, bitmap.width, bitmap.height))
    end
    # Return Bitmap
    return bitmap
  end
end


