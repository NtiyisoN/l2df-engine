--- Network manager
-- @classmod l2df.manager.network
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'NetworkManager works only with l2df v1.0 and higher')

local os = require 'os'
local enet = require 'enet'
local math = require 'math'
local socket = require 'socket'
local log = core.import 'class.logger'
local packer = core.import 'external.packer'
local Client = core.import 'class.client'

local pairs = _G.pairs
local rand = math.random
local strbyte = string.byte
local strmatch = string.match
local strformat = string.format

local sock = nil
local sockReady = false
local clients = { }
local masters = { }

local PENDING = -1

-- Client message codes
local INIT = 1
local FIND = 2

-- Master message codes
local FLUSH = 1
local JOIN = 2

if os.getenv('L2DF_MASTER') then
	masters[os.getenv('L2DF_MASTER')] = PENDING
end

local function discoverIP()
	local udp = socket.udp()
	if not udp:setpeername('www.google.com', 80) then
		log:error('Discovering IP has failed')
		udp:close()
		return nil
	end
	local result = udp:getsockname() or '255.255.255.255'
	udp:close()
	return result
end

local ClientEvents = { }
local ClientEventsMap = { }

local MasterEvents = {
	-- Connected to master
	connect = function (self, manager, host, event)
		if type(masters[host]) == 'userdata' then
			masters[host]:send( strformat('%c%s;%s', INIT, manager.ip, manager:username()) )
		end
	end,

	-- Disconnected from master
	disconnect = function (self, manager, host, event)
		local master = masters[host]
		if type(master) == 'userdata' then
			log:warn 'Lost connection to master'
			master:reset()
			masters[host] = PENDING
		end
	end,

	-- Received message from master
	receive = function (self, manager, host, event)
		local code, payload = strmatch(event.data, '^(.)(.*)')
		code = code and strbyte(code)
		if code and self[code] then
			self[code](self, manager, host, event, payload)
		end
	end,

	-- Request to link another peer
	[JOIN] = function (self, manager, host, event, payload)
		local client, ip = Client { events = ClientEvents, emap = ClientEventsMap }
		ip, client.name, client.private, client.public, client.port = strmatch(payload, '^(%S*);(%S*);(%S*);(%S*):(%S*)')
		if client.public == ip then -- under one NAT
			client.public = client.private
			client.private = ip
		end

		local endpoint = strformat('%s:%s', client.public, client.port)
		client.peer = sock:connect(endpoint)
		log:info('PeerID: %s, punching %s', client.peer:connect_id(), endpoint)
		clients[tostring(client.peer)] = client
	end,

	-- Drop all connections (leaving lobby)
	[FLUSH] = function (self, manager, host, event, payload)
		log:info('FLUSH')
		for k, client in pairs(clients) do
			client.peer:disconnect()
			client:disconnected(event)
		end
		clients = { }
	end
}

