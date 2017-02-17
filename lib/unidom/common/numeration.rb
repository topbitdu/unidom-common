##
# Numeration 是数字格式转换的辅助类。

class Unidom::Common::Numeration

  ##
  # 将二进制数据转换成 16 进制的表达。如：
  # Unidom::Common::Numeration.hex [ 'A', '}' ]
  def self.hex(data)
    data.present? ? data.unpack('H*')[0] : nil
  end

  ##
  # 将十六进制数的表达字符串，转换成二进制数据。如：
  # Unidom::Common::Numeration.rev_hex '6CA0'
  def self.rev_hex(hex)
    hex.present? ? hex.scan(/../).map(&:hex).pack('c*') : nil
  end

end
