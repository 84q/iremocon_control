#encoding: utf-8

require 'yaml'

module IRemoconControl
  class IRemoconError < StandardError
    FILE = File.expand_path(File.dirname(__FILE__)) + "/iremocon_error.yml"
    DEF = YAML.load_file(FILE)
    
    attr_reader :command, :code, :description
    
    def initialize(command, code)
      raise if DEF[@command]
      @command, @code = command, code 
      @desctiption = DEF[@command][@code]
      @desctiption ||= DEF["common"][@code]
    end
    
    def to_s
      @desctiption
    end
    
    def inspect
      "[#{@command}-#{@code}] #{@desctiption}"
    end
  end
end

# vim: sw=2 ts=2 sts=2 et
