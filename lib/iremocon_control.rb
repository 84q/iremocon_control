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
    #
    def au
      reply = send_cmd("*au")
      true
    end
    
    #
    # 赤外線発光用コマンド
    # @param [Integer] remocon_id 発行するリモコンID
    # @return [TrueClass] 常にtrue
    #
    def is(remocon_id)
      reply = send_cmd("*is", remocon_id)
      true
    end
  
    #
    # リモコン学習開始用コマンド
    # @param [Integer] remocon_id 学習するリモコンID
    # @return [TrueClass] 常にtrue
    #
    def ic(remocon_id)
      reply = send_cmd("*ic", remocon_id)
      true
    end
  
    #
    # リモコン学習中止用コマンド
    # @return [TrueClass] 常にtrue
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
    #
    def tm(remocon_id, time, repeat_interval = 0)
      reply = send_cmd("*tm", remocon_id, time.to_i, repeat_interval)
      true
    end
  
    #
    # タイマー一覧取得用コマンド
    # @return [Array<Array<Integer>>] タイマー(タイマーID,リモコンID,発光時刻,繰り返し秒数)一覧
    #
    def tl
      reply = send_cmd("*tl")
      reply[3..-1].map(&:to_i).each_slice(4).to_a
    end
  
    #
    # タイマー解除用コマンド
    # @param [Integer] timer_id 解除するタイマーID
    # @return [TrueClass] 常にtrue
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
    # @return [Integer] 現在時刻
    #
    def tg
      reply = send_cmd("*tg")
      reply[2].to_i
    end
  
    #
    # ファームバージョン番号の取得用コマンド
    # @return [String] バージョン番号
    #
    def vr
      reply = send_cmd("*vr")
      reply[0]
    end
    
    private
    
    def send_cmd(*cmds)
      begin
        reply = _send_cmd(*cmds)
      rescue => e
        @logger.error "#{cmds} -> #{e}"
        raise e
      end
      
      if error? reply
        error = get_error reply
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
      rescue
        raise StandardError.new("IRemocon Connection Error - #{@host}:#{port}")
      end
      
      code = ""
      telnet.cmd(cmds.join(";")) do |res|
        code << res;
        break if res =~ /\n$/
      end
      
      telnet.close
      return code.chomp.split(";")
    end
    
    def error?(reply)
      reply[1] == "err"
    end
    
    def get_error(reply)
      cmd = reply[0]
      err_no = reply[2]
      return IRemoconError.new cmd, err_no
    end
  end
end

# vim: sw=2 ts=2 sts=2 et
