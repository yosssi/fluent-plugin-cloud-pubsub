require 'gcloud'

module Fluent
  class CloudPubSubOutput < BufferedOutput
    MAX_REQ_SIZE = 10 * 1024 * 1024 # 10 MB
    MAX_MSGS_PER_REQ = 1000

    Plugin.register_output('cloud_pubsub', self)

    config_param :project,          :string,  :default => nil
    config_param :topic,            :string,  :default => nil
    config_param :key,              :string,  :default => nil
    config_param :max_req_size,     :integer, :default => MAX_REQ_SIZE
    config_param :max_msgs_per_req, :integer, :default => MAX_MSGS_PER_REQ

    unless method_defined?(:log)
      define_method("log") { $log }
    end

    unless method_defined?(:router)
      define_method("router") { Fluent::Engine }
    end

    def configure(conf)
      super

      raise Fluent::ConfigError, "'project' must be specified." unless @project
      raise Fluent::ConfigError, "'topic' must be specified." unless @topic
      raise Fluent::ConfigError, "'key' must be specified." unless @key
    end

    def start
      super

      pubsub = (Gcloud.new @project, @key).pubsub
      @client = pubsub.topic @topic
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def publish(msgs)
      log.debug "publish #{msgs.length} messages"

      @client.publish do |batch|
        msgs.each do |m|
          batch.publish m
        end
      end
    end

    def write(chunk)
      msgs = []
      msgs_size = 0

      chunk.msgpack_each do |tag, time, record|
        size = Yajl.dump(record).bytesize
        if msgs.length > 0 && (msgs_size + size > @max_req_size || msgs.length + 1 > @max_msgs_per_req)
          publish(msgs)
          msgs = []
          msgs_size = 0
        end
        msgs << record.to_json
        msgs_size += size
      end

      if msgs.length > 0
        publish(msgs)
      end
    rescue
      log.error "unexpected error", :error=>$!.to_s
      log.error_backtrace
    end
  end

end
