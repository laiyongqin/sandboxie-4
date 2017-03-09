local mod = {MOD_NAME = "mod"}

function mod:OtaChk()
    if rtcmem.read32(22)==1 then print(node.heap()..":"..rtctime.get().." --OtaChk--") end
    
    local flag=true
    local host = "raw.githubusercontent.com"
    local path = "/NicolSpies/sandboxie/master/funcs1.lua"
    local srv = tls.createConnection(net.TCP, 0)
    srv:on("receive", function(sck, c) 
        if flag then 
            local a,b,k,m
            --flag=false
            k=c
            print(#k)
            a,b = string.find(k,"\r\n\r\n")
            print(a,b)
            m=string.sub(c,b)
            print(m)
            file.open("test.txt","w+")
            file.write(m) 
            file.close()
            tmr.create():alarm(5000 , tmr.ALARM_SINGLE, function ()
                srv:close()
                return self:Dummy()
            end)
        end    
    end)
    
flashMod(mod)
