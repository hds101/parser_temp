class Publisher
  def self.publish(queue, message = {})
    queue = channel.queue("gust.#{queue}", durable: true)
    channel.default_exchange.publish(message.to_json, routing_key: queue.name)
  end

  def self.channel
    @channel ||= connection.create_channel
  end

  def self.connection
    @connection ||= Bunny.new(host: 'rabbitmq', user: 'rabbitmq', pass: 'rabbitmq').tap do |c|
      c.start
    end
  end
end
