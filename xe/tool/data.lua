local M = {
    {
        class   = "tool", name = "New",
        tooltip = "Create a new project(Ctrl+N)",
        bitmap  = "new.png",
    },
    {
        class   = "tool", name = "Open",
        tooltip = "Open a project(Ctrl+O)",
        bitmap  = "open.png",
    },
    {
        class   = "tool", name = "Save",
        tooltip = "Save the project(Ctrl+S)",
        bitmap  = "save.png",
    },
    {
        class   = "tool", name = "Close",
        tooltip = "Close the project(Ctrl+W)",
        bitmap  = "delete.png",
    },
    --[[
    {
        class   = "tool", name = "Merge",
        tooltip = "Open a project and merge into current project",
        bitmap  = "merge.png",
    },
    --]]
    {
        class   = "tool", name = "Undo",
        tooltip = "Undo(Ctrl+Z)",
        bitmap  = "undo.png",
    },
    {
        class   = "tool", name = "Redo",
        tooltip = "Redo(Ctrl+Y)",
        bitmap  = "redo.png",
    },
    {
        class   = "tool", name = "Delete",
        tooltip = "Delete(Del)",
        bitmap  = "delete.png",
    },
    {
        class   = "tool", name = "Copy",
        tooltip = "Copy(Ctrl+C)",
        bitmap  = "copy.png",
    },
    {
        class   = "tool", name = "Cut",
        tooltip = "Cut(Ctrl+X)",
        bitmap  = "cut.png",
    },
    {
        class   = "tool", name = "Paste",
        tooltip = "Paste(Ctrl+V)",
        bitmap  = "paste.png",
    },
    {
        class   = "tool", name = "Setting",
        tooltip = "Settings",
        bitmap  = "setting.png",
    },
    {
        class   = "tool", name = "Pack",
        tooltip = "Build current project(F7)",
        bitmap  = "pack.png",
    },
    {
        class   = "tool", name = "DebugStage",
        tooltip = "Debug stage from current node(F6)",
        bitmap  = "debugstage.png",
    },
    {
        class   = "tool", name = "DebugSC",
        tooltip = "Debug spell card(Shift+F6)",
        bitmap  = "debugsc.png",
    },
    {
        class   = "tool", name = "Run",
        tooltip = "Run whole project(F5)",
        bitmap  = "run.png",
    },
    {
        class   = "tool", name = "InsertAfter",
        tooltip = "Insert after",
        bitmap  = "down.png",
    },
    {
        class   = "tool", name = "InsertBefore",
        tooltip = "Insert before",
        bitmap  = "up.png",
    },
    {
        class   = "tool", name = "InsertChild",
        tooltip = "Insert as child",
        bitmap  = "child.png",
    },
    --{
    --    class   = "tool", name = "Find",
    --    tooltip = "go to line number",
    --    bitmap  = "find.png",
    --},
    {
        class   = "tool", name = "MoveDown",
        tooltip = "Move down",
        bitmap  = "down.png",
    },
    {
        class   = "tool", name = "MoveUp",
        tooltip = "Move up",
        bitmap  = "up.png",
    },
}

return M
