MPADefaultConnectTool = class()

-- Serverside Callbacks
function MPADefaultConnectTool.server_onCreate( self )
    self.checkBodyOverride = false
end

function MPADefaultConnectTool.server_onFixedUpdate( self, dt )
    local tick = sm.game.getCurrentTick()

    if sm.util.positiveModulo(tick, 8) == 0 or self.checkBodyOverride or tick == 0 then -- get all bodies but only on every 8th tick for preformance
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
        local startTime = os.clock()
        -- cache functions
        local createEffect = sm.effect.createEffect
        local quatFromEuler = sm.quat.fromEuler
        local quatInverse = sm.quat.inverse
        local vec3New = sm.vec3.new
        local uuidNew = sm.uuid.new
   
        if self.motorpoints then -- make sure to clear up non existent motorpoints
            for i, motorpoint in ipairs(self.motorpoints) do
                if not sm.exists( motorpoint[1] ) then
                    self.motorpoints[i] = nil
                end
            end
        end

        print("\n\nrefresh")

        local uuidsToGroup = {
            ["9f0f56e8-2c31-4d83-996c-d00a9b296c3f"] = sm.color.new("#1e68bb"), -- Vanilla Logic Gate
            ["6a9dbff5-7562-4e9a-99ae-3590ece88112"] = sm.color.new("#7514edff") -- mt fast logic gate
        }
        
        local groupedInteractables = {}
        local newlyMadeInteractables = {}
        local interactables = {}
        
        local ipairs = ipairs
        local pairs = pairs
        for i, body in ipairs(bodies) do
            if sm.exists(body) then
                groupedInteractables[body.id] = {["body"] = body, ["uuids"] = {}}
                local uuids = groupedInteractables[body.id].uuids

                local bodyInteractables = body:getInteractables()
                for i, bodyInteractable in ipairs(bodyInteractables) do
                    local uuidMatch = false
                    for uuid, color in pairs(uuidsToGroup) do
                        if tostring(bodyInteractable.shape.shapeUuid) == uuid then
                            uuids[uuid] = uuids[uuid] or {}
                            uuids[uuid][bodyInteractable.id] = bodyInteractable
                            uuidMatch = true
                            break
                        end
                    end
                
                    if not uuidMatch then
                        if self.interactables[bodyInteractable.id] == nil then
                            newlyMadeInteractables[bodyInteractable.id] = bodyInteractable
                        end
                        interactables[bodyInteractable.id] = bodyInteractable
                    end
                end
            end
        end
        self.interactables = interactables
        interactables = nil
        
        -- for each  non-grouped interactable, set up its effect
        local function createNonGroupedMotorpoints(interactables)
            for k, interactable in pairs(interactables) do
                if interactable:getConnectionInputType() ~= sm.interactable.connectionType.none or interactable:getConnectionOutputType() ~= sm.interactable.connectionType.none then
                    local currentMotorpoint = {createEffect("ShapeRenderable", interactable), interactable}
                    currentMotorpoint[1]:setParameter("uuid", uuidNew("a84c4cac-d815-4261-a087-7b8a215af5dd"))
                    
                    if interactable.shape.shapeUuid ~= uuidNew("9f0f56e8-2c31-4d83-996c-d00a9b296c3f") then
                        currentMotorpoint[1]:setScale( vec3New(0.00234375,0.00234375,0.00234375) ) -- default scale
                    else 
                        currentMotorpoint[1]:setScale( vec3New(0.001953125,0.001953125,0.001953125) ) -- small point scale
                    end
                    currentMotorpoint[1]:setParameter("color", interactable:getColorNormal())--sm.color.new("ff0000"))
                    currentMotorpoint[1]:start()
                    self.motorpoints[#self.motorpoints+1] = currentMotorpoint
                end
            end
        end
        createNonGroupedMotorpoints(newlyMadeInteractables)

        -- set up effects for grouped interactables, aka greedy meshing

        -- useful stuff
        local function sort3(a, b, c)
            if a > b then a, b = b, a end
            if b > c then b, c = c, b end
            if a > b then a, b = b, a end
            return a, b, c
        end

        local sizeToUuid = {
            [111] = uuidNew("50223dc8-a87f-4130-a36c-d6aa7a53649f"),
            [112] = uuidNew("981f3c1d-5a1b-4518-abf0-247969974a6d"),
            [113] = uuidNew("07142ffc-1ab6-410d-8b5a-065c60181cdd"),
            [114] = uuidNew("cd30adb7-ffe0-4ca4-9ba6-8ec49ca62162"),
            [122] = uuidNew("9ddfdb95-f73d-42e0-8f4e-7a730fc720a5"),
            [123] = uuidNew("7579e712-96d9-41bc-a9e9-0f55c3b51c58"),
            [124] = uuidNew("f36010e6-f68f-4f3e-824c-9d91ad22a9c4"),
            [133] = uuidNew("a459b1d7-13bb-4b39-b873-83afb21994c8"),
            [134] = uuidNew("0ffa00b2-a438-4c06-865e-793d53f68bc1"),
            [144] = uuidNew("fa5ad954-86b6-42c6-8a08-4fcc940d2d97"),
            [222] = uuidNew("2be172d5-cd5e-45e0-9bab-fa3f46b18de7"),
            [223] = uuidNew("530db76d-620d-4527-b8e9-381f1be5d0c2"),
            [224] = uuidNew("b710431b-db17-4176-95fc-2b011a5229bb"),
            [233] = uuidNew("339da438-f967-4915-8a5f-12c4f6818c05"),
            [234] = uuidNew("6379cebd-1d7d-44bf-8986-3c46afd36ad4"),
            [244] = uuidNew("bbe63a81-7a17-41be-9cfb-c9e1b5d79629"),
            [333] = uuidNew("6a2460f9-46e6-493e-a757-e9ddcfd5b7bb"),
            [334] = uuidNew("f364fafd-1e04-4dbf-a611-00a98ddf02d0"),
            [344] = uuidNew("648c6c5d-ac97-4630-ae33-56ada746e5a5"),
            [444] = uuidNew("6922f861-7e6c-4d6f-be56-5387a3cb7406")
        }
        
        local sizeToRotation = {
            [111] = vec3New(0, 0, 0),
            [112] = vec3New(90, 0, 0),
            [113] = vec3New(90, 0, 0),
            [114] = vec3New(90, 0, 0),
            [121] = vec3New(0, 0, 0),
            [122] = vec3New(0, 0, 0),
            [123] = vec3New(90, 0, 0),
            [124] = vec3New(90, 0, 0),
            [131] = vec3New(0, 0, 0),
            [132] = vec3New(0, 0, 0),
            [133] = vec3New(0, 0, 0),
            [134] = vec3New(90, 0, 0),
            [141] = vec3New(0, 0, 0),
            [142] = vec3New(0, 0, 0),
            [143] = vec3New(0, 0, 0),
            [144] = vec3New(0, 0, 0),
            [211] = vec3New(0, 0, 90),
            [212] = vec3New(0, 0, 90),
            [213] = vec3New(90, 90, 0),
            [214] = vec3New(90, 90, 0),
            [221] = vec3New(0, 90, 0),
            [222] = vec3New(0, 0, 0),
            [223] = vec3New(90, 0, 0),
            [224] = vec3New(90, 0, 0),
            [231] = vec3New(0, 90, 0),
            [232] = vec3New(0, 0, 0),
            [233] = vec3New(0, 0, 0),
            [234] = vec3New(90, 0, 0),
            [241] = vec3New(0, 90, 0),
            [242] = vec3New(0, 0, 0),
            [243] = vec3New(0, 0, 0),
            [244] = vec3New(0, 0, 0),
            [311] = vec3New(0, 0, 90),
            [312] = vec3New(0, 0, 90),
            [313] = vec3New(0, 0, 90),
            [314] = vec3New(90, 90, 0),
            [321] = vec3New(90, 0, 90),
            [322] = vec3New(90, 0, 90),
            [323] = vec3New(0, 0, 90),
            [324] = vec3New(90, 90, 0),
            [331] = vec3New(0, 90, 0),
            [332] = vec3New(0, 90, 0),
            [333] = vec3New(0, 0, 0),
            [334] = vec3New(90, 0, 0),
            [341] = vec3New(0, 90, 0),
            [342] = vec3New(0, 90, 0),
            [343] = vec3New(0, 0, 0),
            [344] = vec3New(0, 0, 0),
            [411] = vec3New(0, 0, 90),
            [412] = vec3New(0, 0, 90),
            [413] = vec3New(0, 0, 90),
            [414] = vec3New(0, 0, 90),
            [421] = vec3New(90, 0, 90),
            [422] = vec3New(0, 0, 90),
            [423] = vec3New(0, 0, 90),
            [424] = vec3New(0, 0, 90),
            [431] = vec3New(90, 0, 90),
            [432] = vec3New(90, 0, 90),
            [433] = vec3New(0, 0, 90),
            [434] = vec3New(0, 0, 90),
            [441] = vec3New(0, 90, 0),
            [442] = vec3New(0, 90, 0),
            [443] = vec3New(0, 90, 0),
            [444] = vec3New(0, 0, 0)
        }

        for bodyID, data in pairs(groupedInteractables) do
            local body = data.body
        
            if self.groupedMotorpoints[body.id] then -- clear up existing motorpoints for this body
                for i, motorpointGroup in ipairs(self.groupedMotorpoints[body.id]) do
                    if sm.exists( motorpointGroup ) then
                        motorpointGroup:destroy()
                    end
                end
            end
            self.groupedMotorpoints[body.id] = {}
        
            local minSize, maxSize = body:getLocalAabb()
            local sizeX = maxSize.x - minSize.x + 1
            local sizeY = maxSize.y - minSize.y + 1
            local sizeZ = maxSize.z - minSize.z + 1

            -- useful function to make fast keys from a 3d position
            local function makeIndex(ix, iy, iz)
                return ((ix - minSize.x) * sizeY + (iy - minSize.y)) * sizeZ + (iz - minSize.z)
            end
            
            -- create a local interactable grid to allow us to not loop over the entire AABB multiple times for each part type
            local interactableGrid = {}
            local localInteractableGrids = {}
            for uuid, interactables in pairs(data.uuids) do
                localInteractableGrids[uuid] = {}
                local count = 0
                for i, k in pairs(interactables) do
                    count = count + 1
                    if count > 50 then
                        for i, interactable in pairs(interactables) do
                            local position = interactable:getShape().localPosition
                            local positionKey = makeIndex(position.x, position.y, position.z)
                            interactableGrid[positionKey] = interactable
                            localInteractableGrids[uuid][positionKey] = interactable
                        end
                        goto stopCountingInteractablesForGrouping
                    end
                end
                createNonGroupedMotorpoints(interactables)
                ::stopCountingInteractablesForGrouping::
            end

            --loop through every position in the body
            for x = minSize.x, maxSize.x, 1 do
                for y = minSize.y, maxSize.y, 1 do
                    for z = minSize.z, maxSize.z, 1 do
                        
                        local positionKey = makeIndex(x,y,z)
                        local rootInteractable = interactableGrid[positionKey]
                        -- then loop for each axis to get the maximum size
                        if rootInteractable ~= nil then 
                            local rootShape = rootInteractable:getShape()
                            local rootUuid = rootShape.uuid
                            -- get the local grid for this part type
                            local localInteractableGrid = localInteractableGrids[tostring(rootUuid)]

                            -- find largest possible width/x
                            local width = 1
                            while true do
                                local testX = x + width
                                if testX > maxSize.x then break end
                                local testKey = makeIndex(testX, y, z)
                                if localInteractableGrid[testKey] and width < 4 then -- make sure to max out at 4
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
                                local fullRowIsValid = true
                                for columnOffset = 0, width - 1, 1 do
                                    local testX = x + columnOffset
                                    local testKey = makeIndex(testX, testY, z)
                                    if not localInteractableGrid[testKey] then
                                        fullRowIsValid = false
                                        break
                                    end
                                end
                                if fullRowIsValid and length < 4 then -- make sure to max out at 4
                                    length = length + 1
                                else
                                    break
                                end
                            end

                            -- find largest possible height/z
                            local height = 1
                            while true do
                                local testZ = z + height
                                if testZ > maxSize.z then break end
                            
                                local fullLayerIsValid = true
                                for rowOffset = 0, length - 1 do
                                    for columnOffset = 0, width - 1 do
                                        local testX = x + columnOffset
                                        local testY = y + rowOffset
                                        local testKey = makeIndex(testX, testY, testZ)
                                        if not localInteractableGrid[testKey] then
                                            fullLayerIsValid = false
                                            break
                                        end
                                    end
                                    if not fullLayerIsValid then break end
                                end
                            
                                if fullLayerIsValid and height < 4 then
                                    height = height + 1
                                else
                                    break
                                end
                            end

                            local sizeKey = width*100 + length*10 + height
                            local rotatedSizeX, rotatedSizeY, rotatedSizeZ = sort3(width, length, height)
                            local rotatedSizeKey = rotatedSizeX*100 + rotatedSizeY*10 + rotatedSizeZ

                            local currentMotorpoint = createEffect("ShapeRenderable", localInteractableGrid[positionKey])
                            currentMotorpoint:setParameter("uuid", sizeToUuid[rotatedSizeKey])
                            --currentMotorpoint:setParameter("color", sm.color.new( math.random(), math.random(), math.random(), 1 ))--interactableColor
                            currentMotorpoint:setParameter("color", uuidsToGroup[tostring(rootShape.uuid)])
                            currentMotorpoint:setOffsetRotation(quatInverse(rootShape.localRotation) * quatFromEuler(sizeToRotation[sizeKey]))
                            currentMotorpoint:setOffsetPosition(quatInverse(rootShape.localRotation) * vec3New(width-1,length-1,height-1)*0.125)
                            currentMotorpoint:start()
                            self.groupedMotorpoints[body.id][#self.groupedMotorpoints[body.id]+1] = currentMotorpoint

                            for rowOffset = 0, length - 1 do
                                for columnOffset = 0, width - 1 do
                                    for layerOffset = 0, height - 1 do
                                        local removeX = x + columnOffset
                                        local removeY = y + rowOffset
                                        local removeZ = z + layerOffset
                                        local removeKey = makeIndex(removeX, removeY, removeZ)
                                        interactableGrid[removeKey] = nil
                                        localInteractableGrid[removeKey] = nil
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        print(string.format("Elapsed time: %.4f seconds", os.clock()-startTime))
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
            for bodyId, motorpointList in pairs(self.groupedMotorpoints) do
                for i, motorpointEffect in ipairs(motorpointList) do
                    if sm.exists(motorpointEffect) then
                        motorpointEffect:destroy()
                    end
                end
            end
        end
    self.motorpoints = {}
    self.groupedMotorpoints = {}
end

function MPADefaultConnectTool.client_onEquippedUpdate( self, primaryState, secondaryState, forceBuild )

    return false, false
end