local Manager = { }

	--- Init networking
	-- @param string username
	-- @return l2df.manager.network
	function Manager:init(username)
		if self:isReady() then
			return self
		end

		self.ip = '127.0.0.1'
		self.name = assert(type(username) == 'string' and username, 'Username is required for NetworkManager')
		self.tag = rand(1000, 9999)
		if sock then
			sock:destroy()
		end
		sock = enet.host_create()
	end

	--- Determine if manager is ready to setup connetions
	-- @return boolean
	function Manager:isReady()
		return sock and sockReady
	end

	--- Determine if any client is connected
	-- @return boolean
	function Manager:isConnected()
		return next(clients) ~= nil
	end

	--- Register new master server
	-- @param string host
	-- @return l2df.manager.network
	function Manager:register(host)
		if masters[host] then return end
		-- TODO: add host validation
		-- TODO: resolve host (remove domains and etc)
		masters[host] = PENDING
		return self
	end

	--- Login to all registered masters and discover your public IP
	-- @return l2df.manager.network
	function Manager:login()
		self.ip = discoverIP() or '127.0.0.1'
		for host, master in pairs(masters) do
			if master == PENDING then
				masters[host] = sock:connect(host)
				sockReady = true
				log:debug('Connecting to master: %s', host)
			end
		end
		return self
	end

	--- Disconnects from all registered masters
	-- @return l2df.manager.network
	function Manager:logout()
		for host, master in pairs(masters) do
			if master ~= PENDING and master:state() ~= 'disconnected' then
				master:disconnect()
			end
			masters[host] = PENDING
		end
		return self
	end

	--- Send search request to master
	-- @param string username
	-- @return boolean
	function Manager:join(username)
		if not self:isReady() or not username then
			return false
		end

		for host, master in pairs(masters) do
			if master ~= PENDING and master:state() ~= 'disconnected' then
				master:send( strformat('%c%s', FIND, username) )
			end
		end
		return true
	end

	--- Returns an iterator on connected clients
	-- @return function
	function Manager:clients()
		local k, v
		return function ()
			k, v = next(clients, k)
			return v
		end
	end

	--- Register new network event
	-- @param string name
	-- @param string format
	-- @param function callback
	function Manager:event(name, format, callback)
		local id = #ClientEvents + 1
		assert(id < 256, 'Too much network events. Max supported count: 255')
		assert(ClientEvents[name] == nil, 'Attempt to register already existing network event')
		assert(type(callback) == 'function', 'Callback for network event must be a function')
		ClientEventsMap[name] = id
		ClientEvents[id] = { 'B' .. (format or ''), format or '', callback }
	end

	--- Broadcast event to all connected clients
	-- @param string event
	function Manager:broadcast(event, ...)
		event = event and ClientEventsMap[event] or 0
		local format = ClientEvents[event]
		if not (format and self:isConnected()) then return false end

		local result = true
		for k, client in pairs(clients) do
			result = result and client:rawsend(format[1], event, ...)
		end
		return result
	end

	--- Dispose all connections
	-- @return l2df.manager.network
	function Manager:destroy()
		self:logout()
		if sock then
			sock:flush()
			sock:destroy()
			sockReady = false
			sock = nil
		end
		return self
	end

	--- Get formatted username
	-- @return string
	function Manager:username()
		return strformat('%s#%s', self.name, self.tag)
	end

	--- Manager's update
	-- @param number dt
	function Manager:update(dt)
		if not self:isReady() then return end

		local event, client, endpoint = sock:service()
		while event do
			endpoint = tostring(event.peer)
			client = clients[endpoint] or Client({ events = ClientEvents, emap = ClientEventsMap, peer = event.peer })

			-- If it came from master
			if masters[endpoint] then
				if MasterEvents[event.type] then
					MasterEvents[event.type](MasterEvents, self, endpoint, event)
				end

			-- If it came from another peer
			elseif event.type == 'receive' then
				client:received(event)

			elseif event.type == 'connect' then
				-- Drop pending and attach to existen
				if client:state() ~= 'connected' then
					client.peer:reset()
					client.peer = event.peer
					log:success('Attached to %s', tostring(client.peer))

				-- Drop duplicated connection
				elseif event.peer:connect_id() < client.peer:connect_id() then
					client.peer:disconnect()
					client.peer = event.peer
					log:success('Switched to %s', tostring(client.peer))

				-- Connected, do nothing
				else
					log:success('Connected to %s', tostring(client.peer))
				end
				if ClientEventsMap.connected then
					ClientEvents[ClientEventsMap.connected][3](client, e)
				end
				clients[endpoint] = client:connected(event)

			elseif event.type == 'disconnect' and client.peer == event.peer then
				-- Failed to connect via public
				if client.attempts == 0 then
					endpoint = strformat('%s:%s', client.private, client.port)
					client.peer = sock:connect(endpoint)
					client.attempts = 1
					log:info('Connecting in local network: %s', endpoint)
					clients[tostring(client.peer)] = client

				-- Connection impossible: symmetric NAT, firewall and etc
				-- or just a simple disconnect
				else
					log:info('Disconnected from %s', endpoint)
					if ClientEventsMap.disconnected then
						ClientEvents[ClientEventsMap.disconnected][3](client, e)
					end
					client:disconnected(event)
					clients[endpoint] = nil
				end
			end
			event = sock:service()
		end
	end

return Manager