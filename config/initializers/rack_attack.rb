# Block requests from 1.2.3.4
Rack::Attack.blacklist('block 46.105.44.24') do |req|
  # Request are blocked if the return value is truthy
  '46.105.44.24' == req.ip
end

# Block spammer
Rack::Attack.blacklist('block /blog/xmlrpc.php') do |req|
  req.path == '/blog/xmlrpc.php'
end

# Block requests containing '/etc/password' in the params.
# After 3 blocked requests in 10 minutes, block all requests from that IP for 5 minutes.
Rack::Attack.blacklist('fail2ban pentesters') do |req|
  # `filter` returns truthy value if request fails, or if it's from a previously banned IP
  # so the request is blocked
  Rack::Attack::Fail2Ban.filter(req.ip, :maxretry => 3, :findtime => 10.minutes, :bantime => 5.minutes) do
    # The count for the IP is incremented if the return value is truthy.
    CGI.unescape(req.query_string) =~ %r{/etc/passwd}
  end
end
