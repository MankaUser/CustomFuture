repeat task.wait() until game:IsLoaded()
local Future = shared.Future
local GuiLibrary = Future.GuiLibrary
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WORKSPACE = game:GetService("Workspace")
local PLAYERS = game:GetService("Players")
local HTTPSERVICE = game:GetService("HttpService")
local COLLECTION = game:GetService("CollectionService")
local lplr = PLAYERS.LocalPlayer
local mouse = lplr:GetMouse()
local cam = WORKSPACE.CurrentCamera
local getcustomasset = --[[getsynasset or getcustomasset or]] GuiLibrary.getRobloxAsset
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local setthreadidentityfunc = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity
local getthreadidentityfunc = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity
local spawn = function(func) 
    return coroutine.wrap(func)()
end
local betterisfile = function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local bedwars = {} 
local Reach = {Enabled = false}
local ViewModel = {Enabled = false} 
local oldisnetworkowner = isnetworkowner
local isnetworkowner = isnetworkowner or function(part) 
    return gethiddenproperty(part, "NetworkOwnershipRule") == Enum.NetworkOwnership.Automatic
end
local printtable = printtable or print
local whitelisted = {}
local storedshahashes = {}
pcall(function()
	whitelisted = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/whitelists/main/whitelist2.json", true))
end)
local antivoidpart
local function requesturl(url, bypass) 
    if betterisfile(url) and shared.FutureDeveloper then 
        return readfile(url)
    end
    local repourl = bypass and "https://raw.githubusercontent.com/MankaUser/" or "https://raw.githubusercontent.com/MankaUser/CustomFuture/main/"
    local url = url:gsub("CustomFuture/", "")
    local req = requestfunc({
        Url = repourl..url,
        Method = "GET"
    })
    if req.StatusCode == 404 then error("404 Not Found") end
    return req.Body
end 
local shalib = loadstring(requesturl("lib/sha.lua"))()
local savedc0 = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Viewmodel"):WaitForChild("RightHand"):WaitForChild("RightWrist").C0
local setc0

local FakeRoot, RealRoot -- fake is client sided
local AnticheatAssist = {}
local AnticheatAssistConstants = {
    MaxDistance = 20,
    -- normal
    Delay = 0.125,
    Lerp = 0.39,
    TPDelay = 0.1,
    -- combat
    CombatDelay = 0.1,
    CombatLerp = 0.5,
    CombatTPDelay = 0,
}

local function getasset(path)
	if not betterisfile(path) then
		local req = requestfunc({
			Url = "https://raw.githubusercontent.com/MankaUser/CustomFuture/main/"..path:gsub("CustomFuture/assets", "assets"),
			Method = "GET"
		})
        print("[Future] downloading "..path.." asset.")
		writefile(path, req.Body)
        repeat task.wait() until betterisfile(path)
        print("[Future] downloaded "..path.." asset successfully!")
	end
	return getcustomasset(path) 
end

local HeartbeatTable = {}
local RenderStepTable = {}
local SteppedTable = {}
local function isAlive(plr)
    local plr = plr or lplr
    if plr and plr.Character and ((plr.Character:FindFirstChild("Humanoid")) and (plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) and (plr.Character:FindFirstChild("HumanoidRootPart")) and (plr.Character:FindFirstChild("Head"))) then
        return true
    end
end

local function BindToHeartbeat(name, func)
    if HeartbeatTable[name] == nil then
        HeartbeatTable[name] = game:GetService("RunService").Heartbeat:connect(func)
    end
end
local function UnbindFromHeartbeat(name)
    if HeartbeatTable[name] then
        HeartbeatTable[name]:Disconnect()
        HeartbeatTable[name] = nil
    end
end
local function BindToRenderStep(name, func)
	if RenderStepTable[name] == nil then
		RenderStepTable[name] = game:GetService("RunService").RenderStepped:connect(func)
	end
end
local function UnbindFromRenderStep(name)
	if RenderStepTable[name] then
		RenderStepTable[name]:Disconnect()
		RenderStepTable[name] = nil
	end
end
local function BindToStepped(name, func)
	if SteppedTable[name] == nil then
		SteppedTable[name] = game:GetService("RunService").Stepped:connect(func)
	end
