module FlappiLogger

  def self.depth=(v)
    @depth = v
  end

  def self.target(&block)
    @base_logger = block
  end

  def self.log(for_depth, msg)
    @base_logger.call(msg) if for_depth <= @depth
  end

  def self.e(msg)
    log(0, msg)
  end

  def self.w(msg)
    log(1, msg)
  end

  def self.i(msg)
    log(2, msg)
  end

  def self.d(msg)
    log(3, msg)
  end

  def self.t(msg)
    log(4, msg)
  end


end
