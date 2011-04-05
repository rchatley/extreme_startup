require "socket"

def local_ip
  UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
end