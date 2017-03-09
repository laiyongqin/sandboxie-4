local mod = {MOD_NAME = "mod"}

function mod:VarInit()
-- init variables in RTC Memory
-- 21=Version(false),22=HeapMem(true), 23=Idle(true),24=MqttFail(false)
-- 25=Operational Mode(3), 26=WiFi Connected(false), 27=OTA Req, 28=OTA Fail
-- 29=Flash Req, 30=ntp
    print(node.heap()..":"..rtctime.get().." --VarInit--")
    rtcmem.write32(21,0,1,1,0,3,1,0,0,0,0) 
    cfg0 = self:LoadJson("cfg0") 	--global variables in cfg0:float,string,max 250 bytes
    print(node.heap()..":"..rtctime.get().." --VarInit End--")
    return self:i2cInit()
end

flashMod(mod)