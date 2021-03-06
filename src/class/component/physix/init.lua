--- Physics component
-- @classmod l2df.class.component.physix
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local helper = core.import 'helper'

local Component = core.import 'class.component'
local World = core.import 'class.component.physix.world'
local KindsManager = core.import 'manager.kinds'

local default = helper.notNil

local function convert(x)
    return x * 60
end

local function movementFilter(self, other)
    if other.vars.body and other.vars.static then return 'slide' end
    return self.vars.body and other.vars.body and self.vars.solid and other.vars.solid and 'slide' or 'cross'
end

local Physix = Component:extend({ unique = true })

    function Physix:init(...)
        self.entity = nil
        self.world = nil
    end

    function Physix:added(entity, kwargs)
        if not entity then return false end
        kwargs = kwargs or { }

        self.entity = entity
        local vars = entity.vars

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.vx = vars.vx or 0
        vars.vy = vars.vy or 0
        vars.vz = vars.vz or 0
        vars.dx = vars.dx or 0
        vars.dy = vars.dy or 0
        vars.dz = vars.dz or 0
        vars.dvx = vars.dvx or 0
        vars.dvy = vars.dvy or 0
        vars.dvz = vars.dvz or 0
        vars.dsx = vars.dsx or 0
        vars.dsy = vars.dsy or 0
        vars.dsz = vars.dsz or 0

        local body = kwargs.body
        if body then
            body.x = body.x or 0
            body.y = body.y or 0
            body.z = body.z or 0
            body.w = body.w or 1
            body.h = body.h or 1
            body.l = body.l or 1
        end
        vars.body = body

        vars.facing = vars.facing or kwargs.facing or 1
        vars.gravity = kwargs.gravity or false
        vars.static = kwargs.static or false
        vars.solid = default(kwargs.solid, true)
        return true
    end

    function Physix:removed(entity, world)
        world = world or self.world
        if world and world:hasItem(entity) then
            world:remove(entity)
        end
        self.entity = nil
        self.world = nil
    end

    function Physix:preUpdate()
        local entity = self.entity
        if not entity then return end

        local vars = entity.vars
        local world = World.getFromContext()

        if not world then
            local _ = self.world and self.world:remove(entity)
            self.world = nil
            return
        elseif world ~= self.world then
            local _ = self.world and self.world:hasItem(entity) and self.world:remove(entity)
            self.world = world
        end

        local body = vars.body
        if not body then return end

        local x, y, z, w, h, l = vars.x + body.x, vars.y + body.y, vars.z + body.z, body.w, body.h, body.l
        if world:hasItem(entity) then
            world:translate(entity, x, y, z, w, h, l)
        else
            world:add(entity, x, y, z, w, h, l)
        end
    end

    function Physix:update(dt)
        local entity = self.entity
        if not entity then return end

        local vars, world = entity.vars, self.world
        if not world or vars.static then return end

        local wdata = world:data()

        vars.vx = vars.vx - convert(vars.vx * wdata.friction) * dt
        vars.vx = vars.dvx ~= 0 and convert(vars.dvx) or vars.vx
        vars.vx = vars.vx + convert(vars.dsx)

        vars.vy = vars.vy + convert(vars.gravity and wdata.gravity or 0) * dt
        vars.vy = vars.dvy ~= 0 and convert(vars.dvy) or vars.vy
        vars.vy = vars.vy + convert(vars.dsy)

        vars.vz = vars.vz - convert(vars.vz * wdata.friction) * dt
        vars.vz = vars.dvz ~= 0 and convert(vars.dvz) or vars.vz
        vars.vz = vars.vz + convert(vars.dsz)

        local mx = (convert(vars.dx) + vars.vx) * dt
        local my = (convert(vars.dy) + vars.vy) * dt
        local mz = (convert(vars.dz) + vars.vz) * dt

        if world:hasItem(entity) then
            if mx ~= 0 or my ~= 0 or mz ~= 0 then
                local c, n
                mx, my, mz, c, n = world:moveRelative(entity, mx, my, mz, movementFilter)
                vars.x, vars.y, vars.z = vars.x + mx, vars.y + my, vars.z + mz
                for i = 1, n do
                    if c[n].normal.y ~= 0 then
                        vars.vy = 0
                    end
                end
            end

            local itrs, itr, kind, entities, count = vars.itrs
            local itrCount = itrs and #itrs or 0
            for i = 1, itrCount do
                itr = itrs[i]
                kind = KindsManager:get(itr.kind)
                if kind then
                    entities, count = world:queryCube(
                        vars.x + itr.x * vars.facing + itr.w * (vars.facing - 1) / 2,
                        vars.y + itr.y,
                        vars.z + itr.z,
                        itr.w, itr.h, itr.l,
                        kind.filter
                    )
                    for j = 1, count do
                        kind:trigger(entity, entities[j], itr)
                    end
                end
            end
        elseif mx ~= 0 or my ~= 0 or mz ~= 0 then
            vars.x, vars.y, vars.z = vars.x + mx, vars.y + my, vars.z + mz
        end

        vars.dsx, vars.dvx, vars.dx = 0, 0, 0
        vars.dsy, vars.dvy, vars.dy = 0, 0, 0
        vars.dsz, vars.dvz, vars.dz = 0, 0, 0
    end

return Physix