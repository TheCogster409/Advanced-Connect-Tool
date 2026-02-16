MPADefaultConnectTool = class()


-- Serverside Callbacks
function MPADefaultConnectTool.server_onCreate( self )
    self.tick = 0
    self.checkBodyOverride = false
end

function MPADefaultConnectTool.server_onFixedUpdate( self, dt )
    self.tick = self.tick + 1

    if sm.util.positiveModulo(self.tick, 9999) == 0 or self.checkBodyOverride then -- get all interactables but only on every 4th tick for preformance
        local bodies = sm.body.getAllBodies()
        self.network:sendToClients("client_onInteractableUpdate", bodies)
        self.checkBodyOverride = false
    end
end

function MPADefaultConnectTool.server_forceBodyOverride( self )
    self.checkBodyOverride = true
end

-- Clientside Callbacks

function MPADefaultConnectTool.client_onCreate( self )
    self.motorpoints = {}
    self.interactables = {}
end

function MPADefaultConnectTool.client_onUpdate( self, dt )
        --self.effect:setOffsetRotation(sm.quat.inverse(self.shapee.localRotation) * sm.camera.getRotation())
        for i, motorpoint in ipairs(self.motorpoints) do
            --local shape = motorpoint[1]:getShape()
            --local position = shape:getWorldPosition()-- + (shape:getWorldRotation() * sm.vec3.new(0, -0.5, -0.5) / 4)
            local cameraPosition = sm.camera.getPosition() + self.tool:getOwner():getCharacter().velocity * dt
            motorpoint[1]:setPosition(motorpoint[2]:getShape():getWorldPosition() * 0.25 + cameraPosition * 0.75)
        end
end

function MPADefaultConnectTool.client_onInteractableUpdate(self, bodies)

   
    if self.motorpoints then -- make sure to clear up non existent motorpoints
        for i, motorpoint in ipairs(self.motorpoints) do
            if not sm.exists( motorpoint[1] ) then
                self.motorpoints[i] = nil
            end
        end
    end

    print("refresh")

    local newlyMadeInteractables = {}
    local interactables = {}
    if self.equipped then
        for i, body in ipairs(bodies) do
            if sm.exists(body) then
                local bodyInteractables = body:getInteractables()
                for k, bodyInteractable in ipairs(bodyInteractables) do
                    if self.interactables[bodyInteractable] == nil then
                        newlyMadeInteractables[#newlyMadeInteractables+1] = bodyInteractable
                    end
                    interactables[bodyInteractable] = true
                end
            end
        end
    end
    self.interactables = interactables
    
    for i, interactable in ipairs(newlyMadeInteractables) do
        local currentMotorpoint = {sm.effect.createEffect("MPAMotorpoint"), interactable}
        currentMotorpoint[1]:setAutoPlay(true)
        currentMotorpoint[1]:start()
        self.motorpoints[#self.motorpoints+1] = currentMotorpoint
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
    self.motorpoints = {}
end

function MPADefaultConnectTool.client_onEquippedUpdate( self, primaryState, secondaryState, forceBuild )

    return true, true
end

function MPADefaultConnectTool.client_onToggle( self, backwards )

    return true
end

function MPADefaultConnectTool.client_onReload( self )

    return true
end

function MPADefaultConnectTool.client_canEquip( self )

    return true
end

function MPADefaultConnectTool.client_equipWhileSeated( self )

end

function MPADefaultConnectTool.client_onClientDataUpdate( self, data, channel )

end

function MPADefaultConnectTool.client_onDestroy( self )

end