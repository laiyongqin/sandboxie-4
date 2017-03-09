local mod = {MOD_NAME = "mod"}

function mod:OtaGet()
    if rtcmem.read32(22)==1 then print(node.heap()..":"..rtctime.get().." --OtaGet--") end
    local BaseUrl="https://user="..cfg0.BbUser..":password="..cfg0.BbPw..
        "@bitbucket.org/"..cfg0.BbUser..cfg0.BbRepo.."/raw/HEAD/"
    local Failed = {}
    local i    

    local function DownLoad(FileTbl,FailTbl)
        for _,v in ipairs(FileTbl) do
            http.get(BaseUrl..FileTbl[v], nil, function(code,data)
                if (code ~= 200) then
                    table.insert(Failed,FileTbl[v])
                else
                    file.open(filename,"w")
                    file.write(data)
                    file.close()
                end
            end)    
        end
    end

    for i = 1,2 do
        DownLoad(OtaFiles,Failed)
        if #Failed==0 then 
            rtcmem.write32(27,0,0,1) --OTA OK, flash Req
            return self:FileFlash()
        else
            OtaFiles=Failed
            Failed={}
            if i==2 then
                OtaFiles,Failed=nil,nil
                rtcmem.write32(27,1,1) --OTA Fail
                print("OTA Failed")
                return self:Dummy()          
            end
        end
    end
end

function mod:FileFlash()
-- flash downloaded files
    if rtcmem.read32(22)==1 then print(node.heap()..":"..rtctime.get().." --FileFlash--") end

    for _,v in ipairs(OtaFiles) do
        print("Flash: "..OtaFiles[v])
        dofile(OtaFiles[v])        
        file.remove(OtaFiles[v])
        collectgarbage()
    end
    OtaFiles=nil
    self:SaveJson("cfg0",cfg0)
    node.restart()
end

flashMod(mod)