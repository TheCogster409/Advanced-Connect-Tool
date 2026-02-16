MPADefaultConnectTool = class()

-- useful functions and more
local function sort3(a, b, c)
    if a > b then a, b = b, a end
    if b > c then b, c = c, b end
    if a > b then a, b = b, a end
    return sm.vec3.new(a, b, c)
end

local sizeToUuid = {
    ["111"] = sm.uuid.new("50223dc8-a87f-4130-a36c-d6aa7a53649f"),
    ["112"] = sm.uuid.new("981f3c1d-5a1b-4518-abf0-247969974a6d"),
    ["113"] = sm.uuid.new("07142ffc-1ab6-410d-8b5a-065c60181cdd"),
    ["114"] = sm.uuid.new("cd30adb7-ffe0-4ca4-9ba6-8ec49ca62162"),
    ["122"] = sm.uuid.new("9ddfdb95-f73d-42e0-8f4e-7a730fc720a5"),
    ["123"] = sm.uuid.new("7579e712-96d9-41bc-a9e9-0f55c3b51c58"),
    ["124"] = sm.uuid.new("f36010e6-f68f-4f3e-824c-9d91ad22a9c4"),
    ["133"] = sm.uuid.new("a459b1d7-13bb-4b39-b873-83afb21994c8"),
    ["134"] = sm.uuid.new("0ffa00b2-a438-4c06-865e-793d53f68bc1"),
    ["144"] = sm.uuid.new("fa5ad954-86b6-42c6-8a08-4fcc940d2d97"),
    ["222"] = sm.uuid.new("2be172d5-cd5e-45e0-9bab-fa3f46b18de7"),
    ["223"] = sm.uuid.new("530db76d-620d-4527-b8e9-381f1be5d0c2"),
    ["224"] = sm.uuid.new("b710431b-db17-4176-95fc-2b011a5229bb"),
    ["233"] = sm.uuid.new("339da438-f967-4915-8a5f-12c4f6818c05"),
    ["234"] = sm.uuid.new("6379cebd-1d7d-44bf-8986-3c46afd36ad4"),
    ["244"] = sm.uuid.new("bbe63a81-7a17-41be-9cfb-c9e1b5d79629"),
    ["333"] = sm.uuid.new("6a2460f9-46e6-493e-a757-e9ddcfd5b7bb"),
    ["334"] = sm.uuid.new("f364fafd-1e04-4dbf-a611-00a98ddf02d0"),
    ["344"] = sm.uuid.new("648c6c5d-ac97-4630-ae33-56ada746e5a5"),
    ["444"] = sm.uuid.new("6922f861-7e6c-4d6f-be56-5387a3cb7406")
}

