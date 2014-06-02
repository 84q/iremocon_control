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
    #
    def initialize(host, port=51013, logger:nil)
      @host = host
      @port = port.to_i
      @logger = (logger.is_a?(Logger) ? logger : Logger.new(logger))
    end
    
    #
    # 接続の確認用コマンド
    #
    def au
      reply = send("*au")
      reply[0] == "ok" ? true : get_error(reply)
    end
    
    #
    # 赤外線発光用コマンド
    #
    def is(remocon_id)
      reply = send("*is", remocon_id)
      reply[1] == "ok" ? true : get_error(reply)
    end
  
    #
    # リモコン学習開始用コマンド
    #
    def ic(remocon_id)
      reply = send("*ic", remocon_id)
      reply[1] == "ok" ? true : get_error(reply)
    end
  
    #
    # リモコン学習中止用コマンド
    #
    def cc
      reply = send("*cc")
      reply[1] == "ok" ? true : get_error(reply)
    end
  
    #
    # タイマーセット用コマンド
    #
    def tm(remocon_id, time, repeat_interval = 0)
      reply = send("*tm", remocon_id, time.to_i, repeat_interval)
      reply[1] == "ok" ? true : get_error(reply)
    end
  
    #
    # タイマー一覧取得用コマンド
    #
    def tl
      reply = send("*tl")
      reply[1] == "ok" ? reply[3..-1].map(&:to_i).each_slice(4).to_a : get_error(reply)
    end
  
    #
    # タイマー解除用コマンド
    #
    def td(timer_id)
      reply = send("*td", timer_id)
      reply[1] == "ok" ? true : get_error(reply)
    end
  
    #
    # 現在時刻設定用コマンド
    #
    def ts(time)
      reply = send("*ts", time.to_i)
      reply[1] == "ok" ? true : get_error(reply)
    end
  
    #
    # 現在時刻取得用コマンド
    #
    def tg
      reply = send("*tg")
      reply[1] == "ok" ? reply[2].to_i : get_error(reply)
    end
  
    #
    # ファームバージョン番号の取得用コマンド
    #
    def vr
      reply = send("*vr")
      reply[1] == "err" ? get_error(reply) : reply[0]
    end
    
    private
    
    def send(*cmds)
      begin
        reply = _send(*cmds)
      rescue => e
        @logger.warn "#{cmds} -> #{e}"
        raise e
      end
      @logger.info "#{cmds} -> #{reply}"
      reply
    end
    
    def _send(*cmds)
      telnet = Net::Telnet.new('Host' => @host, 'Port' => @port)
      
      code = ""
      telnet.cmd(cmds.join(";")) do |res|
        code << res;
        break if res =~ /\n$/
      end
      
      telnet.close
      return code.chomp.split(";")
    end
    
    def get_error(reply)
      cmd = reply[0]
      err_no = reply[2]
      return IRemoconError.new cmd, err_no
    end
  end
end

# vim: sw=2 ts=2 sts=2 et
