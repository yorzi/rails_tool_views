# frozen_string_literal: true
# Tests may use SQLite and process pipes, but cannot contact an external provider.
require "socket"
module ToolViewsOfflineTCP
  def new(*)
    raise "Network access is disabled in ToolViews tests"
  end
end
module ToolViewsOfflineSocket
  def tcp(*)
    raise "Network access is disabled in ToolViews tests"
  end
end
TCPSocket.singleton_class.prepend(ToolViewsOfflineTCP)
Socket.singleton_class.prepend(ToolViewsOfflineSocket)
