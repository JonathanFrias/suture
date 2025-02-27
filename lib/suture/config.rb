require "suture/comparator"

module Suture
  DEFAULT_OPTIONS = {
    :comparator => Comparator.new,
    :log_level => "INFO",
    :log_stdout => true,
    :log_io => nil,
    :log_file => nil,
    :raise_on_result_mismatch => true,
    :adapter_options => {
      :adapter => "sqlite",
      :database_path => "db/suture.sqlite3",
    }
  }

  def self.config(config = {})
    @config ||= DEFAULT_OPTIONS.dup
    @config.merge!(config)
  end

  def self.config_reset!
    @config = DEFAULT_OPTIONS.dup
  end
end
