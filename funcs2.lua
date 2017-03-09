local mod = {MOD_NAME = "mod"}

function mod:i2cInit()
-- i2c bus setup
    if rtcmem.read32(22)==1 then print(node.heap()..":"..rtctime.get().." --i2cInit--") end
    i2c.setup(0,4,3,i2c.SLOW)
    tmr.delay(500)
    return self:BatRead()
end

function mod:BatRead()
-- 0x90 For ED0 slave address (0x48 without low bit)    
-- Config register:
--   7   6 5 4   3   2   1    0
-- STart 0 0 SC DR1 DR0 PGA1 PGA0
-- 0x8C by default (Data Rate 15 SPS, continuous conversion, Gain=1)
-- SC = 1 - single conversion; 0 - continuous conversion.

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

            --mydata = c

            tmr.create():alarm(5000 , tmr.ALARM_SINGLE, function ()
                --a,b = string.find(c,"\r\n\r\n")
                --c=string.sub(c,b)
                --print(c)
                srv:close()
                return self:Dummy()
            end)

            --print(c)
            --mydata=c
            --print(c)
            --c=nil
            --srv:close()
            --srv=nil
            --collectgarbage()
            --return self:Dummy()
        end    
    end)

    srv:on("connection", function(sck, c)
        print("connected")
        sck:send("GET " .. path .. " HTTP/1.1\r\nHost: " .. host .. "\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")
    end)
    
    srv:connect(443, host)
        
    


end


-- function mod:OtaChk()
-- -- OTA download updates.lua, execute, {updates} contain files to download
--     if rtcmem.read32(22)==1 then print(node.heap()..":"..rtctime.get().." --OtaChk--") end
 
--     -- local BaseUrl="http://user="..cfg0.BbUser..":password="..cfg0.BbPw..
--     --     ips..":80/"..cfg0.BbUser.."/"..cfg0.BbRepo.."/raw/HEAD/otafiles.lua"
    
--     --print(BaseUrl)

--     --local BaseUrl = "https://raw.githubusercontent.com/matgoebl/nodemcu-wifimusicledclock/master/compile.lua"  
--     local BaseUrl = "matgoebl/nodemcu-wifimusicledclock/master/compile.lua" 

--     sk = net.createConnection(net.TCP, 0)
--     sk:on("receive", function(sck, c) print(c) end )
--     sk:on("connection", function(sck,c)
--         -- Wait for connection before sending.
--         sck:send("GET / HTTP/1.1\r\nHost: BaseUrl\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")
--     end)
--     sk:connect(80,"raw.githubusercontent.com")


--     -- if rtcmem.read32(26)==1 then
--     --     http.get(BaseUrl, "", function(code,data)
--     --         print("data: "..data)
--     --         print("code: "..code)
--     --         if (code ~= 200) then
--     --             print("http error:",code)
--     --         else
--     --             print("body size:",#data)
--     --             pcall(loadstring(data))
--     --             if #OtaFiles==0 then
--     --                 OtaFiles=nil
--     --                 return self:Dummy() --no OTA required
--     --             else
--     --                 return self:OtaGet() --get files
--     --             end    
--     --         end
--     --     end)
--     -- else
--     --     return self:Dummy() --WiFi no connected, no update possible
--     -- end            
--end

flashMod(mod)