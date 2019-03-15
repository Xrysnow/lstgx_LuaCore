---@class editor.scene:ViewBase
local M = class("EditorScene", cc.load("mvc").ViewBase)

local glv = cc.Director:getInstance():getOpenGLView()
local DropDownList = require('ui.DropDownList')
local _touchmask
local _touchmask_task = {}
local white = cc.c4b(255, 255, 255, 255)
local _main_tree
local _instance

function M:onCreate()
    _instance = self
end

---@return editor.scene
function M:getInstance()
    return _instance
end

function M:onEnter()
    --Print(self:getLocalZOrder())
    --Print(self:getGlobalZOrder())
    --local sc = cc.Director:getInstance():getRunningScene()
    glv:setDesignResolutionSize(1280, 720, cc.ResolutionPolicy.SHOW_ALL)
    glv:setFrameSize(1280, 720)

    local touchmask = ccui.Button:create('editor/null.png')
    touchmask:setScale9Enabled(true)
    touchmask:setContentSize(1280, 720)
    self:addChild(touchmask)
    touchmask:setZoomScale(0)
    touchmask:setAnchorPoint(cc.p(0, 0))
    touchmask:setPosition(cc.p(0, 0))
    touchmask:setSwallowTouches(false)
    touchmask:setLocalZOrder(10)
    touchmask:addClickEventListener(function()
        for _, v in pairs(_touchmask_task) do
            for _, u in ipairs(v) do
                u()
            end
        end
    end)
    _touchmask = touchmask
    _touchmask_task = {}

    ---@type editor.Tree
    local tree = require('editor.tree'):create({ size = cc.size(680, 700) })
    --tree:addTo(self):setPosition(242, 10)--:setVisible(false)
    _main_tree = tree
    self._tree = tree

    local tp = require('editor.tool_panel.ToolPanel')()
    --tp:addTo(self):setPosition(104, 0)
    local data = require('editor.tools_data')
    for _, v in ipairs(data) do
        --local ico = 'editor/images/toolbar/' .. v.bitmap
        --tp:addContent(nil,ico,nil)
        local tab = tp:createTab(v.label, nil)
        for _, u in ipairs(v.content) do
            local cb
            if string.sub(u.name, 1, 7) == 'Insert_' then
                local node_t = string.sub(u.name, 8)
                cb = function()
                    Print(string.format('Insert node of type [%s]', node_t))
                    M:getInstance():getMainTree():insertDefault(node_t)
                end
            elseif string.sub(u.name, 1, 4) == 'Tool' then
                local fname = u.name
                cb = function()
                    Print(string.format('[TOOL] %s', fname))
                    require('editor.ToolMgr')[fname]()
                end
            end
            tab:addContent(u.name, 'editor/x2/' .. u.bitmap, cb)
            --sel:addImage(u.name, cc.Sprite:create('editor/x2/' .. u.bitmap))
        end
    end

    self.menubar_h = 0

    self:_createPropPanel()

    --local tb = require('ui.TabBar'):create()
    --tb:addTo(self)
    --tb:addTab('General', cc.Node:create())
    --tb:addTab('Stage', cc.Node:create())
    --tb:setPosition(cc.p(100, 600))
    --tb:active(1)

    --local input_bg = ccui.Scale9Sprite:create('res/editor/base_button_normal.png')
    --input_bg:setCapInsets(cc.rect(2, 2, 28, 28))
    --local input1 = ccui.EditBox:create(cc.size(80, 48), input_bg)
    --input1:addTo(self)
    --input1:setPosition(cc.p(350, 100))
    --input1:setFontColor(cc.c3b(0, 0, 0))
    --input1:setFont('Arial', 20)

    --local dd = require('ui.DropDownList').createBase(96, 24, { 'Item_A', 'Item_B', 'Item_C' })
    --dd:addTo(self):setPosition(cc.p(300, 150))
    --local chb = require('ui.checkbox_prefab').createBase()
    --chb:addTo(self):setPosition(cc.p(200, 100)):setScale(1.2)
    --require('ui.MessageBox').OK_Cancel(nil,'This is a message')
    --local sel = require('editor.dialog.SelectImage')()

    local tpr = require('editor.tool_panel.ToolPanel')(
            {
                verticle     = true,
                size         = cc.size(48, 720),
                sel_size     = cc.size(48, 64),
                panel_size   = cc.size(64, 720),
                dir          = 'left',
                --color    = cc.c3b(33, 115, 70),
                sel_bg_color = cc.WHITE,
            })
    --tpr:addTo(self):setPosition(1280 - 48, 0)
    local tab1 = tpr:createTab('Property', nil)
    local tab2 = tpr:createTab('File', nil)
    --tpr:getPanel('Property'):setBackGroundColor(cc.RED)
    tab1:setContentSize(cc.size(300, 720)):alignLeft(-300)
    tab1:setBackGroundColor(cc.WHITE)
    self.property_panel:addTo(tab1):setContentSize(cc.size(280, 640)):alignCenter()
    local pp_frame = require('ui.helper').makeFrame(self.property_panel, cc.c4b(214, 214, 214, 255))
                                         :addTo(tab1):setPosition((300 - 280) / 2, (720 - 640) / 2)

    tab1:setOnResize(function(this, size)
        local sz = cc.size(size.width - 20, size.height - 80)
        self.property_panel:setContentSize(sz):alignCenter()
        pp_frame:setContentSize(sz)
    end)

    --require('editor.dialog.NewProject')()
    --require('editor.dialog.EditText')()
    --require('editor.dialog.Setting')()
    --require('editor.dialog.SelectObjectClass')()
    --require('editor.dialog.InputParameter')()
    --require('editor.dialog.InputTypeName')()
    local fp=require('editor.FilePanel')(
            {
                path      = 'api.lua',
                size      = cc.size(256, 720),
                view_size = cc.size(240, 640),
            }
    )
    fp:addTo(tab2):alignRight(0)--:setPosition(300,0)--:alignRight(150)
    tab2:setOnResize(function(this, size)
        fp:setContentSize(size):alignCenter()
    end)

    self:_initColorPicker()

    local color_bg=cc.c4b(224,224,224,255)
    self.sv = require('ui.SplitViewH')(nil, nil, { size = cc.size(1280, 720), color = color_bg })
    self.sv:addTo(self)
    self.sv:setMargin(8)
    self.sv:setLeft(self:_createToolbar(), { 104 })

    self.svr = require('ui.SplitViewH')(nil, nil, { color = color_bg })
    self.svr.margin.m = 8
    self.sv:setRight(self.svr)
    self.svr:setRight(tpr, { 320 })

    self.svrl = require('ui.SplitViewH')(nil, nil, { color = color_bg })
    self.svrl.margin.m = 8
    self.svr:setLeft(self.svrl)
    self.svrl:setLeft(tp, { 128 })
    self.svrl:setRight(tree)

    --local def = { l = self:_createToolbar(), r = { l = { l = tp, r = tree }, r = { tpr } } }

    cc.Director:getInstance():setDisplayStats(false)
    cc.Director:getInstance():getEventDispatcher():addCustomEventListener('glview_window_resized', function()
        local glv = cc.Director:getInstance():getOpenGLView()
        local fsize = glv:getFrameSize()
        if fsize.width < 200 then
            fsize.width = 200
        end
        if fsize.height < 200 then
            fsize.height = 200
        end
        glv:setDesignResolutionSize(fsize.width, fsize.height, cc.ResolutionPolicy.SHOW_ALL)
        self.sv:setContentSize(fsize)
    end)
