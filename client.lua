local RSGCore = exports['rsg-core']:GetCoreObject()

local doorCoords   = vector3(2858.8628, -1194.9165, 47.9914)
local doorModel    = GetHashKey("s_clothingcasedoor01x")
local doorYawFrom  = 94.9999
local doorYawTo    = -174.6001
local isDoorOpen   = false

local trap1Coords    = vector3(1326.0381, -1326.3833, 76.9224)
local trap1Model     = GetHashKey("p_gunsmithtrapdoor01x")
local trap1PitchFrom = 0.0
local trap1PitchTo   = -89.8991
local trap1Yaw       = 165.0
local isTrap1Open    = false

local trap2Coords    = vector3(-1790.7443, -390.1504, 159.2894)
local trap2Model     = GetHashKey("p_trapdoor01x")
local trap2PitchFrom = 0.0
local trap2PitchTo   = -90.0
local trap2Yaw       = 145.0879
local isTrap2Open    = false

local trap3Coords    = vector3(1259.8738, -406.4928, 96.6224)
local trap3Model     = GetHashKey("p_gunsmithtrapdoor01x")
local trap3PitchFrom = 0.0
local trap3PitchTo   = -90.0
local trap3Yaw       = 5.0
local isTrap3Open    = false

local doorGroup   = GetRandomIntInRange(0, 0xffffff)
local trap1Group  = GetRandomIntInRange(0, 0xffffff)
local trap2Group  = GetRandomIntInRange(0, 0xffffff)
local trap3Group  = GetRandomIntInRange(0, 0xffffff)

local doorPrompt, trap1Prompt, trap2Prompt, trap3Prompt

local function CreateAllPrompts()
    doorPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(doorPrompt, 0x760A9C6F)
    PromptSetText(doorPrompt, CreateVarString(10, 'LITERAL_STRING', 'Open/Close Door'))
    PromptSetEnabled(doorPrompt, true)
    PromptSetVisible(doorPrompt, true)
    PromptSetHoldMode(doorPrompt, true)
    PromptSetGroup(doorPrompt, doorGroup)
    PromptRegisterEnd(doorPrompt)

    trap1Prompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(trap1Prompt, 0x760A9C6F)
    PromptSetText(trap1Prompt, CreateVarString(10, 'LITERAL_STRING', 'Open/Close Trapdoor'))
    PromptSetEnabled(trap1Prompt, true)
    PromptSetVisible(trap1Prompt, true)
    PromptSetHoldMode(trap1Prompt, true)
    PromptSetGroup(trap1Prompt, trap1Group)
    PromptRegisterEnd(trap1Prompt)

    trap2Prompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(trap2Prompt, 0x760A9C6F)
    PromptSetText(trap2Prompt, CreateVarString(10, 'LITERAL_STRING', 'Open/Close Trapdoor'))
    PromptSetEnabled(trap2Prompt, true)
    PromptSetVisible(trap2Prompt, true)
    PromptSetHoldMode(trap2Prompt, true)
    PromptSetGroup(trap2Prompt, trap2Group)
    PromptRegisterEnd(trap2Prompt)

    trap3Prompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(trap3Prompt, 0x760A9C6F)
    PromptSetText(trap3Prompt, CreateVarString(10, 'LITERAL_STRING', 'Open/Close Trapdoor'))
    PromptSetEnabled(trap3Prompt, true)
    PromptSetVisible(trap3Prompt, true)
    PromptSetHoldMode(trap3Prompt, true)
    PromptSetGroup(trap3Prompt, trap3Group)
    PromptRegisterEnd(trap3Prompt)
end

