#encoding: utf-8

require 'net/telnet'
require 'logger'
require_relative 'iremocon_control/iremocon_error.rb'
require_relative 'iremocon_control/version.rb'

module IRemoconControl
  
  #
  # iRemoconを操作するクラス
  #
  class IRemocon
    attr_reader :host, :port, :logger
    
    #
    # コンストラクタ
    # @param [String] host IRemoconのホスト名(またはIPアドレス)
    # @param [Integer] port IRemoconのポート番号
    # @param [String,Logger,IO] logger ログの出力先(出力しない場合、nil)
    #
    def initialize(host, port=51013, logger:nil)
      @host = host
      @port = port.to_i
      @logger = (logger.is_a?(Logger) ? logger : Logger.new(logger))
      @logger.level = Logger::WARN
    end
    
    #
    # 接続の確認用コマンド
    # @return [TrueClass] 常にtrue
    # @raise [TelnetConnectionError] 通信エラーが発生した場合
    # @raise [IRemoconError] IRemoconからエラーが帰ってきた場合
    #
    def au
      reply = send_cmd("*au")
      true
    end
    
    #
    # 赤外線発光用コマンド
    # @param [Integer] remocon_id 発行するリモコンID
    # @return [TrueClass] 常にtrue
    # @raise [TelnetConnectionError] 通信エラーが発生した場合
    # @raise [IRemoconError] IRemoconからエラーが帰ってきた場合
    #
    def is(remocon_id)
      reply = send_cmd("*is", remocon_id)
      true
    end
  
    #
    # リモコン学習開始用コマンド
    # @param [Integer] remocon_id 学習するリモコンID
    # @return [TrueClass] 常にtrue
    # @raise [TelnetConnectionError] 通信エラーが発生した場合
    # @raise [IRemoconError] IRemoconからエラーが帰ってきた場合
    #
    def ic(remocon_id)
      reply = send_cmd("*ic", remocon_id)
      true
    end
  
    #
    # リモコン学習中止用コマンド
    # @return [TrueClass] 常にtrue
    # @raise [TelnetConnectionError] 通信エラーが発生した場合
    # @raise [IRemoconError] IRemoconからエラーが帰ってきた場合
    #
    def cc
      reply = send_cmd("*cc")
      true
    end
  
    #
    # タイマーセット用コマンド
    # @param [Integer] remocon_id タイマーをセットするリモコンID
    # @param [Time] time 次回の日時
    # @param [Time] repeat_interval 繰り返し秒数(繰り返さない場合、0)
    # @return [TrueClass] 常にtrue
    # @raise [TelnetConnectionError] 通信エラーが発生した場合
    # @raise [IRemoconError] IRemoconからエラーが帰ってきた場合
    #
    def tm(remocon_id, time, repeat_interval = 0)
      reply = send_cmd("*tm", remocon_id, time.to_i, repeat_interval)
      true
    end
  
    #
    # タイマー一覧取得用コマンド
    # @return [Array<IRemoconTimer>] タイマー一覧
    # @raise [TelnetConnectionError] 通信エラーが発生した場合
    # @raise [IRemoconError] IRemoconからエラーが帰ってきた場合
    #
    def tl
      reply = send_cmd("*tl")
      reply[3..-1].map(&:to_i).each_slice(4).map {|timer_id, remocon_id, time, repeat_interval|
        IRemoconTimer.new(timer_id, remocon_id, Time.at(time), repeat_interval);
      }
    end
  
    #
    # タイマー解除用コマンド
    # @param [Integer] timer_id 解除するタイマーID
    # @return [TrueClass] 常にtrue
    # @raise [TelnetConnectionError] 通信エラーが発生した場合
    # @raise [IRemoconError] IRemoconからエラーが帰ってきた場合
    #
    def td(timer_id)
      reply = send_cmd("*td", timer_id)
      true
    end
    
    #
    # 現在時刻設定用コマンド
    # @param [Integer] time 現在時刻
    # @return [TrueClass] 常にtrue
    #
    def ts(time)
      reply = send_cmd("*ts", time.to_i)
      true
    end
  
    #
    # 現在時刻取得用コマンド
    # @return [Time] 現在時刻
    # @raise [TelnetConnectionError] 通信エラーが発生した場合
    # @raise [IRemoconError] IRemoconからエラーが帰ってきた場合
    #
    def tg
      reply = send_cmd("*tg")
      Time.at(reply[2].to_i)
    end
  
    #
    # ファームバージョン番号の取得用コマンド
    # @return [String] バージョン番号
    # @raise [TelnetConnectionError] 通信エラーが発生した場合
    # @raise [IRemoconError] IRemoconからエラーが帰ってきた場合
    #
    def vr
      reply = send_cmd("*vr")
      reply[0]
    end
    
    #
    # ネットワーク上からiRemoconを見つける
    # @param num_iremocon [Integer] ネットワーク上のiRemoconの数
    # @param timeout [Integer] 探索のタイムアウト
    # @return [Array<String>] iRemoconのIPアドレス文字列の配列
    #
    def self.find(num_iremocon = 1, timeout = 5)
      sock = UDPSocket.open()
      sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1)
      sock.bind("0.0.0.0", 0)
      
      # メッセージをブロードキャスト
      sock.send("FIND", 0, "<broadcast>", 1460)
      
      ips = []
      begin
        # タイムアウト設定
        timeout(timeout) do
          # タイムアウトまで繰り返す
          while true
            # 受信待ち
            mesg, sockaddr = sock.recvfrom(512)
            # iRemoconが見つかったら登録
            ips << sockaddr[3] if sockaddr and sockaddr[3]
            # num_iremocon個見つかったら修了
            break if ips.uniq!.size == num_iremocon
          end
        end
      rescue
        # タイムアウトまでnum_iremocon個見つからなかった場合
        nil
      end
      
      ips
    end
    
    private
    
    def send_cmd(*cmds)
      begin
        reply = _send_cmd(*cmds)
      rescue => e
        @logger.error "#{cmds} -> #{e}"
        raise e
      end
      
      if IRemoconError.error? reply
        error = IRemoconError.get_error reply
        @logger.warn "#{cmds} -> #{error}"
        raise error
      else
        @logger.info "#{cmds} -> #{reply}"
      end
      reply
    end
    
    def _send_cmd(*cmds)
      begin
        telnet = Net::Telnet.new('Host' => @host, 'Port' => @port)
        
        code = ""
        telnet.cmd(cmds.join(";")) do |res|
          code << res;
          break if res =~ /\n$/
        end
        
        telnet.close
      rescue
        raise TelnetConnectionError.new("IRemocon Connection Error - #{@host}:#{@port}")
      end
      return code.chomp.split(";")
    end
  end
  
  class TelnetConnectionError < StandardError; end
  
  #
  # iRemoconのTimerを管理するクラス
  #
  class IRemoconTimer
    attr_reader :timer_id, :remocon_id, :time, :repeat_interval
    
    def initialize(timer_id, remocon_id, time, repeat_interval)
      @timer_id, @remocon_id, @time, @repeat_interval = timer_id, remocon_id, Time.at(time), repeat_interval;
    end
    
    def to_s
      "remocon_id : #{@remocon_id}, next : #{@time}, repeat : #{@repeat_interval}"
    end
    
    alias_method :inspect, :to_s
  end
end

# vim: sw=2 ts=2 sts=2 et
