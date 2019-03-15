local FU = cc.FileUtils:getInstance()
---已包含的脚本
lstg.included = {}

---脚本搜索路径
lstg.current_script_path = { '' }

---Include(filename)
---包含（执行）脚本文件
function Include(filename)
    filename = tostring(filename)
    filename = string.gsub(filename, '\\', '/')
    filename = string.gsub(filename, '//', '/')
    filename = FU:fullPathForFilename(filename)
    if not plus.FileExists(filename) then
        --error('找不到脚本 ' .. filename)
        error(i18n("can't find script") .. ': ' .. filename)
    end

    if string.sub(filename, 1, 1) == '~' then
        filename = lstg.current_script_path[#lstg.current_script_path] .. string.sub(filename, 2)
    end
    if not lstg.included[filename] then
        local i, j = string.find(filename, '^.+[\\/]+')
        if i then
            table.insert(lstg.current_script_path, string.sub(filename, i, j))
        else
            table.insert(lstg.current_script_path, '')
        end
        lstg.included[filename] = true
        DoFile(filename)
        lstg.current_script_path[#lstg.current_script_path] = nil
    end
end

