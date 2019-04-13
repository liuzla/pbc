local protobuf = require "protobuf"
-- 主目录make -> cd binding && make 生成protobuf.so
-- ./gen_pb.sh 生成.pb文件


local path = "pb/"
local fp = io.popen("ls "..path)
for file in fp:lines() do
	protobuf.register_file(path..file)
end
fp:close()

-- c2s 
c2s_change_name = 1001
c2s_get_card_info = 1002

-- s2c
s2c_player_base = 10001

C2S_MAP = {
	[c2s_change_name] = "c2s_change_name",
	[c2s_get_card_info] = "c2s_get_card_info",
}

S2C_MAP = {
	[s2c_player_base] = "s2c_player_base",
}

-- c2s 
local session = 0
local function pack_request(itype, args)
	local pbname = C2S_MAP[itype]
	assert(pbname, "not find type"..itype)
	local pbcode = protobuf.encode("game."..pbname, args)
	session = session + 1
	return string.pack(">I2>I4>s2", itype, session, pbcode), session
end

local function unpack_request(msg)
	local itype, isession, pbcode = string.unpack(">I2>I4>s2", msg)
	local pbname = C2S_MAP[itype]
	assert(pbname, "not find type"..itype)
	local args = protobuf.decode("game."..pbname, pbcode)
	return pbname, args, isession
end

-- s2c 
local function pack_response(itype, args, isession)
	local pbname = S2C_MAP[itype]
	assert(pbname, "not find type"..itype)
	local pbcode = protobuf.encode("game."..pbname, args)
	return string.pack(">I2>I4>s2", itype, isession or 0, pbcode)
end

local function unpack_response(msg)
	local itype, isession, pbcode = string.unpack(">I2>I4>s2", msg)
	local pbname = S2C_MAP[itype]
	assert(pbname, "not find type"..itype)
	local args = protobuf.decode("game."..pbname, pbcode)
	return pbname, args, isession
end

local function print_tb(tbl)
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			print("k-table do------>")
			print_tb(v)
			print("k-table end----->")
		else
			print("k, v--->", k, v)
		end
	end
end
-- test request
print("test request-------------------")
local pack_msg = pack_request(c2s_change_name, {name="test"})
local pbname, args, isession = unpack_request(pack_msg)
-- print("pack_msg", pack_msg)
print("pbname, isession", pbname, isession)
print_tb(args)

-- test response
print("test response-------------------")
local pack_msg = pack_response(s2c_player_base, {
		account = "test1",
		channel = 1,
		pid = 100001,
		name = "robot1",
		phone = {{number="18646351890",type="MOBILE"}},
		level = 99,
		cards = {{id=101, name="Q1", level=9}, {id=102, name="J1", level=7}}
	})
local pbname, args, isession = unpack_response(pack_msg)
print("pbname, isession", pbname, isession)
print_tb(args)