end

function M.addMaskClickTask(sender, task)
    if not _touchmask_task[sender] then
        _touchmask_task[sender] = {}
    end
    table.insert(_touchmask_task[sender], task)
end

function M.removeMaskClickTask(sender)
    _touchmask_task[sender] = nil
end
--[[
function M:_initMenubar()
    local menubar_h = self.menubar_h
    local menubar = cc.LayerColor:create(white, 1280, menubar_h)
    menubar:addTo(self):setPosition(cc.p(0, 720 - menubar_h))

    local menubar_data = require('editor.menubar_data')
    for i, v in ipairs(menubar_data) do
        local btn = require('ui.ButtonToggle'):createBase(cc.size(48, menubar_h), v.title)
        btn:setTitleFontName('Arial'):setTitleFontSize(12)
        local menu = DropDownList:create(btn, menubar_h, 128, 128)
        for j, content in ipairs(v.content) do
            menu:addCell(content.title)
        end
        menubar:addChild(menu)
        menu:setPosition(cc.p((i - 1) * 48, 0))
    end
    self.menubar = menubar
    local draw = cc.DrawNode:create()
    draw:addTo(self)
    draw:setLineWidth(1)
    draw:drawLine(cc.p(0, 720 - menubar_h), cc.p(1280, 720 - menubar_h), cc.c4f(0.94, 0.94, 0.94, 1))
end
]]
--function M:_initBg()
--    local bg = ccui.Layout:create()
--    bg:setBackGroundColorType(1):setBackGroundColor(cc.c3b(192, 192, 192))
--    bg:setContentSize(cc.size(1280, 720))
--    self:add(bg, -100)
--    self.bg = bg
--end

