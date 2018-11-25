#encoding:utf-8
#==============================================================================
# ■ Bitmap
#------------------------------------------------------------------------------
# 　位图的类。所谓位图即表示图像其本身。
#==============================================================================
 
class Bitmap
  #--------------------------------------------------------------------------
  # ● 传送到内存的API函数
  #--------------------------------------------------------------------------
  RtlMoveMemory_pi = Win32API.new('kernel32', 'RtlMoveMemory', 'pii', 'i')
  #--------------------------------------------------------------------------
  # ● Bitmap地址
  #--------------------------------------------------------------------------
  # [[[bitmap.object_id * 2 + 16] + 8] + 16] == 数据的开头
  def address
    buffer, ad = "rgba", object_id * 2 + 16
    RtlMoveMemory_pi.call(buffer, ad, 4)
    ad = buffer.unpack("L")[0] + 8
    RtlMoveMemory_pi.call(buffer, ad, 4)
    ad = buffer.unpack("L")[0] + 16
    RtlMoveMemory_pi.call(buffer, ad, 4)
    return buffer.unpack("L")[0]
  end
 
  module Bitmap2PNG
    module_function
    Malloc = Win32API.new('msvcrt.dll','malloc','i','i')
    Memcpy_pi = Win32API.new('kernel32.dll','RtlMoveMemory','pii','v')
    Memcpy_ii = Win32API.new('kernel32.dll','RtlMoveMemory','iii','v')
    Memcpy_ip = Win32API.new('kernel32.dll','RtlMoveMemory','ipi','v')
    Free = Win32API.new('msvcrt.dll','free','i','v')
    Callsub = Win32API.new('user32.dll','CallWindowProcW','iiiii','i')
    #--------------------------------------------------------------------------
    # ● 主处理
    #-------------------------------------------------------------------------- 
    def make_png(bitmap_Fx)
      @bitmap_Fx = bitmap_Fx
      return make_header + make_ihdr + make_idat + make_iend
    end
    #--------------------------------------------------------------------------
    # ● PNG文件头数据块
    #--------------------------------------------------------------------------
    def make_header
      return [0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a].pack("C*")
    end
    #--------------------------------------------------------------------------
    # ● PNG文件情报头数据块(IHDR)
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
    # ● 生成图像数据(IDAT)
    #-------------------------------------------------------------------------- 
    def make_idat
      header = "IDAT"
      data = make_bitmap_data_dant
      data = Zlib::Deflate.deflate(data)
      crc = [Zlib.crc32(header + data)].pack("N")
      size = [data.length].pack("N")
      return size + header + data + crc
    end
    #--------------------------------------------------------------------------
    # ● 从Bitmap对象的原始数据生成PNG图像数据
    #-------------------------------------------------------------------------- 
    def make_bitmap_data_dant
      len = @bitmap_Fx.width * @bitmap_Fx.height * 4
      pBuf = Malloc.call(len)
      bitmap=@bitmap_Fx#.reverse
      addr=bitmap.address
      Memcpy_ii.call(pBuf,addr,len)
      Callsub.call(@pCode,pBuf,bitmap.width*bitmap.height,0,0)
      len2=len+bitmap.height
      len3=bitmap.width*4
      pBuf2 = Malloc.call(len2+512)
      pos=pBuf2
      pos2=pBuf+len-len3
      Memcpy_ip.call(pos,0.chr,1)
      pos+=1
      for i in 0...bitmap.height
        Memcpy_ii.call(pos,pos2,len3)
        pos+=len3
        pos2-=len3
        Memcpy_ip.call(pos,0.chr,1)
        pos+=1
      end
      buf="\0"*len2
      Memcpy_pi.call(buf,pBuf2,len2)
      Free.call(pBuf)
      Free.call(pBuf2)
#~       bitmap.dispose
      return buf
    end
    #--------------------------------------------------------------------------
    # ● PNG文件尾数据块(IEND)
    #-------------------------------------------------------------------------- 
    def make_iend
      return [0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,0x42,0x60,0x82].pack("C*")
      #ie_size = [0].pack("N")
      #ie_sign = "IEND"
      #ie_crc = [Zlib.crc32(ie_sign)].pack("N")
      #return ie_size + ie_sign + ie_crc
    end
 
    def init
      @pCode=Malloc.call(512)
=begin
      qwe proc src,pixels,un,used
      mov eax,src
      xor ecx,ecx
      .while ecx < pixels
      mov edx,[eax] ;AARRGGBB|BB GG RR AA
      bswap edx ;BBGGRRAA|AA RR GG BB
      ror edx,8 ;AABBGGRR|RR GG BB AA
      mov [eax],edx
      inc ecx
      add eax,4
      .endw
      ret
      qwe endp
=end
      code = [0x55,0x8B,0xEC,0x8B,0x45,0x8,0x33,0xC9,0xEB,0xD,0x8B,0x10,0xF,0xCA,0xC1,0xCA,0x8,0x89,0x10,0x41,0x83,0xC0,0x4,0x3B,0x4D,0xC,0x72,0xEE,0xC9,0xC2,0x10,0x0].pack('C*')
      Memcpy_ip.call(@pCode,code,code.length)
 
    end
 
    def close
      Free.call(@pCode)
    end
 
  end #Bitmap2PNG
 
  def save_png(filename)
    File.open(filename,"wb"){|f|f.write(Bitmap2PNG.make_png(self))}
  end
 
end #Bitmap
 
 
Bitmap::Bitmap2PNG.init
END {Bitmap::Bitmap2PNG.close}