--
local M = {}

function M.selectImage()
    local path = lstg.FileDialog:open('png,jpg,bmp', '')
    if path == '' then
        print(lstg.FileDialog:getLastError())
        return
    end
    return path
end

function M.selectImages()
    local paths = lstg.FileDialog:openMultiple('png,jpg,bmp', '')
    if #paths == 0 then
        print(lstg.FileDialog:getLastError())
        return
    end
    for i = 1, #paths do
        paths[i] = paths[i]:gsub('\\', '/')
    end
    return paths
end

function M.create(name, path, rect)
    local im = imgui
    local wi = require('imgui.Widget')

    local sp = cc.Sprite:create(unpack({ path, rect }))
    if not sp then
        print('failed to load:', path)
        return nil
    end
    local sz = sp:getContentSize()
    local t = { name = name, sprite = sp, size = { x = sz.width, y = sz.height } }
    local viewer = require('xe.image.ImageViewer')(t)
    sp:addTo(viewer):setVisible(false)

    local id = 'Image Viewer'
    local popup
    popup = wi.Widget(function()
        im.setNextWindowSize(im.vec2(350, 350), im.Cond.Once)
        im.openPopup(id)
        if im.beginPopupModal(id) then
            wi._handler(popup)
            im.endPopup()
        end
    end)
    viewer:addTo(popup)
    popup:addTo(require('xe.main'):getInstance()._la)
end

return M