Citizen.CreateThread(function()
    CreateAllPrompts()

    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if #(pos - doorCoords) < 2.5 then
            sleep = 0
            PromptSetActiveGroupThisFrame(doorGroup, CreateVarString(10, 'LITERAL_STRING', 'Open/Close Door'))
            if PromptHasHoldModeCompleted(doorPrompt) then
                TriggerServerEvent("rsg_door:server:rotateDoor")
                Wait(2000)
            end
        end

        if #(pos - trap1Coords) < 2.5 then
            sleep = 0
            PromptSetActiveGroupThisFrame(trap1Group, CreateVarString(10, 'LITERAL_STRING', 'Open/Close Trapdoor'))
            if PromptHasHoldModeCompleted(trap1Prompt) then
                TriggerServerEvent("rsg_door:server:rotateTrapdoor")
                Wait(2000)
            end
        end

        if #(pos - trap2Coords) < 2.5 then
            sleep = 0
            PromptSetActiveGroupThisFrame(trap2Group, CreateVarString(10, 'LITERAL_STRING', 'Open/Close Trapdoor'))
            if PromptHasHoldModeCompleted(trap2Prompt) then
                TriggerServerEvent("rsg_door:server:rotateTrapdoor2")
                Wait(2000)
            end
        end

        if #(pos - trap3Coords) < 2.5 then
            sleep = 0
            PromptSetActiveGroupThisFrame(trap3Group, CreateVarString(10, 'LITERAL_STRING', 'Open/Close Trapdoor'))
            if PromptHasHoldModeCompleted(trap3Prompt) then
                TriggerServerEvent("rsg_door:server:rotateTrapdoor3")
                Wait(2000)
            end
        end

        Wait(sleep)
    end
end)

-- Smooth rotate function
local function smoothRotate(entity, fromAngle, toAngle, setter)
    local delta = toAngle - fromAngle
    if delta > 180.0 then delta = delta - 360.0 end
    if delta < -180.0 then delta = delta + 360.0 end
    local duration = 2000
    local t0 = GetGameTimer()
    Citizen.CreateThread(function()
        while true do
            local elapsed = GetGameTimer() - t0
            local t = math.min(elapsed / duration, 1.0)
            local angle = fromAngle + delta * t
            setter(entity, angle)
            if t >= 1.0 then break end
            Wait(0)
        end
    end)
end

-- Rotate functions
local function RotateDoor()
    local ent = GetClosestObjectOfType(doorCoords.x, doorCoords.y, doorCoords.z, 1.0, doorModel, false, false, false)
    if ent == 0 then return end
    local from, to = doorYawFrom, doorYawTo
    if isDoorOpen then from, to = doorYawTo, doorYawFrom end
    smoothRotate(ent, from, to, function(e, a) SetEntityHeading(e, a) end)
    isDoorOpen = not isDoorOpen
end

local function RotateTrap1()
    local ent = GetClosestObjectOfType(trap1Coords.x, trap1Coords.y, trap1Coords.z, 1.0, trap1Model, false, false, false)
    if ent == 0 then return end
    local from, to = trap1PitchFrom, trap1PitchTo
    if isTrap1Open then from, to = trap1PitchTo, trap1PitchFrom end
    smoothRotate(ent, from, to, function(e, a) SetEntityRotation(e, a, 0.0, trap1Yaw, 2, true) end)
    isTrap1Open = not isTrap1Open
end

local function RotateTrap2()
    local ent = GetClosestObjectOfType(trap2Coords.x, trap2Coords.y, trap2Coords.z, 1.0, trap2Model, false, false, false)
    if ent == 0 then return end
    local from, to = trap2PitchFrom, trap2PitchTo
    if isTrap2Open then from, to = trap2PitchTo, trap2PitchFrom end
    smoothRotate(ent, from, to, function(e, a) SetEntityRotation(e, a, 0.0, trap2Yaw, 2, true) end)
    isTrap2Open = not isTrap2Open
end

local function RotateTrap3()
    local ent = GetClosestObjectOfType(trap3Coords.x, trap3Coords.y, trap3Coords.z, 1.0, trap3Model, false, false, false)
    if ent == 0 then return end
    local from, to = trap3PitchFrom, trap3PitchTo
    if isTrap3Open then from, to = trap3PitchTo, trap3PitchFrom end
    smoothRotate(ent, from, to, function(e, a) SetEntityRotation(e, a, 0.0, trap3Yaw, 2, true) end)
    isTrap3Open = not isTrap3Open
end

-- Events
RegisterNetEvent("rsg_door:client:rotateDoor", RotateDoor)
RegisterNetEvent("rsg_door:client:rotateTrapdoor", RotateTrap1)
RegisterNetEvent("rsg_door:client:rotateTrapdoor2", RotateTrap2)
RegisterNetEvent("rsg_door:client:rotateTrapdoor3", RotateTrap3)
