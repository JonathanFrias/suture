module Suture::Util
  module Env
    def self.to_map(excludes = {})
      envs = suture_envs(excludes)
      adapter_envs = suture_adapter_envs(excludes)

      if adapter_envs.any?
        envs.merge(:adapter_options => adapter_envs)
      else
        envs
      end
    end

    def self.to_sym(name)
      name.gsub(/^SUTURE_ADAPTER_|^SUTURE\_/, "").downcase.to_sym
    end

    def self.sanitize_value(value)
      if value == "false"
        false
      elsif value == "true"
        true
      else
        value
      end
    end

    private

    def self.suture_envs(excludes)
      Hash[
        ENV.keys.
          select { |k| k.start_with?("SUTURE_") && !k.start_with?("SUTURE_ADAPTER") }.
          map { |k| [to_sym(k), sanitize_value(ENV[k])] }
      ].reject { |(k, _)| excludes.include?(k) }
    end

    def self.suture_adapter_envs(excludes)
      Hash[
        ENV.keys.
          select { |k| k.start_with?("SUTURE_ADAPTER") }.
          map { |k| [to_sym(k), sanitize_value(ENV[k]) ] }
      ].reject { |(k, _)| excludes.include?(k) }
    end
  end
end
