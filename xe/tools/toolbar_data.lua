local M = {
    {
        class   = "tool", name = "New",
        tooltip = {
            en = "Create a new project(Ctrl+N)",
            zh = "新建工程(Ctrl+N)",
        },
        --bitmap  = "new.png",
        bitmap  = "new.svg",
    },
    {
        class   = "tool", name = "Open",
        tooltip = {
            en = "Open a project(Ctrl+O)",
            zh = "打开工程(Ctrl+O)",
        },
        --bitmap  = "open.png",
        bitmap  = "open.svg",
    },
    {
        class   = "tool", name = "Save",
        tooltip = {
            en = "Save project(Ctrl+S)",
            zh = "保存工程(Ctrl+S)",
        },
        --bitmap  = "save.png",
        bitmap  = "save.svg",
    },
    {
        class   = "tool", name = "Close",
        tooltip = {
            en = "Close project(Ctrl+W)",
            zh = "关闭工程(Ctrl+W)",
        },
        --bitmap  = "delete.png",
        bitmap  = "close.svg",
    },
    --[[
    {
        class   = "tool", name = "Merge",
        tooltip = {
            en="Open a project and merge into current project",
            zh="",
        },
        bitmap  = "merge.png",
    },
    --]]
    --[[
    {
        class   = "tool", name = "Undo",
        tooltip = {
            en="Undo(Ctrl+Z)",
            zh="",
        },
        bitmap  = "undo.png",
    },
    {
        class   = "tool", name = "Redo",
        tooltip = {
            en="Redo(Ctrl+Y)",
            zh="",
        },
        bitmap  = "redo.png",
    },
    --]]
    {
        class   = "tool", name = "Delete",
        tooltip = {
            en = "Delete node(Del)",
            zh = "删除节点(Del)",
        },
        --bitmap  = "delete.png",
        bitmap  = "delete.svg",
    },
    {
        class   = "tool", name = "Copy",
        tooltip = {
            en = "Copy node(Ctrl+C)",
            zh = "复制节点(Ctrl+C)",
        },
        --bitmap  = "copy.png",
        bitmap  = "copy.svg",
    },
    {
        class   = "tool", name = "Cut",
        tooltip = {
            en = "Cut node(Ctrl+X)",
            zh = "剪切节点(Ctrl+X)",
        },
        --bitmap  = "cut.png",
        bitmap  = "cut.svg",
    },
    {
        class   = "tool", name = "Paste",
        tooltip = {
            en = "Paste node(Ctrl+V)",
            zh = "粘贴节点(Ctrl+V)",
        },
        --bitmap  = "paste.png",
        bitmap  = "paste.svg",
    },
    {
        class   = "tool", name = "Setting",
        tooltip = {
            en = "Settings",
            zh = "设置",
        },
        --bitmap  = "setting.png",
        bitmap  = "setting.svg",
    },
    {
        class   = "tool", name = "Build",
        tooltip = {
            en = "Build project(F7)",
            zh = "编译工程(F7)",
        },
        --bitmap  = "pack.png",
        bitmap  = "build.svg",
    },
    {
        class   = "tool", name = "Pack",
        tooltip = {
            en = "Pack project",
            zh = "打包工程",
        },
        --bitmap  = "pack.png",
        bitmap  = "pack.svg",
    },
    {
        class   = "tool", name = "DebugStage",
        tooltip = {
            en = "Debug stage from current node(F6)",
            zh = "运行当前关卡(F6)",
        },
        --bitmap  = "debugstage.png",
        bitmap  = "debug_stage.svg",
    },
    {
        class   = "tool", name = "DebugSC",
        tooltip = {
            en = "Debug spell card(Shift+F6)",
            zh = "运行当前符卡(Shift+F6)",
        },
        --bitmap  = "debugsc.png",
        bitmap  = "debug_sc.svg",
    },
    {
        class   = "tool", name = "Run",
        tooltip = {
            en = "Run whole project(F5)",
            zh = "运行(F5)",
        },
        --bitmap  = "run.png",
        bitmap  = "debug.svg",
    },
    {
        class   = "tool", name = "InsertAfter",
        tooltip = {
            en = "Insert after",
            zh = "优先插入为后继节点",
        },
        --bitmap  = "down.png",
        bitmap  = "insert_after.svg",
    },
    --[[
    {
        class   = "tool", name = "InsertBefore",
        tooltip = {
            en="Insert before",
            zh="",
        },
        bitmap  = "up.png",
    },
    --]]
    {
        class   = "tool", name = "InsertChild",
        tooltip = {
            en = "Insert as child",
            zh = "优先插入为子节点",
        },
        --bitmap  = "child.png",
        bitmap  = "insert_child.svg",
    },
    --[[
    {
        class   = "tool", name = "Find",
        tooltip = {
            en="go to line number",
            zh="",
        },
        bitmap  = "find.png",
    },
    --]]
    {
        class   = "tool", name = "MoveDown",
        tooltip = {
            en = "Move down",
            zh = "向下移动",
        },
        --bitmap  = "down.png",
        bitmap  = "move_down.svg",
    },
    {
        class   = "tool", name = "MoveUp",
        tooltip = {
            en = "Move up",
            zh = "向上移动",
        },
        --bitmap  = "up.png",
        bitmap  = "move_up.svg",
    },
}

return M
