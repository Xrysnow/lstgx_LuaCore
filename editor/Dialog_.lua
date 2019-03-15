--
local M = {}

local S = {}
M.EditorSetting = S

function S:show()
end

function S:setParam(setting)
    self.resXText:SetValue(tostring(setting.resx))
    self.resYText:SetValue(tostring(setting.resy))
    self.windowedCheckBox:SetValue(setting.windowed)
    self.cheatCheckBox:SetValue(setting.cheat)
    self.updateLibCheckBox:SetValue(setting.updatelib)
end

function S:OnOK(event)
    if tonumber(resXText:GetValue()) == nil or tonumber(resYText:GetValue()) == nil then
        wx.wxMessageBox("Resolution must be number", "Error", wx.wxICON_ERROR)
        return
    end
    setting.resx = tonumber(resXText:GetValue())
    setting.resy = tonumber(resYText:GetValue())
    setting.windowed = windowedCheckBox:GetValue()
    setting.cheat = cheatCheckBox:GetValue()
    setting.updatelib = updateLibCheckBox:GetValue()
    local f = io.open("editor\\EditorSetting.lua", "w")
    f:write("setting=" .. Tree.Serialize(setting))
    f:close()
    --event:Skip()
end

local NP = {}
M.NewProj = NP

function NP:show(b)
end

function NP:OnOK(event)
    local fileName = filePickerNewProj:GetPath()
    if fileName == "" then
        wx.wxMessageBox("Specify file path and name first", "Error", wx.wxICON_ERROR)
        return
    end
    local msg = LoadFromFile("editor/templates/" .. templates[listTemplate:GetSelection() + 1][2])
    if msg == nil then
        local msg2 = SaveToFile(fileName)
        if msg2 == nil then
            projectTree:Expand(rootNode)
            SetCurProjFile(fileName)
            frame:Enable(true)
            TreeShotUpdate()
            savedPos = 1
            event:Skip()
        else
            Tree.data = {}
            projectTree:DeleteChildren(rootNode)
            OutputLog(msg2, "Error")
        end
    else
        OutputLog(msg, "Error")
    end
end

function NP:OnCancel(event)
    frame:Enable(true)
    --event:Skip()
end

--
M.EditText = wx.wxDialog()
--xmlResource:LoadDialog(M.EditText, wx.NULL, "Edit Text")
--editAttrLabel = M.EditText:FindWindow(ID("EditAttrLabel")):DynamicCast("wxStaticText")
--editAttrText = M.EditText:FindWindow(ID("EditAttrText")):DynamicCast("wxTextCtrl")
--
M.Setting = wx.wxDialog()
--xmlResource:LoadDialog(M.Setting, wx.NULL, "Setting")
--resXText = M.Setting:FindWindow(ID("ResXText")):DynamicCast("wxTextCtrl")
--resYText = M.Setting:FindWindow(ID("ResYText")):DynamicCast("wxTextCtrl")
--windowedCheckBox = M.Setting:FindWindow(ID("WindowedCheckBox")):DynamicCast("wxCheckBox")
--cheatCheckBox = M.Setting:FindWindow(ID("CheatCheckBox")):DynamicCast("wxCheckBox")
--updateLibCheckBox = M.Setting:FindWindow(ID("UpdateLibCheckBox")):DynamicCast("wxCheckBox")
--
M.SoundEffect = wx.wxDialog()
--xmlResource:LoadDialog(M.SoundEffect, wx.NULL, "Select Sound Effect")
--soundListBox = M.SoundEffect:FindWindow(ID("SoundListBox")):DynamicCast("wxListBox")
--
M.Type = wx.wxDialog()
--xmlResource:LoadDialog(M.Type, wx.NULL, "Select Type")
--typeListBox = M.Type:FindWindow(ID("TypeListBox")):DynamicCast("wxListBox")
--
M.Image = wx.wxDialog()
--xmlResource:LoadDialog(M.Image, wx.NULL, "Select Image")
--imageListBox = M.Image:FindWindow(ID("ImageListBox")):DynamicCast("wxListBox")
--imagePrevPanel = M.Image:FindWindow(ID("ImagePrevPanel")):DynamicCast("wxPanel")
--
M.InputParameter = wx.wxDialog()
--xmlResource:LoadDialog(M.InputParameter, wx.NULL, "Input Parameter")
--for i = 1, 16 do
--    paramNameLabel[i] = M.InputParameter:FindWindow(ID("ParamNameLabel" .. i)):DynamicCast("wxStaticText")
--    paramText[i] = M.InputParameter:FindWindow(ID("ParamText" .. i)):DynamicCast("wxTextCtrl")
--end
--
M.InputTypeName = wx.wxDialog()
--xmlResource:LoadDialog(M.InputTypeName, wx.NULL, "Input Type Name")
--typeNameText = M.InputTypeName:FindWindow(ID("TypeNameText")):DynamicCast("wxTextCtrl")
--difficultyCombo = M.InputTypeName:FindWindow(ID("DifficultyCombo")):DynamicCast("wxComboBox")
--
M.SelectEnemyStyle = wx.wxDialog()
--xmlResource:LoadDialog(M.SelectEnemyStyle, wx.NULL, "Select Enemy Style")
--for i = 1, 34 do
--    selectEnemyStyleButton[i] = M.SelectEnemyStyle:FindWindow(ID("Style" .. i)):DynamicCast("wxBitmapButton")
--end
--
M.SelectBulletStyle = wx.wxDialog()
--xmlResource:LoadDialog(M.SelectBulletStyle, wx.NULL, "Select Bullet Style")
--for i, n in ipairs(enumType.bulletshow) do
--    selectBulletStyleButton[i] = M.SelectBulletStyle:FindWindow(ID(n)):DynamicCast("wxBitmapButton")
--end
--
M.SelectColor = wx.wxDialog()
--xmlResource:LoadDialog(M.SelectColor, wx.NULL, "Select Color")
--for i, n in ipairs(enumType.color) do
--    selectColorButton[i] = M.SelectColor:FindWindow(ID(n)):DynamicCast("wxBitmapButton")
--end

function M.getPicker(type)
    return {
        sound            = M.SoundEffect,
        image            = M.Image,
        selecttype       = M.Type,
        param            = M.InputParameter,
        typename         = M.InputTypeName,
        selectenemystyle = M.SelectEnemyStyle,
        bulletstyle      = M.SelectBulletStyle,
        color            = M.SelectColor,
    }[type]
end

return M
