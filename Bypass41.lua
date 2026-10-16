local function findExecutableSegment(lib)
local ranges=gg.getRangesList(lib)
for _,v in ipairs(ranges) do
if v.type:find("-x") then return v.start end
end
return nil
end
local function readValue(address,flags)
return gg.getValues({[1]={address=address,flags=flags}})[1].value
end
local function writeValue(address,flags,value,freeze)
local item={address=address,flags=flags,value=value,freeze=freeze}
if freeze then gg.addListItems({item}) else gg.setValues({item}) end
end

function setvalue(address,flags,value,freeze) if address == 0 then return end local tt={} tt[1]={} tt[1].address=address tt[1].flags=flags tt[1].value=value tt[1].freeze=freeze if freeze==false then gg.setValues(tt) end gg.addListItems(tt) end
function getvalue(address,flags,value,freeze) if address == 0 then return end local tt={} tt[1]={} tt[1].address=address tt[1].flags=flags gg.addListItems(tt) end
function autovalue(address,flags,_o,_v,freeze) if address == 0 then return end local tt={} tt[1]={} tt[1].address=address tt[1].flags=flags tt[1].freeze=freeze local _v_ = gg.getValues(tt)[1].value if math.abs(_v_-_o) < 1e-7 then tt[1].value=_v else tt[1].value=_o end if freeze==false then gg.setValues(tt) end gg.addListItems(tt) end
function readD(address) return gg.getValues({{address = address, flags = 4}})[1].value end 
function S_Pointer(t_So, t_Offset, _bit)
	local function getRanges()
		local ranges = {}
		local t = gg.getRangesList('^/data/*.so*$')
		for i, v in pairs(t) do
			if v.type:sub(2, 2) == 'w' then
				table.insert(ranges, v)
			end
		end
		return ranges
	end
	local function Get_Address(N_So, Offset, ti_bit)
		local ti = gg.getTargetInfo()
		local t = {}
		local _t
		local _S = nil
		if ti_bit then
			_t = 32
		 else
			_t = 4
		end
		local _S = gg.getRangesList(N_So[1])[1]
		if _S then
			t[#t + 1] = {}
			t[#t].address = _S.start + Offset[1]
			t[#t].flags = _t
			if #Offset ~= 1 then
				for i = 2, #Offset do
					local S = gg.getValues(t)
					t = {}
					for _ in pairs(S) do
						if not ti.x64 then
							S[_].value = S[_].value & 0xFFFFFFFF
						else
						    S[_].value = S[_].value & 0xFFFFFFFFFF
						end
						t[#t + 1] = {}
						t[#t].address = S[_].value + Offset[i]
						t[#t].flags = _t
					end
				end 

			end
			_S = t[#t].address

		end
		return _S
	end
	local ttt = Get_Address(t_So, t_Offset, _bit)
	if ttt ~= nil then
	local _A = string.format('0x%X', ttt)
	return _A
	end
	return 0
end

function RDI(address) return gg.getValues({{address = address, flags = 4}})[1].value & 0xFFFFFFFF  end
function RQI(address) return gg.getValues({{address = address, flags = gg.TYPE_QWORD}})[1].value end

function Format(tab, format, value, type, Function)
if format == "查看" then
tab[1]["flags"] = type
return print(gg.getValues(tab))
elseif format == "修改" then
tab[1]["flags"] = type
tab[1]["value"] = value
return gg.setValues(tab)
elseif format == "冻结" then
tab[1]["flags"] = type
tab[1]["freeze"] = true
tab[1]["value"] = value
tab[1]["name"] = Function or "功能"   
return gg.addListItems(tab)
elseif format == "加载" then
tab[1]["flags"] = type

return gg.loadResults(tab)
end
end

function LSQ_Chain(so, offset, format, value, type, Function)--模块设置, 偏移量, 功能参数, 修改值, 类型, 功能
getRanges = getRanges or (function()
local ranges = {}		
		local t = gg.getRangesList('^/data/*.so*$')
		for i, v in pairs(t) do
			if v["type"]:sub(2, 2) == 'w' then--判断so是否可读可写
			ranges[#ranges+1] = v
			end
		end
	return ranges
end)
local rest, ranges, sostart, valtype = {}, getRanges(), nil , gg.TYPE_DWORD
if gg.getTargetInfo()["x64"] then--判断应用程序是否为64位
valtype = gg.TYPE_QWORD
end

for i in pairs(ranges) do
		local _name = ranges[i]["internalName"]:gsub('^.*/', '')
		if so[1] == _name and so[2] == ranges[i]["state"] then
			sostart = ranges[i]["start"]
			break
		end
	end
	
if sostart then	
if offset[1]  then		
for i = 1, #offset do	
	rest = {{flags = valtype,address = sostart + offset[i]}}
	rest = gg.getValues(rest)
		if i == #offset then
break
end
	 		if valtype == gg.TYPE_DWORD then
				sostart = rest[1].value & 0xFFFFFFFF--对值进行补位操作 
				else
				sostart = rest[1].value			
			end
		end
	end		
	if #rest == 1 then
	   
	end
	return Format(rest, format, value, type, Function)
end
gg.toast("功能:" .. Function .. "开启失败")
print("功能开启失败原因: 未找到基址头")
return os.exit()
end

-- 读取内存地址的函数
function readPointer(name, offset, i)
local re = gg.getRangesList(name)  local x64 = gg.getTargetInfo().x64  local va = {[true]=32, [false]=4}  if re[i or 1] then local addr = re[i or 1].start + offset[1]  for i = 2, #offset do addr = gg.getValues({{address=addr, flags=va[x64]}})  if not x64 then addr[1].value = addr[1].value & 0xFFFFFFFF end addr = addr[1].value + offset[i] end return addr end end
-- 修改内存地址的函数
function gg.edits(addr, Table, name)
local Table1 = {{}, {}}  for k, v in ipairs(Table) do local value = {address = addr+v[3], value = v[1], flags = v[2], freeze = v[4]} if v[4] then Table1[2][#Table1[2]+1] = value else Table1[1][#Table1[1]+1] = value end end gg.addListItems(Table1[2]) gg.setValues(Table1[1]) gg.toast((name or "") .. "开启成功, 共修改"..#Table.."个值") end

function readPointer(name, offset, i)
    local re = gg.getRangesList(name)
    local x64 = gg.getTargetInfo().x64
    local va = { [true] = 32, [false] = 4 }
    if re[i or 1] then
        local addr = re[i or 1].start + offset[1]
        for i = 2, #offset do
            addr = gg.getValues({ { address = addr, flags = va[x64] } })
            if not x64 then
                addr[1].value = addr[1].value & 0xFFFFFFFF
            else
                addr[1].value = addr[1].value & 0xFFFFFFFFFF
            end
            addr = addr[1].value + offset[i]
        end
        return addr
    end
end
local t = {"libUE4.so"}
--开火
local tt = {0xF1CE084}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", true)
local tt = {0xF1CE088}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", true)
local tt = {0xF1CDD8C}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", true)
local tt = {0xF1CDD90}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 B [PC,#0x5D0]", true)
local tt = {0xF1CEBDC}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 MOV X0, XZR", true)
local tt = {0xF1CEBE0}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", true)
local tt = {0xF1CFE78}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", true)
local tt = {0xF1CFFD0}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 B [PC,#0x1104]", true)
local tt = {0xEA9C964}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 B [PC,#0x21C]", true)
local tt = {0xEA9C994}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 B [PC,#0x1EC]", true)
local tt = {0xEA9CA24}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 B [PC,#0x140]", true)
local tt = {0xEA9C8C8}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 RET", true)

local t = {"libtersafe.so"}
local tt = {0x1F56C0}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 RET", true)--登出VM
local tt = {0x1F2C6C}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 RET", true)--登出VM
local tt = {0x1D307C}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", true)--过飞机禁网
local tt = {0x3929F0}local ttt = S_Pointer(t,tt,true)setvalue(ttt, 4, "~A8 RET", true)--hash上下文
local tt = {0x457680}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 B [PC,#0x2C]", true)--hash计算
local tt = {0x3b4804}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", true)--hash扫描
local tt = {0x4a3d9c}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 LDRB W9, [X0]", true)--crc计算
local tt = {0x332BE4}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 LDRB W13, [X1]", true)--crc32
local tt = {0x33096C}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 LDRB W15, [X0]", true)--crc16
local tt = {0x23B1D8}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", true)--过特征
local tt = {0x23B188}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", true)--过特征
local tt = {0x1D1ACC}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", true)--过特征
local tt = {0x435CC4}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 MOVZ W0, #0", true)--mrpcs异常上报
local tt = {0x39715C}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 MOV X0, XZR", true)--mrpcs扫描
local tt = {0x446404}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 B [PC,#0x1C]", true)--mrpcs初始化
local tt = {0x4463d8}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 MOV X0, XZR", true)--mrpcs初始化
local tt = {0x457540}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 MOV X0, XZR", true)--memcpy扫描
local tt = {0x4BDBE8}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 RET", true)--text防闪
local tt = {0x503A24}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 RET", true)--get2
local tt = {0x23B1F8}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 CMP W9, #0x1", true)--get3
local tt = {0x23B1FC}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP ", true)--get3
local tt = {0x1D9584}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 MOV X0, XZR", true)--data4
local tt = {0x1E47F0}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 MOV X0, XZR", true)--get4
local tt = {0x47c444}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", true)--case35

local t = {"libtprt.so"}
local tt = {0xE057C}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 RET", false)--tprt text段校验
local tt = {0x11CA3C}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 NOP", false)--tprt完整性校验
local tt = {0x1226EC}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 RET", false)--过修改tprt导致的闪退
local tt = {0x122A4C}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 RET", false)--过修改tprt导致的对局闪退
local tt = {0x11D028}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 RET", false)--tprt CRC校验1
local tt = {0x11D080}local ttt = S_Pointer(t,tt,true)setvalue(ttt,4, "~A8 RET", false)--tprt CRC校验2