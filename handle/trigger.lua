require('CeresStdLib.handle.handle')
require('CeresStdLib.base.basics')

Trigger     = Trigger or Handle.new()
Trigger.__props.evalcount   = {
    get                     = function(t) return GetTriggerEvalCount(t.__obj) end
}
Trigger.__props.execcount   = {
    get                     = function(t) return GetTriggerExecCount(t.__obj) end
}
Trigger.__props.conditions  = {
    get                     = function(t) return #t.__conditions.__funcList.__protected end
}
Trigger.__props.actions     = {
    get                     = function(t) return #t.__actions.__funcList.__protected end
}

function Trigger.create() return Trigger.wrap(CreateTrigger()) end
function Trigger:eval() return TriggerEvaluate(self.__obj) end
function Trigger:exec() TriggerExecute(self.__obj) end
function Trigger:addCondition(func)
    if self.__conditions == nil then
        self.__conditions = {
            __funcList      = {
                __protected     = {}
            }
        }
        self.__conditions.__funcList.__protected.__index    = function(t, k) return self.__conditions.__funcList.__protected[k] end
        self.__conditions.__funcList.__protected.__newindex = function(t, k, v) end
        setmetatable(self.__conditions.__funcList, self.__conditions.__funcList.__protected)
        self.__conditions.__filterfunc = Filter(function()
            local b = true
            for k, v in ipairs(self.__conditions.__funcList.__protected) do
                self.__curfunc = v
                b = b and execute(v)
                if not b then break end
            end
            return b
        end)
        TriggerAddCondition(self.__obj, self.__conditions.__filterfunc)
    end
    table.insert(self.__conditions.__funcList.__protected, func)
    return #self.__conditions.__funcList.__protected
end
function Trigger:addAction(func)
    if self.__actions == nil then 
        self.__actions = {
            __funcList      = {
                __protected     = {}
            }
        }
        self.__actions.__funcList.__protected.__index    = function(t, k) return self.__actions.__funcList.__protected[k] end
        self.__actions.__funcList.__protected.__newindex = function(t, k, v) end
        setmetatable(self.__actions.__funcList, self.__actions.__funcList.__protected)
        self.__actions.__actionfunc = function()
            for k, v in ipairs(self.__actions.__funcList.__protected) do
                self.__curfunc = v
                execute(v)
            end
        end
        TriggerAddAction(self.__obj, self.__actions.__actionfunc)
    end
    table.insert(self.__actions.__funcList.__protected, func)
    return #self.__actions.__funcList.__protected
end
function Trigger:removeCondition(i)
    if self.__conditions == nil or self.conditions < i then return end
    table.remove(self.__conditions.__funcList.__protected, i)
end
function Trigger:removeAction(i)
    if self.__actions == nil or self.actions < i then return end
    table.remove(self.__actions.__funcList.__protected, i)
end
function Trigger:clearConditions()
    while self.conditions > 0 do
        self:removeCondition(self.conditions)
    end
end
function Trigger:clearActions()
    while self.actions > 0 do
        self:removeAction(self.actions)
    end
end
function Trigger:destroy()
    self:clearConditions()
    self:clearActions()
    TriggerRemoveCondition(self.__obj, self.__conditions.__filterfunc)
    TriggerRemoveAction(self.__obj, self.__actions.__actionfunc)

    self.__conditions.__filterfunc  = nil
    self.__actions.__actionfunc     = nil
    self.__conditions.__funcList.__protected    = nil
    self.__conditions.__funcList                = nil
    self.__actions.__funcList.__protected       = nil
    self.__actions.__funcList                   = nil
    self.__conditions   = nil
    self.__actions      = nil

    DestroyTrigger(self.__obj)
    self:unwrap()
end

function Trigger:registerEnterRegion(reg) return TriggerRegisterEnterRegion(self.__obj, reg) end
function Trigger:registerPlayerUnitEvent(p, ev, filter) return TriggerRegisterPlayerUnitEvent(self.__obj, p, ev, filter) end
function Trigger:registerAnyUnitEvent(ev)
    local eventList = {}
    for i = 0, (bj_MAX_PLAYER_SLOTS - 1) do
        table.insert(eventList, self:registerPlayerUnitEvent(players[i], ev, nil))
    end
    return eventList
end