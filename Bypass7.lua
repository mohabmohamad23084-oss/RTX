function WriteSignatures(original,GAMATARU) gg.setRanges(16384) gg.searchNumber("h"..original) gg.getResults(9999) gg.editAll("h"..GAMATARU,1) gg.clearResults() end
function split(szFullString, szSeparator)  local nFindStartIndex = 1  local nSplitIndex = 1  local nSplitArray = {}  while true do  local nFindLastIndex = string.find (szFullString, szSeparator, nFindStartIndex)  if not nFindLastIndex then  nSplitArray[nSplitIndex] =  string.sub(szFullString, nFindStartIndex, string.len (szFullString))  break end  nSplitArray[nSplitIndex] = string.sub (szFullString, nFindStartIndex, nFindLastIndex - 1)  nFindStartIndex = nFindLastIndex + string.len (szSeparator)  nSplitIndex = nSplitIndex + 1 end return  nSplitArray end  function xgxc(szpy, qmxg)  for x = 1, #(qmxg) do  xgpy = szpy + qmxg[x]["offset"]  xglx = qmxg[x]["type"]  xgsz = qmxg[x]["value"]  xgdj = qmxg[x]["freeze"]  if xgdj == nil or xgdj == "" then  gg.setValues({[1]  = {address = xgpy, flags = xglx, value = xgsz}})  else  gg.addListItems({[1]  = {address = xgpy, flags = xglx,  freeze = xgdj, value = xgsz}}) end  xgsl = xgsl + 1 xgjg = true end end  function xqmnb(qmnb)  gg.clearResults()  gg.setRanges(qmnb[1]["memory"])  gg.searchNumber(qmnb[3]["value"], qmnb[3]["type"])  if gg.getResultCount() == 0 then  gg.toast(qmnb[2]["name"] .. "开启失败")  else  gg.refineNumber(qmnb[3]["value"], qmnb[3]["type"]) gg.refineNumber(qmnb[3]["value"], qmnb[3]["type"])  gg.refineNumber(qmnb[3]["value"], qmnb[3]["type"])  if gg.getResultCount() == 0 then  gg.toast(qmnb[2]["name"] .. "开启失败")  else          sl = gg.getResults(999999)  sz = gg.getResultCount()          xgsl = 0 if sz > 999999 then  sz = 999999 end for i = 1, sz do  pdsz = true for v = 4, #(qmnb) do if  pdsz == true then  pysz = {} pysz[1]  = {} pysz[1].address  = sl[i].address + qmnb[v]["offset"] pysz[1].flags  = qmnb[v]["type"]  szpy = gg.getValues(pysz)  pdpd = qmnb[v]["lv"] .. ";" .. szpy[1].value szpd  = split(pdpd, ";") tzszpd  = szpd[1] pyszpd = szpd[2]  if tzszpd == pyszpd then  pdjg = true pdsz = true else  pdjg = false pdsz = false end end end if  pdjg == true then szpy  = sl[i].address xgxc(szpy, qmxg) end end  if xgjg == true then  gg.toast(qmnb[2]["name"] .. "开启成功,共修改" .. xgsl .. "条数据")  else  gg.toast(qmnb[2]["name"] .. "开启失败")  end  end  end  end

function setvalue(address,flags,value)  local refinevalues={}  refinevalues[1]={}  refinevalues[1].address=address  refinevalues[1].flags=flags  refinevalues[1].value=value  gg.setValues(refinevalues)  end 
so=gg.getRangesList('libgsrt.so')[1].start
setvalue(so + "0x6A250", 32, "h 00 00 B0 E3 1E FF 2F E1")
setvalue(so + "0x6C688", 4, "h 1E FF 2F E1")
setvalue(so + "0x6C68C", 32, "h 00 00 B0 E3 1E FF 2F E1")
setvalue(so + "0x6C6A8", 4, "h 1E FF 2F E1")
setvalue(so + "0x6C6B8", 4, "h 00 00 B0 E3")
setvalue(so + "0x6C6BC", 4, "h1E FF 2F E1 ")
setvalue(so + "0x6C748", 4, "h00 20 B0 E3")
setvalue(so + "0x6C7B8", 4, "h00 20 B0 E3")
setvalue(so + "0x6DF20", 4, "h00 20 B0 E3")
local AobSearch = "2F 64 61 74 61 2F 64 61 74 61"
local AobReplace = "2F 6B 61 74 61 2F 64 61 74 61"
WriteSignatures(AobSearch,AobReplace)
gg.alert("Activated")
    