local sizeToRotation = {
    ["111"] = sm.vec3.new(0, 0, 0),
    ["112"] = sm.vec3.new(90, 0, 0),
    ["113"] = sm.vec3.new(90, 0, 0),
    ["114"] = sm.vec3.new(90, 0, 0),
    ["121"] = sm.vec3.new(0, 0, 0),
    ["122"] = sm.vec3.new(0, 0, 0),
    ["123"] = sm.vec3.new(90, 0, 0),
    ["124"] = sm.vec3.new(90, 0, 0),
    ["131"] = sm.vec3.new(0, 0, 0),
    ["132"] = sm.vec3.new(0, 0, 0),
    ["133"] = sm.vec3.new(0, 0, 0),
    ["134"] = sm.vec3.new(90, 0, 0),
    ["141"] = sm.vec3.new(0, 0, 0),
    ["142"] = sm.vec3.new(0, 0, 0),
    ["143"] = sm.vec3.new(0, 0, 0),
    ["144"] = sm.vec3.new(0, 0, 0),
    ["211"] = sm.vec3.new(0, 0, 90),
    ["212"] = sm.vec3.new(0, 0, 90),
    ["213"] = sm.vec3.new(90, 90, 0),
    ["214"] = sm.vec3.new(90, 90, 0),
    ["221"] = sm.vec3.new(0, 90, 0),
    ["222"] = sm.vec3.new(0, 0, 0),
    ["223"] = sm.vec3.new(90, 0, 0),
    ["224"] = sm.vec3.new(90, 0, 0),
    ["231"] = sm.vec3.new(0, 90, 0),
    ["232"] = sm.vec3.new(0, 0, 0),
    ["233"] = sm.vec3.new(0, 0, 0),
    ["234"] = sm.vec3.new(90, 0, 0),
    ["241"] = sm.vec3.new(0, 90, 0),
    ["242"] = sm.vec3.new(0, 0, 0),
    ["243"] = sm.vec3.new(0, 0, 0),
    ["244"] = sm.vec3.new(0, 0, 0),
    ["311"] = sm.vec3.new(0, 0, 90),
    ["312"] = sm.vec3.new(0, 0, 90),
    ["313"] = sm.vec3.new(0, 0, 90),
    ["314"] = sm.vec3.new(90, 90, 0),
    ["321"] = sm.vec3.new(90, 0, 90),
    ["322"] = sm.vec3.new(90, 0, 90),
    ["323"] = sm.vec3.new(0, 0, 90),
    ["324"] = sm.vec3.new(90, 90, 0),
    ["331"] = sm.vec3.new(0, 90, 0),
    ["332"] = sm.vec3.new(0, 90, 0),
    ["333"] = sm.vec3.new(0, 0, 0),
    ["334"] = sm.vec3.new(90, 0, 0),
    ["341"] = sm.vec3.new(0, 90, 0),
    ["342"] = sm.vec3.new(0, 90, 0),
    ["343"] = sm.vec3.new(0, 0, 0),
    ["344"] = sm.vec3.new(0, 0, 0),
    ["411"] = sm.vec3.new(0, 0, 90),
    ["412"] = sm.vec3.new(0, 0, 90),
    ["413"] = sm.vec3.new(0, 0, 90),
    ["414"] = sm.vec3.new(0, 0, 90),
    ["421"] = sm.vec3.new(90, 0, 90),
    ["422"] = sm.vec3.new(0, 0, 90),
    ["423"] = sm.vec3.new(0, 0, 90),
    ["424"] = sm.vec3.new(0, 0, 90),
    ["431"] = sm.vec3.new(90, 0, 90),
    ["432"] = sm.vec3.new(90, 0, 90),
    ["433"] = sm.vec3.new(0, 0, 90),
    ["434"] = sm.vec3.new(0, 0, 90),
    ["441"] = sm.vec3.new(0, 90, 0),
    ["442"] = sm.vec3.new(0, 90, 0),
    ["443"] = sm.vec3.new(0, 90, 0),
    ["444"] = sm.vec3.new(0, 0, 0)
}

-- Serverside Callbacks
function MPADefaultConnectTool.server_onCreate( self )
    self.checkBodyOverride = false
end

