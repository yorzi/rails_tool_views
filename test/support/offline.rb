# frozen_string_literal: true
# Tests may use SQLite and process pipes, but cannot contact an external provider.
require "socket"
module RailsToolViewsOfflineTCP
  def new(*)
    raise "Network access is disabled in RailsToolViews tests"
  end
end
module RailsToolViewsOfflineSocket
  def tcp(*)
    raise "Network access is disabled in RailsToolViews tests"
  end
end
TCPSocket.singleton_class.prepend(RailsToolViewsOfflineTCP)
Socket.singleton_class.prepend(RailsToolViewsOfflineSocket)
