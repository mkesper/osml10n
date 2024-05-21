local osml10n = {}

local server_host = os.getenv("OSML10N_HOST") or 'localhost'
local server_port = os.getenv("OSML10N_PORT") or 8033

local socket = require('socket')
local sock = socket.connect(server_host, server_port)

if not sock then
    error("Can not connect to server " .. server_host .. ":" .. server_port ..
          ". Is geo-transcript-srv.py running?")
end

sock:setoption('tcp-nodelay', true)

function osml10n.geo_transcript(id,name,bbox)
  local lon,lat,reqbody
  local bx = {}
  if (bbox == nil) then
    reqbody = "CC/" .. id .. "/" .. "/" .. name
  else
    if (type(bbox) == "function") then
      bx[1], bx[2], bx[3], bx[4] = bbox()
    -- assume bbox is table type otherwise
    else
      bx = bbox
    end
    if (bx[1] ~= nil) then
      lon = (bx[1]+bx[3])/2.0
      lat = (bx[2]+bx[4])/2.0
    else
      lon = 0
      lat = 0
    end
    reqbody = "XY/" .. id .. "/" .. lon .. "/" .. lat .. "/" .. name
  end

  sock:send(string.pack('s4', reqbody))
  lendata, msg = sock:receive(4)
  if lendata == nil then
    error(msg)
  end
  length = string.unpack('I4', lendata)
  if (length > 0) then
      local response, msg = sock:receive(length)
      if response == nil then
        error(msg)
      end
      return response
  end
  return ''

end

return osml10n