function MPADefaultConnectTool.server_onFixedUpdate( self, dt )
    local tick = sm.game.getCurrentTick()

    if sm.util.positiveModulo(tick, 8) == 0 or self.checkBodyOverride then -- get all bodies but only on every 8th tick for preformance
        local bodies = sm.body.getAllBodies()
        local changedBodies = {}
        for i, body in pairs(bodies) do -- get all bodies that have had something changed
            if body:hasChanged(tick-8) then
                changedBodies[#changedBodies+1] = body
            end
        end
        if #changedBodies ~= 0 then -- send only changed bodies OR send all upon equip
            self.network:sendToClients("client_onInteractableUpdate", changedBodies)
        elseif self.checkBodyOverride then
            self.network:sendToClients("client_onInteractableUpdate", bodies)   
        end
        self.checkBodyOverride = false
    end
end

function MPADefaultConnectTool.server_forceBodyOverride( self )
    self.checkBodyOverride = true
end

-- Clientside Callbacks

function MPADefaultConnectTool.client_onCreate( self )
    self.motorpoints = {}
    self.groupedMotorpoints = {}
    self.interactables = {}
end

function MPADefaultConnectTool.client_onUpdate( self, dt )
    for i, motorpoint in ipairs(self.motorpoints) do
        local shape = motorpoint[2]:getShape()
        local directionVector = (sm.camera.getPosition() - shape.worldPosition):normalize()
        if directionVector:length() ~= 0 then
            local direction = sm.vec3.getRotation(sm.vec3.new(0, 1, 0), directionVector)
            motorpoint[1]:setOffsetRotation(sm.quat.inverse(shape.worldRotation) * direction)
        end
    end
end

function MPADefaultConnectTool.client_onInteractableUpdate(self, bodies)
    if self.equipped then
   
        if self.motorpoints then -- make sure to clear up non existent motorpoints
            for i, motorpoint in ipairs(self.motorpoints) do
                if not sm.exists( motorpoint[1] ) then
                    self.motorpoints[i] = nil
                end
            end
        end

        print("\n\nrefresh")
        
        local groupedInteractables = {}
        local newlyMadeInteractables = {}
        local interactables = {}
        
        for i, body in ipairs(bodies) do
            if sm.exists(body) then
                groupedInteractables[body] = {}

                local bodyInteractables = body:getInteractables() -- get all interactables in the body and mark it as a new one if it was not present last time
                for k, bodyInteractable in ipairs(bodyInteractables) do
                    if self.interactables[bodyInteractable.id] == nil then
                        newlyMadeInteractables[bodyInteractable.id] = bodyInteractable
                    end
                    interactables[bodyInteractable.id] = bodyInteractable

                    if bodyInteractable.shape.shapeUuid == sm.uuid.new("9f0f56e8-2c31-4d83-996c-d00a9b296c3f") then -- if its a logic gate then mark it as a grouped one
                        groupedInteractables[body][bodyInteractable.id] = bodyInteractable
                    end
                end
            end
        end
        self.interactables = interactables
        interactables = nil
        
        -- for each  non-grouped interactable, set up its effect
        local function createNonGroupedMotorpoints(interactables, override)
            for k, interactable in pairs(interactables) do
                if (interactable.shape.shapeUuid ~= sm.uuid.new("9f0f56e8-2c31-4d83-996c-d00a9b296c3f") or override) and (interactable:getConnectionInputType() ~= sm.interactable.connectionType.none or interactable:getConnectionOutputType() ~= sm.interactable.connectionType.none) then
                    local currentMotorpoint = {sm.effect.createEffect("ShapeRenderable", interactable), interactable}
                    currentMotorpoint[1]:setParameter("uuid", sm.uuid.new("a84c4cac-d815-4261-a087-7b8a215af5dd"))
                    
                    if interactable.shape.shapeUuid ~= sm.uuid.new("9f0f56e8-2c31-4d83-996c-d00a9b296c3f") then
                        currentMotorpoint[1]:setScale( sm.vec3.new(0.00234375,0.00234375,0.00234375) ) -- default scale
                    else 
                        currentMotorpoint[1]:setScale( sm.vec3.new(0.001953125,0.001953125,0.001953125) ) -- small point scale
                    end
                    --currentMotorpoint[1]:setScale( sm.vec3.new(0.75,0.75,0.75) )
                    --currentMotorpoint[1]:setScale( sm.vec3.new(0.001171875,0.001171875,0.001171875) )
                    currentMotorpoint[1]:setParameter("color", interactable:getColorNormal())--sm.color.new("ff0000"))
                    currentMotorpoint[1]:start()
                    self.motorpoints[#self.motorpoints+1] = currentMotorpoint
                end
            end
        end
        createNonGroupedMotorpoints(newlyMadeInteractables, false)

        -- set up effects for grouped interactables
        if self.groupedMotorpoints then
            for i, motorpointGroup in ipairs(self.groupedMotorpoints) do
                if sm.exists( motorpointGroup ) then
                    motorpointGroup:destroy()
                end
            end
        end
        self.groupedMotorpoints = {}
        for body, interactables in pairs(groupedInteractables) do
            local count = 0 -- if there are less than 250 parts then just skip this proccess its not worth it
            for i, k in pairs(interactables) do
                count = count + 1
            end

            if count > 150 then -- greedy meshing
                local minSize, maxSize = body:getLocalAabb()

                local interactableGrid = {} -- Set up each interactable in a grid for fast greedy meshing
                for i, interactable in pairs(interactables) do
                    local position = interactable:getShape().localPosition
                    local posString = tostring(position.x)..","..tostring(position.y)..","..tostring(position.z) -- use a string as lua compares the value directly instead of using pointers
                    interactableGrid[posString] = interactable
                end

                 --loop through every position in the body
                for x = minSize.x, maxSize.x, 1 do
                    for y = minSize.y, maxSize.y, 1 do
                        for z = minSize.z, maxSize.z, 1 do
                            local modifiedPosition = sm.vec3.new(x,y,z)
                            local posString = tostring(modifiedPosition.x)..","..tostring(modifiedPosition.y)..","..tostring(modifiedPosition.z)
                            -- then loop for each axis to get the maximum size
                            if interactableGrid[posString] ~= nil then

                                -- find largest possible width/x
                                local width = 1
                                while true do
                                    local testX = x + width
                                    if testX > maxSize.x then break end
                                    local testKey = tostring(testX)..","..tostring(y)..","..tostring(z)
                                    if interactableGrid[testKey] and width < 4 then -- make sure to max out at 4
                                        width = width + 1
                                    else
                                        break
                                    end
                                end

                                -- find largest possible length/y
                                local length = 1
                                while true do
                                    local testY = y + length
                                    if testY > maxSize.y then break end
                                    local entireRowExists = true
                                    for columnOffset = 0, width - 1, 1 do
                                        local checkX = x + columnOffset
                                        local checkKey = tostring(checkX)..","..tostring(testY)..","..tostring(z)
                                        if not interactableGrid[checkKey] then
                                            entireRowExists = false
                                            break
                                        end
                                    end
                                    if entireRowExists and length < 4 then -- make sure to max out at 4
                                        length = length + 1
                                    else
                                        break
                                    end
                                end

                                -- find largest possible depth/z
                                local depth = 1
                                while true do
                                    local testZ = z + depth
                                    if testZ > maxSize.z then break end
                                
                                    local entireLayerExists = true
                                    for rowOffset = 0, length - 1 do
                                        for columnOffset = 0, width - 1 do
                                            local checkX = x + columnOffset
                                            local checkY = y + rowOffset
                                            local checkKey = tostring(checkX)..","..tostring(checkY)..","..tostring(testZ)
                                            if not interactableGrid[checkKey] then
                                                entireLayerExists = false
                                                break
                                            end
                                        end
                                        if not entireLayerExists then break end
                                    end
                                
                                    if entireLayerExists and depth < 4 then
                                        depth = depth + 1
                                    else
                                        break
                                    end
                                end

                                local shape = interactableGrid[posString]:getShape()

                                local size = tostring(width)..tostring(length)..tostring(depth)
                                local rotatedSize = sort3(width, length, depth)
                                local rotatedSizeString = tostring(rotatedSize.x)..tostring(rotatedSize.y)..tostring(rotatedSize.z)
                                local positionOffset = sm.vec3.new(width-1,length-1,depth-1)*0.125

                                local currentMotorpoint = sm.effect.createEffect("ShapeRenderable", interactableGrid[posString])
                                currentMotorpoint:setParameter("uuid", sizeToUuid[rotatedSizeString])--sm.uuid.new("50223dc8-a87f-4130-a36c-d6aa7a53649f"))
                                currentMotorpoint:setParameter("color", sm.color.new("#1e68bb"))--sm.color.new( math.random(), math.random(), math.random(), 1 ))
                                currentMotorpoint:setOffsetRotation(sm.quat.inverse(shape.localRotation) * sm.quat.fromEuler(sizeToRotation[size]))
                                currentMotorpoint:setOffsetPosition(sm.quat.inverse(shape.localRotation) * positionOffset)
                                currentMotorpoint:setAutoPlay(true)
                                currentMotorpoint:start()
                                self.groupedMotorpoints[#self.groupedMotorpoints+1] = currentMotorpoint

                                if shape.color == sm.color.new("eeeeee") then -- debug information
                                    sm.gui.displayAlertText( size, 1.5 )    
                                    print(size)
                                    print(sizeToRotation[size])
                                end

                                for rowOffset = 0, length - 1 do
                                    for columnOffset = 0, width - 1 do
                                        for layerOffset = 0, depth - 1 do
                                            local removeX = x + columnOffset
                                            local removeY = y + rowOffset
                                            local removeZ = z + layerOffset
                                            local removeKey = tostring(removeX)..","..tostring(removeY)..","..tostring(removeZ)
                                            interactableGrid[removeKey] = nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else -- individual motorpoints
                createNonGroupedMotorpoints(interactables, true)
            end
        end
    end
end

function MPADefaultConnectTool.client_onEquip( self, animate )
    self.equipped = true
    self.interactables = {}
    self.network:sendToServer("server_forceBodyOverride")
end

function MPADefaultConnectTool.client_onUnequip( self, animate )
    self.equipped = false
    self.interactables = {}
    if self.motorpoints then
        for i, motorpoint in ipairs(self.motorpoints) do
            if sm.exists( motorpoint[1] ) then
                motorpoint[1]:destroy()
            end
        end
    end
    if self.groupedMotorpoints then
        for i, motorpointGroup in ipairs(self.groupedMotorpoints) do
            if sm.exists( motorpointGroup ) then
                motorpointGroup:destroy()
            end
        end
    end
    self.motorpoints = {}
end

function MPADefaultConnectTool.client_onEquippedUpdate( self, primaryState, secondaryState, forceBuild )

    return false, false
end