local mod = {MOD_NAME = "mod"}

function mod:BatRead()
    if rtcmem.read32(22)==1 then print(node.heap()..":"..rtctime.get().." --BatRead--") end
    i2c.start(0)
    if i2c.address(0, 0x48, i2c.RECEIVER) then
        local b = i2c.read(0, 2) -- read two bytes
        i2c.stop(0)
        cfg0.Bat = string.format("%.3f",(b:byte(1) * 256 + b:byte(2))*1.279e-4)
        return self:WiFiConnect()
    else
        cfg0.Bat = 99
        return self:WiFiConnect()
    end    
end

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
                --a,b = string.find(c,"\r\n\r\n")
                --c=string.sub(c,b)
                --print(c)
                srv:close()
                return self:Dummy()
            end)
        end    
    end)

    srv:on("connection", function(sck, c)
        print("connected")
        sck:send("GET " .. path .. " HTTP/1.1\r\nHost: " .. host .. "\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")
    end)
    
    srv:connect(443, host)
    
flashMod(mod)
