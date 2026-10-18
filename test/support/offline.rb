# frozen_string_literal: true
# Core/adapter tests forbid TCP. Browser tests permit loopback for their own
# server and driver; an external provider remains forbidden.
require "socket"
module RailsToolViewsOfflineNetwork
  def self.loopback?(host)
    ENV["RAILS_TOOL_VIEWS_SYSTEM_TEST"] == "1" && %w[127.0.0.1 ::1 localhost].include?(host)
  end
end
module RailsToolViewsOfflineTCP
  def new(host, ...)
    raise "Network access is disabled in RailsToolViews tests" unless RailsToolViewsOfflineNetwork.loopback?(host)
    super
  end
end
module RailsToolViewsOfflineSocket
  def tcp(host, ...)
    raise "Network access is disabled in RailsToolViews tests" unless RailsToolViewsOfflineNetwork.loopback?(host)
    super
  end
end
TCPSocket.singleton_class.prepend(RailsToolViewsOfflineTCP)
Socket.singleton_class.prepend(RailsToolViewsOfflineSocket)
