class SnowflakeIdGenerator
  EPOCH = 1_620_000_000_000 # your custom epoch
  MACHINE_ID = ENV.fetch("MACHINE_ID", 42).to_i

  def initialize
    @sequence = 0
    @last_timestamp = -1
    @mutex = Mutex.new
  end

  def next_id
    @mutex.synchronize do
      timestamp = current_millis

      if timestamp == @last_timestamp
        @sequence = (@sequence + 1) & 0xfff
        if @sequence == 0
          # wait until next millisecond
          timestamp = wait_next_millis(timestamp)
        end
      else
        @sequence = 0
      end

      @last_timestamp = timestamp

      ((timestamp - EPOCH) << 22) | (MACHINE_ID << 12) | @sequence
    end
  end

  private

  def current_millis
    (Time.now.to_f * 1000).to_i
  end

  def wait_next_millis(last_ts)
    ts = current_millis
    ts = current_millis while ts <= last_ts
    ts
  end
end