function M:_createToolbar()
    self.toolbar_h = 52
    local hh = self.toolbar_h
    --local toolbar = cc.LayerColor:create(cc.WHITE, hh * 2, 720)
    local toolbar = ccui.Layout()
    toolbar:setBackGroundColorType(1):setBackGroundColor(cc.BLUE)
    --toolbar:addTo(self):setPosition(cc.p(0, 0))
    toolbar:setContentSize(cc.size(hh * 2, 720))

    local toolbar_data = require('editor.toolbar_data')
    for i, v in ipairs(toolbar_data) do
        local btn = require('ui.button').BaseButton(cc.size(hh - 4, hh - 4))
        btn:addTo(toolbar)
        btn:alignTop((math.floor((i - 1) / 2)) * hh + 1):alignLeft((i + 1) % 2 * hh + 1)
        local icon = cc.Sprite:create('editor/x2/images/toolbar/' .. v.bitmap)
        assert(icon, v.bitmap)
        icon:addTo(btn):setPosition(cc.p(hh / 2 - 2, hh / 2 - 2))
        btn:addClickEventListener(function()
            Print(string.format('[TOOL] %s', v.name))
            require('editor.ToolMgr')[v.name]()
        end)
    end
    return toolbar
end

local _prop_panel
function M:_createPropPanel()
    local panel = require('editor.property_panel')()
    --panel:setContentSize(cc.size(320, 640)):setPosition(cc.p(1280 - 320 - 64, 0))
    panel:setBackGroundColorType(1):setBackGroundColor(cc.c3b(235, 235, 235))
    --panel:addTo(self)
    --Print(stringify(panel:getContentSize()))
    _prop_panel = panel
    self.property_panel = panel
    return panel
end

local _color_picker
function M:_initColorPicker()
    local cp = require('ui.color_picker.ColorPicker')()
    local sz = cp:getContentSize()
    cp:addTo(self):setPosition(640 - sz.width / 2, 360 - sz.height / 2)
    cp:setVisible(false)
    _color_picker = cp
    self._color_picker = cp
end

---@return editor.Tree
function M.getMainTree()
    return M:getInstance()._tree
end

---@return editor.PropertyPanel
function M.getPropertyPanel()
    return M:getInstance().property_panel
end

function M.getColorPicker()
    return M:getInstance()._color_picker
end

return M