end
local function UnbindFromStepped(name)
	if SteppedTable[name] then
		SteppedTable[name]:Disconnect()
		SteppedTable[name] = nil
	end
end

local function skipFrame() 
    return game:GetService("RunService").Heartbeat:Wait()
end
 
local function ferror(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    GuiLibrary.CreateNotification("<font color='rgb(255, 10, 10)'>[ERROR]"..str.."</font>")
    error("[Future]"..str)
end

local function fwarn(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    warn("[Future]"..str)
    GuiLibrary.CreateNotification("<font color='rgb(255, 255, 10)'>[WARNING] "..str.."</font>")
end

local function fprint(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    print("[Future]"..str)
    GuiLibrary.CreateNotification("<font color='rgb(200, 200, 200)'>"..str.."</font>")
end

local function betterfind(tab, obj)
    for i,v in next, (tab) do
        if v == obj or type(v) == "table" and v.hash == obj then
            return v
        end
    end
    return nil
end

local function getconnectionproto(func, level, con) 
    local proto = debug.getproto(func, level)
    local info = debug.getinfo(proto)
    
    local old = getthreadidentityfunc and getthreadidentityfunc() or 8
    setthreadidentityfunc(2)
    for i,v in next, getconnections(con) do 
        local coninfo = debug.getinfo(v.Function)
        if v.Function and coninfo.src == info.src and coninfo.numparams == info.numparams and coninfo.currentline == info.currentline then 
            return v.Function
        end
    end
    setthreadidentityfunc(old)
end


local function getColorFromPlayer(v) 
    if v.Team ~= nil then return v.TeamColor.Color end
end

local function getremote(t)
    for i,v in next, t do 
        if v == "Client" then 
            return t[i+1]
        end
    end
end

local function getPlrNear(max)
    local returning, nearestnum = nil,max
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local diff = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if diff < nearestnum then 
                nearestnum = diff 
                returning = v
            end
        end
    end
    return returning
end

local function getLowestHpPlrNear(max) 
    local returning, lowestnum = nil, 9999999999
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local diff = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            local health = v.Character:GetAttribute("Health")
            if diff < max and health < lowestnum then 
                lowestnum = health 
                returning = v
            end
        end
    end
    return returning
end

local function getPlrNearMouse(max)
    local max = max or 99999999999999
    local nearestval, nearestnum = nil,max
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local pos, vis = WORKSPACE.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            if vis and pos then 
                local diff = (UIS:GetMouseLocation() - Vector2.new(pos.X, pos.Y)).Magnitude
                if diff < nearestnum then 
                    nearestnum = diff 
                    nearestval = v
                end
            end
        end
    end
    return nearestval
end

local function getAllPlrsNear(max)
    if not isAlive() then return {} end
    local t = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            if v.Character.HumanoidRootPart and (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude <= max then 
                table.insert(t, v)
            end
        end
    end
    return t
end

local function canBeTargeted(plr, doTeamCheck) 
    return Future.canBeTargeted(plr)
end

local function getMoveDirection(plr) 
    if not isAlive(plr) then return Vector3.new() end
    local velocity = plr.Character.HumanoidRootPart:GetVelocityAtPosition(plr.Character.HumanoidRootPart.Position)
    local velocityDirection = velocity.Magnitude > 0 and velocity.Unit or Vector3.new()
    return velocityDirection
end



local function hashvector(vec)
	return {
		value = vec
	}
end


GuiLibrary.RemoveObject("HighJumpOptionsButton")
do
    local Duration,Power = {Value = 50},{Value = 5}
    local HighJump = {}; HighJump = GuiLibrary.Objects.MovementWindow.API.CreateOptionsButton({
        Name = "HighJump",
        Function = function(callback) 
            if callback then 
                spawn(function() 
                    if isAlive() then
                        for i = 1, Duration.Value do 
                            lplr.Character.HumanoidRootPart.Velocity = lplr.Character.HumanoidRootPart.Velocity + Vector3.new(0, Power.Value, 0)
                            if not HighJump.Enabled then
                                break
                            end
                            task.wait()
                        end
                        if HighJump.Enabled then 
                            HighJump.Toggle()
                        end
                    end
                end)
            end
        end,
    })
    Duration = HighJump.CreateSlider({
        Name = "Duration",
        Function = function() end,
        Min = 1,
        Max = 500,
        Round = 1,
        Default = 50,
    })
    Power = HighJump.CreateSlider({
        Name = "Power",
        Function = function() end,
        Min = 1,
        Max = 6,
        Default = 5
    })
end

local stopSpeed = false
GuiLibrary["RemoveObject"]("LongJumpOptionsButton")
do 
    local doRay = false
    local speedval, timeval,distance, delayval = {["Value"] = 0},{["Value"] = 0},{["Value"] = 0}, {["Value"] = 0}
    local LongJump = {["Enabled"] = false}; LongJump = GuiLibrary.Objects.MovementWindow.API.CreateOptionsButton({
        ["Name"] = "LongJump",
        ["Function"] = function(callback) 
            if callback then
                if isAlive() then 
                    lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)
                else
                    LongJump.Toggle()
                    return
                end
                task.delay(timeval["Value"], function() 
                    if LongJump.Enabled then
                        LongJump.Toggle()
                    end
                end)
                spawn(function()
                    repeat 
                        local dt = skipFrame()
                        if isAlive() then
                            stopSpeed = true
                            if doRay then
                                local params = RaycastParams.new()
                                params.FilterDescendantsInstances = {game:GetService("CollectionService"):GetTagged("block")}
                                params.FilterType = Enum.RaycastFilterType.Whitelist
                                local ray = WORKSPACE:Raycast(lplr.Character.HumanoidRootPart.Position, Vector3.new(0, -10, 0), params)
                                if ray and ray.Instance then 
                                    if LongJump.Enabled then
                                        LongJump.Toggle()
                                        stopSpeed = false
                                    end
                                    break
                                end
                            end

                            local moveDir = lplr.Character.Humanoid.MoveDirection ~= Vector3.zero and lplr.Character.Humanoid.MoveDirection or lplr.Character.HumanoidRootPart.CFrame.lookVector
                            local velo = moveDir * (speedval["Value"] - lplr.Character.Humanoid.WalkSpeed) * dt
                            velo = Vector3.new(velo.x, 0, velo.z)
                            lplr.Character:TranslateBy(velo)
                            --local velo2 = (movedir * speedval["Value"]) / speedsettings.velocitydivfactor
                            lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 1, 0)
                        end
                    until not LongJump.Enabled
                    stopSpeed = false
                end)
                spawn(function() 
                    local num = delayval.Value

                    for i = 1, math.round(timeval["Value"]) * num do 
                        task.wait(1/num) 
                        if not LongJump.Enabled then break end
                        if isAlive() then 
                            local newCframe = lplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -distance.Value)
                            local params = RaycastParams.new()
                            params.FilterDescendantsInstances = {game:GetService("CollectionService"):GetTagged("block")}
                            params.FilterType = Enum.RaycastFilterType.Whitelist
                            local ray = WORKSPACE:Raycast(lplr.Character.HumanoidRootPart.Position, CFrame.new(0, 0, -distance.Value).p, params)
                            if not (ray and ray.Instance) then
                                lplr.Character.HumanoidRootPart.CFrame = newCframe
                            else
                                lplr.Character.HumanoidRootPart.CFrame = CFrame.new(ray.Position)
                            end
                        end
                        if i-1 >= timeval["Value"] then doRay = true end
                    end
                end)
            else
                doRay = false
                stopSpeed = false
            end
        end,
    })
    speedval = LongJump.CreateSlider({
        ["Name"] = "Speed",
        ["Default"] = 42, 
        ["Min"] = 10,
        ["Round"] = 0,
        ["Max"] = 42,
        ["Function"] = function(value) end,
    })
    timeval = LongJump.CreateSlider({
        ["Name"] = "Duration",
        ["Default"] = 2, 
        ["Min"] = 1,
        ["Round"] = 1,
        ["Max"] = 3,
        ["Function"] = function(value) end,
    })
    distance = LongJump.CreateSlider({
        Name = "BypassDist",
        Default = 6,
        Min = 4,
        Round = 1,
        Max = 7,
        Function = function() end
    })
    delayval = LongJump.CreateSlider({
        Name = "BypassSpeed",
        Default = 4,
        Min = 1,
        Max = 10,
        Round = 0,
        Function = function() end, 
    })
end
