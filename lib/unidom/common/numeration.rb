##
# Numeration 是数字格式转换的辅助类。

class Unidom::Common::Numeration

  def self.hex(data)
    data.present? ? data.unpack('H*')[0] : nil
  end

  def self.rev_hex(hex)
    hex.present? ? hex.scan(/../).map(&:hex).pack('c*') : nil
  end

end
