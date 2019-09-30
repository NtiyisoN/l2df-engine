local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Entity = core.import 'core.class.entity'
local Render = core.import 'core.class.component.render'
local Frames = core.import 'core.class.component.frames'
local States = core.import 'core.class.component.states'
local Print = core.import 'core.class.component.print'

local UI = Entity:extend()

    function UI:init(kwargs)
        self.vars.x = kwargs.x or 0
        self.vars.y = kwargs.y or 0
        self.vars.z = kwargs.z or 0
        self.vars.r = math.rad(kwargs.r or 0)
        self.vars.scalex = kwargs.scalex or 1
        self.vars.scaley = kwargs.scaley or 1
        self.vars.pic = kwargs.pic or 1
        self.vars.hidden = kwargs.hidden or false
    end

    UI.Image = UI:extend({ name = 'image' })
    function UI.Image:init(kwargs)
        self:super(kwargs)
        self:addComponent(Render(), kwargs.sprites)
    end

    UI.Text = UI:extend({ name = 'text' })
    function UI.Text:init(kwargs)
        self:super(kwargs)
        self:addComponent(Print(kwargs))
    end

    UI.Animation = UI:extend({ name = 'animation' })
    function UI.Animation:init(kwargs)
        self:super(kwargs)
        self:addComponent(Render(), kwargs.sprites)
        self:addComponent(Frames(), 1, kwargs.nodes)
        self:addComponent(States())
    end

return setmetatable({ UI.Image, UI.Animation, UI.Text }, { __index = UI })