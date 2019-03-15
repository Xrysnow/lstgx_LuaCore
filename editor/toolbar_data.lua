local M = {
    --[[
    {
        class   = "tool", name = "ToolNew",
        tooltip = "Create a new project(Ctrl+N)",
        bitmap  = "new.png",
    },
    {
        class   = "tool", name = "ToolOpen",
        tooltip = "Open a project(Ctrl+O)",
        bitmap  = "open.png",
    },
    {
        class   = "tool", name = "ToolSave",
        tooltip = "Save the project(Ctrl+S)",
        bitmap  = "save.png",
    },
    {
        class   = "tool", name = "ToolClose",
        tooltip = "Close the project(Ctrl+W)",
        bitmap  = "delete.png",
    },
    {
        class   = "tool", name = "ToolMerge",
        tooltip = "Open a project and merge into current project",
        bitmap  = "merge.png",
    },
    ]]
    {
        class   = "tool", name = "ToolUndo",
        tooltip = "Undo(Ctrl+Z)",
        bitmap  = "undo.png",
    },
    {
        class   = "tool", name = "ToolRedo",
        tooltip = "Redo(Ctrl+Y)",
        bitmap  = "redo.png",
    },
    {
        class   = "tool", name = "ToolDelete",
        tooltip = "Delete(Del)",
        bitmap  = "delete.png",
    },
    {
        class   = "tool", name = "ToolCopy",
        tooltip = "Copy(Ctrl+C)",
        bitmap  = "copy.png",
    },
    {
        class   = "tool", name = "ToolCut",
        tooltip = "Cut(Ctrl+X)",
        bitmap  = "cut.png",
    },
    {
        class   = "tool", name = "ToolPaste",
        tooltip = "Paste(Ctrl+V)",
        bitmap  = "paste.png",
    },
    {
        class   = "tool", name = "ToolSetting",
        tooltip = "Settings",
        bitmap  = "setting.png",
    },
    {
        class   = "tool", name = "ToolPack",
        tooltip = "Build current project(F7)",
        bitmap  = "pack.png",
    },
    {
        class   = "tool", name = "ToolDebugStage",
        tooltip = "Debug stage from current node(F6)",
        bitmap  = "debugstage.png",
    },
    {
        class   = "tool", name = "ToolDebugSC",
        tooltip = "Debug spell card(Shift+F6)",
        bitmap  = "debugsc.png",
    },
    {
        class   = "tool", name = "ToolRun",
        tooltip = "Run whole project(F5)",
        bitmap  = "run.png",
    },
    {
        class   = "tool", name = "ToolInsertAfter",
        tooltip = "Insert after",
        bitmap  = "down.png",
    },
    {
        class   = "tool", name = "ToolInsertBefore",
        tooltip = "Insert before",
        bitmap  = "up.png",
    },
    {
        class   = "tool", name = "ToolInsertChild",
        tooltip = "Insert as child",
        bitmap  = "child.png",
    },
    --{
    --    class   = "tool", name = "ToolFind",
    --    tooltip = "go to line number",
    --    bitmap  = "find.png",
    --},
    {
        class   = "tool", name = "ToolMoveDown",
        tooltip = "Move down",
        bitmap  = "movedown.png",
    },
    {
        class   = "tool", name = "ToolMoveUp",
        tooltip = "Move up",
        bitmap  = "moveup.png",
    },
}

return M
