#NoEnv

global UI_HWND := 0
global UI_VISIBLE := 0
global UI_W := 760
global UI_H := 560
global UI_BC := 0
global UI_LOGOIMG := 0
global UI_ICONIMG := 0
global UI_PAGE := 0
global UI_SCROLL := 0
global UI_SCROLLT := 0
global UI_SEARCH := ""
global UI_CAPIDX := -1
global UI_CAPMODE := ""
global UI_CAPNEW := ""
global UI_SEARCHING := 0
global UI_WINX := -1
global UI_WINY := -1
global UI_CUR := ""
global UI_WHEEL := 0
global UI_PREVLMB := 0
global UI_PREVRMB := 0
global UI_PREVESC := 0
global UI_DRAGGING := 0
global UI_DRAGX := 0
global UI_DRAGY := 0
global UI_DRAGWX := 0
global UI_DRAGWY := 0
global UI_RESIZING := 0
global UI_RESIZE := ""
global UI_RESIZEX := 0
global UI_RESIZEY := 0
global UI_RESIZEWX := 0
global UI_RESIZEWY := 0
global UI_RESIZEWW := 0
global UI_RESIZEWH := 0
global UI_TIME := 0
global UI_CARET := 0
global UI_DD := 0
global UI_DRAGID := ""
global UI_LASTTICK := 0
global UI_WASREADY := 0
global UI_OFFSCREEN := 0
global UI_TOAST := ""
global UI_TOASTUNTIL := 0
global UI_PREVMX := -1
global UI_PREVMY := -1
global UI_DIRTY := 0

global UI_CT := []
global UI_GRPS := []
global UI_HK := []
global UI_CFG := { aspect: 150 }
global UI_STATUS := { state: "absent", ok: false, pid: 0, resolved: 0, title: "", sub: "", miss: "" }
global UI_ASPITEMS := []
global UI_ASPFOCUS := 0
global UI_ASPDRAFT := ""
global UI_ASPKEYS := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5", "Numpad6", "Numpad7", "Numpad8", "Numpad9", "Backspace", "Enter", "NumpadEnter", "Delete"]
global UI_ASPKEYPREV := {}

global PAGE_RENDER := 0
global PAGE_ASPECT := 1
global PAGE_INFO := 2

UI_InitFonts(logfn := 0)
{
    global UI_FAM_R, UI_FAM_M, UI_FAM_S, UI_FAM_L, UI_LOGOIMG, UI_ICONIMG
    GP_Startup()
    Dir := A_ScriptDir "\data\fonts"
    UI_FAM_R := GP_FamilyFromFile(Dir "\MuseoSansCyrl.ttf")
    if (!UI_FAM_R)
    {
        UI_FAM_R := GP_LoadFamily(Dir, "Museo", logfn)
        GP_Log(logfn, "ui: MuseoSansCyrl file load failed, trying family load")
    }
    if (!UI_FAM_R)
    {
        UI_FAM_R := GP_SysFamily("Segoe UI")
        GP_Log(logfn, "ui: Museo unavailable, falling back to Segoe UI")
    }
    UI_FAM_M := UI_FAM_R
    UI_FAM_S := UI_FAM_R
    if (!UI_FAM_R)
    {
        UI_FAM_R := GP_SysFamily("Arial")
        GP_Log(logfn, "ui: Segoe UI unavailable, falling back to Arial")
        UI_FAM_M := UI_FAM_R
        UI_FAM_S := UI_FAM_R
    }
    UI_FAM_L := GP_FamilyFromFile(Dir "\lucide.ttf")
    if (!UI_FAM_L)
        GP_Log(logfn, "ui: lucide icon font unavailable")
    if (FileExist(A_ScriptDir "\data\logo.png"))
    {
        UI_LOGOIMG := GP_Image(A_ScriptDir "\data\logo.png")
        if (!IsObject(UI_LOGOIMG))
            UI_LOGOIMG := 0
    }
    UI_ICONIMG := GP_Image(A_ScriptDir "\data\icon.ico")
    if (!IsObject(UI_ICONIMG))
        UI_ICONIMG := 0
}

UI_InitWindow()
{
    global UI_HWND, UI_W, UI_H, UI_WINX, UI_WINY
    Gui, UI:New, -Caption +E0x00040000 +LastFound +hwndUI_HWND -DPIScale
    Gui, UI:Color, 101115
    Gui, UI:Font, s9, Segoe UI
    c := 0x141A1F
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", UI_HWND, "UInt", 33, "UInt*", 2, "UInt", 4)
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", UI_HWND, "UInt", 34, "Ptr", &c, "UInt", 4)
    dm := 1
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", UI_HWND, "UInt", 20, "Ptr", &dm, "UInt", 4)
    UI_SetWindowIcon()
    OnMessage(0x20A, "UI_OnWheel")
    OnMessage(0x0F, "UI_OnPaint")
    OnMessage(0x08, "UI_OnBlur")
    OnMessage(0x102, "UI_OnChar")
    UI_Resize(S(UI_W), S(UI_H))
    if (UI_WINX < 0)
        UI_WINX := (A_ScreenWidth - UI_W) // 2
    if (UI_WINY < 0)
        UI_WINY := (A_ScreenHeight - UI_H) // 2
}

UI_Resize(w, h)
{
    global UI_W, UI_H, UI_BC
    if (w = UI_W && h = UI_H && IsObject(UI_BC))
        return
    UI_W := w
    UI_H := h
    if (IsObject(UI_BC))
        UI_BC := GP_ScaleBackbuffer(UI_BC, w, h)
    else
        UI_BC := GP_Backbuffer(w, h, 0xFF101115)
}

UI_ResetInput()
{
    global UI_CAPIDX, UI_CAPMODE, UI_CAPNEW, UI_SEARCHING, UI_DRAGGING, UI_DRAGID
    global UI_CLICK, UI_LMB, UI_PREVLMB, UI_PREVESC, UI_WHEEL, UI_MODAL, UI_HITCLIP, UI_INPUTACTIVE
    global UI_RCLICK, UI_RMB, UI_PREVRMB
    global UI_TIP, UI_HOT, UI_ANYHIT, UI_KEYPREV, UI_TYPEPREV, UI_OFFSCREEN
    global UI_RESIZING, UI_RESIZE, UI_RESIZEX, UI_RESIZEY, UI_RESIZEWX, UI_RESIZEWY, UI_RESIZEWW, UI_RESIZEWH
    if (UI_OFFSCREEN)
        return
    capture := UI_CAPIDX >= 0
    UI_CAPIDX := -1
    UI_CAPMODE := ""
    UI_CAPNEW := ""
    UI_SEARCHING := 0
    UI_ASPFOCUS := 0
    UI_ASPDRAFT := ""
    UI_DRAGGING := 0
    UI_DRAGID := ""
    UI_RESIZING := 0
    UI_RESIZE := ""
    UI_CLICK := 0
    UI_LMB := 0
    UI_PREVLMB := 0
    UI_RCLICK := 0
    UI_RMB := 0
    UI_PREVRMB := 0
    UI_PREVESC := 0
    UI_WHEEL := 0
    UI_MODAL := 0
    UI_HITCLIP := 0
    UI_INPUTACTIVE := 0
    UI_TIP := ""
    UI_HOT := ""
    UI_ANYHIT := 0
    UI_KEYPREV := {}
    UI_TYPEPREV := {}
    DD_Close()
    if (capture)
        UI_Act("capture_end")
}

UI_SetWindowIcon()
{
    global UI_HWND
    if (!UI_HWND)
        return
    ico := A_ScriptDir "\data\icon.ico"
    hIcon := DllCall("LoadImage", "Ptr", 0, "Str", ico, "UInt", 1, "Int", 0, "Int", 0, "UInt", 0x10 | 0x40, "Ptr")
    if (!hIcon)
        hIcon := DllCall("LoadImage", "Ptr", 0, "Str", ico, "UInt", 1, "Int", 32, "Int", 32, "UInt", 0x10, "Ptr")
    if (!hIcon)
        return
    DllCall("SendMessage", "Ptr", UI_HWND, "UInt", 0x80, "Ptr", 1, "Ptr", hIcon)
    DllCall("SendMessage", "Ptr", UI_HWND, "UInt", 0x80, "Ptr", 0, "Ptr", hIcon)
    Try
        DllCall("SetClassLongPtr", "Ptr", UI_HWND, "Int", -14, "Ptr", hIcon)
    Try
        DllCall("SetClassLongPtr", "Ptr", UI_HWND, "Int", -34, "Ptr", hIcon)
    DllCall("RedrawWindow", "Ptr", UI_HWND, "Ptr", 0, "Ptr", 0, "UInt", 0x0001 | 0x0002 | 0x0100 | 0x0400)
    DllCall("UpdateWindow", "Ptr", UI_HWND)
}

UI_Show()
{
    global UI_HWND, UI_VISIBLE, UI_W, UI_H, UI_WINX, UI_WINY, UI_DT, UI_LASTTICK
    UI_ResetInput()
    UI_Resize(S(760), S(560))
    UI_VISIBLE := 1
    UI_LASTTICK := 0
    UI_DT := 0
    Gui, UI:Show, x%UI_WINX% y%UI_WINY% w%UI_W% h%UI_H%
    WinRestore, ahk_id %UI_HWND%
    WinActivate, ahk_id %UI_HWND%
    UI_SetWindowIcon()
    UI_Frame()
}

UI_Hide()
{
    global UI_VISIBLE, UI_WINX, UI_WINY, UI_HWND, UI_LASTTICK
    if (!DllCall("IsIconic", "Ptr", UI_HWND))
    {
        WinGetPos, px, py, , , ahk_id %UI_HWND%
        if (px != "" && py != "")
        {
            UI_WINX := px
            UI_WINY := py
        }
    }
    UI_ResetInput()
    Gui, UI:Hide
    UI_VISIBLE := 0
    UI_LASTTICK := 0
}

UI_Toggle()
{
    global UI_VISIBLE, UI_HWND
    if (UI_VISIBLE && !DllCall("IsIconic", "Ptr", UI_HWND))
        UI_Hide()
    else
        UI_Show()
}

UI_OnBlur(wParam, lParam, msg, hwnd)
{
    global UI_HWND
    if (hwnd = UI_HWND)
        UI_ResetInput()
}

UI_OnPaint(wParam, lParam, msg, hwnd)
{
    global UI_HWND, UI_BC
    if (hwnd != UI_HWND || !IsObject(UI_BC))
        return
    VarSetCapacity(ps, A_PtrSize = 8 ? 72 : 64, 0)
    dc := DllCall("BeginPaint", "Ptr", hwnd, "Ptr", &ps, "Ptr")
    if (dc)
        DllCall("BitBlt", "Ptr", dc, "Int", 0, "Int", 0, "Int", UI_BC.w, "Int", UI_BC.h, "Ptr", UI_BC.memdc, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
    DllCall("EndPaint", "Ptr", hwnd, "Ptr", &ps)
    return 0
}

UI_OnWheel(wParam, lParam, msg, hwnd)
{
    global UI_WHEEL, UI_VISIBLE, UI_HWND, UI_PAGE, UI_STATUS, UI_DD, UI_CAPIDX, UI_W, UI_H
    if (hwnd != UI_HWND || !UI_VISIBLE || DllCall("GetForegroundWindow", "Ptr") != UI_HWND)
        return
    if (!UI_STATUS.ok || IsObject(UI_DD) || UI_CAPIDX >= 0 || UI_PAGE != PAGE_RENDER)
        return 0
    VarSetCapacity(pt, 8, 0)
    NumPut(lParam & 0xFFFF, pt, 0, "Short")
    NumPut((lParam >> 16) & 0xFFFF, pt, 4, "Short")
    NumPut(NumGet(pt, 0, "Short"), pt, 0, "Int")
    NumPut(NumGet(pt, 4, "Short"), pt, 4, "Int")
    DllCall("ScreenToClient", "Ptr", UI_HWND, "Ptr", &pt)
    x := NumGet(pt, 0, "Int")
    y := NumGet(pt, 4, "Int")
    if (x < S(72) || x >= UI_W - S(24) || y < S(100) || y >= UI_H - S(38))
        return 0
    d := (wParam >> 16) & 0xFFFF
    if (d > 32767)
        d -= 65536
    UI_WHEEL -= d / 120.0
    return 0
}

UI_Poll()
{
    global UI_MX, UI_MY, UI_LMB, UI_CLICK, UI_PREVLMB, UI_PREVESC, UI_INPUTACTIVE, UI_VISIBLE
    global UI_RMB, UI_RCLICK, UI_PREVRMB
    global UI_HWND, UI_DRAGGING, UI_DRAGX, UI_DRAGY, UI_DRAGWX, UI_DRAGWY, UI_WINX, UI_WINY, UI_ANYHIT, UI_TIP, UI_HOT
    active := UI_VISIBLE && !DllCall("IsIconic", "Ptr", UI_HWND) && DllCall("GetForegroundWindow", "Ptr") = UI_HWND
    wasActive := UI_INPUTACTIVE
    if (!active && wasActive)
        UI_ResetInput()
    UI_INPUTACTIVE := active ? 1 : 0
    VarSetCapacity(pt, 8, 0)
    DllCall("GetCursorPos", "Ptr", &pt)
    cx := NumGet(pt, 0, "Int")
    cy := NumGet(pt, 4, "Int")
    DllCall("ScreenToClient", "Ptr", UI_HWND, "Ptr", &pt)
    UI_MX := NumGet(pt, 0, "Int")
    UI_MY := NumGet(pt, 4, "Int")
    global UI_PREVMX, UI_PREVMY
    if (UI_MX != UI_PREVMX || UI_MY != UI_PREVMY)
    {
        UI_PREVMX := UI_MX
        UI_PREVMY := UI_MY
        UI_DIRTY := 1
    }
    else
        UI_DIRTY := 0
    UI_LMB := active && GetKeyState("LButton", "P") ? 1 : 0
    UI_RMB := active && GetKeyState("RButton", "P") ? 1 : 0
    if (active && !wasActive)
    {
        UI_PREVLMB := UI_LMB
        UI_PREVRMB := UI_RMB
        UI_PREVESC := GetKeyState("Escape", "P") ? 1 : 0
    }
    UI_CLICK := UI_LMB && !UI_PREVLMB ? 1 : 0
    UI_PREVLMB := UI_LMB
    UI_RCLICK := UI_RMB && !UI_PREVRMB ? 1 : 0
    UI_PREVRMB := UI_RMB
    if (UI_CLICK || UI_RCLICK || UI_WHEEL)
        UI_DIRTY := 1
    UI_ANYHIT := 0
    UI_TIP := ""
    UI_HOT := ""
    if (UI_DRAGGING)
    {
        if (UI_LMB && active)
        {
            nx := cx - UI_DRAGX
            ny := cy - UI_DRAGY
            if (nx != UI_DRAGWX || ny != UI_DRAGWY)
            {
                DllCall("SetWindowPos", "Ptr", UI_HWND, "Ptr", 0, "Int", nx, "Int", ny, "Int", 0, "Int", 0, "UInt", 0x0015)
                UI_DRAGWX := nx
                UI_DRAGWY := ny
                UI_WINX := nx
                UI_WINY := ny
            }
        }
        else
            UI_DRAGGING := 0
    }
    if (!UI_DRAGGING && active && UI_INPUTACTIVE)
    {
        UI_ResizeHover(cx, cy)
        if (UI_RESIZE != "" && UI_LMB && !UI_PREVLMB)
        {
            UI_RESIZING := 1
            WinGetPos, wx, wy, ww, wh, ahk_id %UI_HWND%
            UI_RESIZEX := cx
            UI_RESIZEY := cy
            UI_RESIZEWX := wx
            UI_RESIZEWY := wy
            UI_RESIZEWW := ww
            UI_RESIZEWH := wh
            UI_CLICK := 0
        }
    }
    if (UI_RESIZING)
    {
        if (UI_LMB && active)
        {
            dx := cx - UI_RESIZEX
            dy := cy - UI_RESIZEY
            nw := UI_RESIZEWW
            nh := UI_RESIZEWH
            if (InStr(UI_RESIZE, "r"))
                nw += dx
            if (InStr(UI_RESIZE, "b"))
                nh += dy
            if (nw < S(500))
                nw := S(500)
            if (nh < S(400))
                nh := S(400)
            if (nw != UI_W || nh != UI_H)
                UI_Resize(nw, nh)
        }
        else
            UI_RESIZING := 0
    }
}

UI_ResizeHover(cx, cy)
{
    global UI_HWND, UI_W, UI_H, UI_RESIZE
    if (!IsObject(UI_HWND) || !UI_HWND)
        return
    VarSetCapacity(rc, 16, 0)
    DllCall("GetClientRect", "Ptr", UI_HWND, "Ptr", &rc)
    w := NumGet(rc, 8, "Int")
    h := NumGet(rc, 12, "Int")
    VarSetCapacity(pt, 8, 0)
    DllCall("GetCursorPos", "Ptr", &pt)
    DllCall("ScreenToClient", "Ptr", UI_HWND, "Ptr", &pt)
    mx := NumGet(pt, 0, "Int")
    my := NumGet(pt, 4, "Int")
    edge := S(7)
    atR := (mx > w - edge)
    atB := (my > h - edge)
    dir := ""
    if (atR && atB)
        dir := "br"
    else if (atR)
        dir := "r"
    else if (atB)
        dir := "b"
    UI_RESIZE := dir
    if (dir = "")
        DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32512, "Ptr"))
    else if (dir = "br")
        DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32642, "Ptr"))
    else if (dir = "r")
        DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32644, "Ptr"))
    else if (dir = "b")
        DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32645, "Ptr"))
}

UI_Frame()
{
    global UI_BC, UI_HWND, UI_DT, UI_TIME, UI_VISIBLE, UI_CARET, UI_LASTTICK
    global UI_HK, UI_SEARCH, UI_SEARCHING, UI_CAPIDX, UI_CAPMODE, UI_DD, UI_MODAL, UI_HITCLIP
    global UI_INPUTACTIVE, UI_PREVESC, UI_CLICK, UI_STATUS, UI_WASREADY, UI_WHEEL, UI_W, UI_H, UI_DRAGGING, UI_RESIZING
    if (!UI_VISIBLE)
        return
    if (DllCall("IsIconic", "Ptr", UI_HWND))
    {
        if (UI_INPUTACTIVE)
            UI_ResetInput()
        UI_LASTTICK := 0
        return
    }
    now := ClockMs()
    UI_DT := UI_LASTTICK ? Min(0.1, Max(0, (now - UI_LASTTICK) / 1000.0)) : 0
    UI_LASTTICK := now
    dirty := 0
    UI_TIME += UI_DT
    caretWas := UI_CARET
    UI_CARET += UI_DT
    if ((UI_ASPFOCUS || UI_SEARCHING) && Floor(UI_CARET * 2.2) != Floor(caretWas * 2.2))
        dirty := 1
    if (UI_WASREADY && !UI_STATUS.ok)
        UI_ResetInput()
    UI_WASREADY := UI_STATUS.ok
    UI_Poll()
    if (UI_DRAGGING)
    {
        UI_WHEEL := 0
        return 1
    }
    UI_HITCLIP := 0
    UI_MODAL := IsObject(UI_DD) || UI_CAPIDX >= 0 ? 1 : 0
    if (UI_INPUTACTIVE)
    {
        esc := GetKeyState("Escape", "P") ? 1 : 0
        if (esc && !UI_PREVESC)
        {
            if (UI_CAPIDX >= 0)
                UI_ResetInput()
            else if (IsObject(UI_DD))
                DD_Close()
            else if (UI_ASPFOCUS)
                UI_ASPFOCUS := 0
            else
                UI_SEARCHING := 0
            UI_CLICK := 0
        }
        else if (UI_CAPIDX >= 0)
        {
            k := UI_CaptureTick()
            if (k = "__cancel__")
                UI_ResetInput()
            else if (k != "")
            {
                idx := UI_CAPIDX
                mode := UI_CAPMODE
                UI_CAPIDX := -1
                UI_CAPMODE := ""
                UI_HK_Done(idx, k)
                UI_Act("capture_end")
                UI_CLICK := 0
            }
        }
        else if (UI_SEARCHING && !IsObject(UI_DD))
        {
            if (UI_CLICK && !InRect(S(72), S(56), UI_W - S(96), S(34)))
                UI_SEARCHING := 0
        }
        else if (UI_ASPFOCUS && !IsObject(UI_DD))
        {
            if (UI_CLICK && !InRect(S(90), S(108), UI_W - S(132), S(34)))
            {
                UI_ASPFOCUS := 0
                if (UI_ASPDRAFT != "")
                    UI_Act("aspect_set")
                UI_CLICK := 0
            }
        }
        if (UI_ASPFOCUS)
            UI_ASPTypeTick()
        UI_PREVESC := esc
    }
    if (!IsObject(UI_BC))
        return 1
    if (dirty || UI_DIRTY || UI_NeedsRepaint())
        UI_PaintFrame(UI_BC)
    UI_WHEEL := 0
    if (UI_VISIBLE)
        GP_Present(UI_BC, UI_HWND)
    if (UI_INPUTACTIVE)
        UI_Hand()
    return 1
}

UI_NeedsRepaint()
{
    global UI_ANIM, UI_ANIMT, UI_TIME, UI_CARET, UI_ASPFOCUS, UI_SEARCHING, UI_TIP, UI_TOAST, UI_TOASTUNTIL
    global UI_DD, UI_CAPIDX, UI_DRAGGING, UI_RESIZING, UI_SCROLL, UI_SCROLLT, UI_STATUS, UI_MODAL
    if (UI_ASPFOCUS || UI_SEARCHING || IsObject(UI_DD) || UI_CAPIDX >= 0)
        return 1
    if (UI_DRAGGING || UI_RESIZING || UI_MODAL)
        return 1
    if (UI_TIP != "" || (UI_TOAST != "" && UI_TIME < UI_TOASTUNTIL))
        return 1
    if (Abs(UI_SCROLL - UI_SCROLLT) > 0.7)
        return 1
    for id, v in UI_ANIM
    {
        t := UI_ANIMT.HasKey(id) ? UI_ANIMT[id] : -1
        if (UI_TIME - t < 0.5)
            return 1
    }
    return 0
}

UI_PaintFrame(bc)
{
    global UI_W, UI_H, UI_HITCLIP, UI_OFFSCREEN
    g := bc.g
    GP_Clear(g, COL_BG)
    p := GP_RoundRect(0, 0, UI_W, UI_H, S(11))
    st := GP_ClipPathPush(g, p)
    GP_FreePath(p)
    UI_Draw(g)
    UI_HITCLIP := 0
    sel := DD_Draw(g)
    if (!UI_OFFSCREEN)
        DD_Apply(sel)
    DrawCapture(g)
    DrawToast(g)
    if (!UI_OFFSCREEN)
    {
        UI_PageTips(g)
        Tip_Draw(g)
    }
    GP_ClipPop(g, st)
    GP_Flush(bc)
}

UI_RenderToFile(path)
{
    global
    local names, saved, name, bc, result, _
    names := ["UI_INPUTACTIVE", "UI_CLICK", "UI_LMB", "UI_RCLICK", "UI_RMB", "UI_PREVRMB", "UI_WHEEL", "UI_MODAL", "UI_HITCLIP", "UI_MX", "UI_MY", "UI_DT", "UI_TIME", "UI_CARET", "UI_ANIM", "UI_HOV", "UI_HOT", "UI_ANYHIT", "UI_TIP", "UI_TIPX", "UI_TIPY", "UI_SCROLL", "UI_SCROLLT", "UI_DRAGID", "UI_DD", "UI_OFFSCREEN"]
    saved := {}
    for _, name in names
        saved[name] := %name%
    UI_ANIM := {}
    UI_HOV := {}
    UI_DD := IsObject(UI_DD) ? UI_DD.Clone() : 0
    UI_OFFSCREEN := 1
    UI_RCLICK := 0
    UI_RMB := 0
    UI_PREVRMB := 0
    UI_INPUTACTIVE := 0
    UI_CLICK := 0
    UI_LMB := 0
    UI_WHEEL := 0
    UI_MX := -10000
    UI_MY := -10000
    UI_DT := 0
    UI_TIME := 0
    UI_CARET := 0
    UI_DRAGID := ""
    UI_TIP := ""
    UI_HITCLIP := 0
    UI_MODAL := IsObject(UI_DD) || UI_CAPIDX >= 0 ? 1 : 0
    bc := GP_Backbuffer(UI_W, UI_H)
    try
    {
        UI_PaintFrame(bc)
        result := GP_Save(bc, path)
    }
    finally
    {
        GP_FreeBackbuffer(bc)
        for _, name in names
            %name% := saved[name]
    }
    return result
}

DrawFade(g)
{
    global UI_W, UI_H
    fade := Anim("fade", 1.0, 11.0)
    if (fade < 0.999)
        Fill(g, 0, 0, UI_W, UI_H, 0, Al(COL_BG, 1 - fade))
}

UI_Draw(g)
{
    global UI_W, UI_H, UI_PAGE, UI_CLICK, UI_ANYHIT, UI_MX, UI_MY, UI_DRAGGING, UI_DRAGX, UI_DRAGY, UI_HWND
    global UI_STATUS, UI_INPUTACTIVE, UI_MODAL, UI_OFFSCREEN
    Fill(g, 0, 0, UI_W, UI_H, 0, COL_BG)
    DrawSidebar(g)
    DrawTop(g)
    if (!UI_STATUS.ok && UI_PAGE != PAGE_INFO)
        DrawWaiting(g)
    else if (UI_PAGE = PAGE_RENDER)
        DrawRender(g)
    else if (UI_PAGE = PAGE_ASPECT)
        DrawAspect(g)
    else
        DrawInfo(g)
    DrawStatus(g)
    if (!UI_OFFSCREEN && UI_INPUTACTIVE && !UI_MODAL && UI_CLICK && !UI_ANYHIT && UI_MX >= S(56) && UI_MX < UI_W - S(76) && UI_MY >= 0 && UI_MY < S(46))
        UI_DragStart()
}

UI_DragStart()
{
    global UI_HWND, UI_DRAGGING, UI_DRAGX, UI_DRAGY, UI_DRAGWX, UI_DRAGWY, UI_WINX, UI_WINY
    global UI_CLICK
    VarSetCapacity(pt, 8, 0)
    DllCall("GetCursorPos", "Ptr", &pt)
    WinGetPos, wx, wy, , , ahk_id %UI_HWND%
    UI_DRAGX := NumGet(pt, 0, "Int") - wx
    UI_DRAGY := NumGet(pt, 4, "Int") - wy
    UI_DRAGWX := wx
    UI_DRAGWY := wy
    UI_CLICK := 0
    UI_DRAGGING := 1
}

UI_PageTips(g)
{
    global UI_HOT, UI_TIP, UI_MX, UI_MY, UI_TIPX, UI_TIPY, UI_MODAL
    if (UI_TIP != "" || UI_MODAL)
        return
    tip := ""
    if (UI_HOT = "##close")
        tip := TR("Скрыть окно", "Hide window")
    else if (UI_HOT = "##min")
        tip := TR("Свернуть", "Minimize")
    else if (UI_HOT = "lang")
        tip := TR("Сменить язык", "Switch language")
    if (tip = "")
        return
    UI_TIP := tip
    UI_TIPX := UI_MX
    UI_TIPY := UI_MY + S(18)
}

DrawSidebar(g)
{
    global UI_W, UI_H, UI_PAGE, UI_ICONIMG, UI_SCROLL, UI_SCROLLT, UI_LANG, UI_STATUS
    Fill(g, 0, 0, S(56), UI_H, 0, COL_SIDE)
    Margin(g)
    if (UI_ICONIMG)
        GP_DrawImage(g, UI_ICONIMG, S(14), S(14), S(28), S(28))
    else
        IconSliders(g, S(25), S(28), S(11), COL_RED)
    nav := [["sliders", PAGE_RENDER, TR("Рендер", "Rendering")], ["aperture", PAGE_ASPECT, TR("Аспект", "Aspect ratio")], ["lightbulb", PAGE_INFO, TR("Справка", "Info")]]
    for i, n in nav
    {
        cy := S(96 + (i - 1) * 52)
        id := "nav" i
        enabled := UI_STATUS.ok || n[2] = PAGE_INFO || n[2] = PAGE_RENDER
        hit := Hit(id, S(10), cy - S(22), S(36), S(44), enabled)
        hov := UI_HovGet(id)
        sel := Anim("navsel" i, UI_PAGE = n[2] ? 1.0 : 0.0, 18.0)
        m := Max(sel, hov)
        if (m > 0.004)
            Fill(g, S(13), cy - S(20), S(24), S(24), S(7), Al(sel > 0.5 ? COL_SEL : COL_FIELD, m))
        col := enabled ? Mix(COL_ICON, COL_WHITE, m) : COL_INK
        if (n[1] = "sliders")
            IconSliders(g, S(25), cy, S(11), col)
        else if (n[1] = "aperture")
            IconAperture(g, S(25), cy, S(11), col)
        else
            IconChr(g, 0xE1C2, S(25), cy, S(11), col)
        Tip(id, n[3])
        if (hit && UI_PAGE != n[2])
        {
            UI_ResetInput()
            UI_PAGE := n[2]
            UI_SCROLL := 0
            UI_SCROLLT := 0
        }
    }
    if (Hit("lang", S(10), UI_H - S(70), S(36), S(44)))
    {
        UI_LANG := UI_LANG ? 0 : 1
        UI_Act("lang")
    }
    lf := UI_HovGet("lang")
    Fill(g, S(10), UI_H - S(70), S(36), S(44), S(9), Mix(COL_SIDE, COL_FIELD, lf))
    TxtBox(g, UI_LANG ? "EN" : "RU", S(10), UI_H - S(70), S(36), S(44), Mix(COL_GRAY2, COL_WHITE, lf), 12, 1, 1)
}

Margin(g)
{
    global UI_W, UI_H
    Dash(g, S(56), 0, S(56), UI_H, COL_BORDER, S(1.2))
}

DrawTop(g)
{
    global UI_W, UI_PAGE, UI_HWND, UI_STATUS, UI_LASTTICK
    titles := [TR("Рендер", "Rendering"), TR("Аспект", "Aspect ratio"), TR("Справка", "Info")]
    subs := [TR("отключение тяжёлых проходов", "disable heavy rendering passes"), TR("соотношение сторон камеры", "camera aspect ratio"), TR("состояние и подключение", "status and connection")]
    title := !UI_STATUS.ok && UI_PAGE != PAGE_INFO ? "convars" : titles[UI_PAGE + 1]
    sub := !UI_STATUS.ok && UI_PAGE != PAGE_INFO ? TR("настройки рендера Deadlock", "Deadlock rendering settings") : subs[UI_PAGE + 1]
    TxtBox(g, title, S(72), S(6), UI_W - S(170), S(24), COL_WHITE, 17, 2)
    TxtBox(g, sub, S(72), S(32), UI_W - S(170), S(20), COL_INK, 12.5)
    res := Titlebar(g, UI_W - S(14), S(22))
    if (res = "close")
        UI_Hide()
    else if (res = "min")
    {
        UI_ResetInput()
        UI_LASTTICK := 0
        Gui, UI:Minimize
    }
}

DrawWaiting(g)
{
    global UI_W, UI_H, UI_STATUS, UI_LOGOIMG, UI_ICONIMG
    x := S(72)
    cw := UI_W - S(96)
    h := S(288)
    y := S(56) + (UI_H - S(94) - h) / 2
    Card(g, x, y, cw, h)
    cx := x + cw / 2
    cy := y + S(84)
    state := UI_STATUS.state
    connecting := state = "attaching"
    col := state = "retry" ? 0xFFD7A42B : (connecting ? 0xFF8D9097 : COL_GRAY)
    img := IsObject(UI_LOGOIMG) ? UI_LOGOIMG : UI_ICONIMG
    if (IsObject(img))
    {
        scale := Min(S(40) / img.w, S(40) / img.h)
        iw := img.w * scale
        ih := img.h * scale
        GP_DrawImage(g, img, cx - iw / 2, cy - iw / 2 + S(6), iw, ih)
    }
    else
        IconChr(g, connecting ? 0xE145 : 0xE0D1, cx, cy - S(6), S(20), col)
    title := connecting ? TR("Подключение к игре", "Connecting to game") : (state = "retry" ? TR("Не удалось подключиться", "Connection unavailable") : TR("Ожидание игры", "Waiting for game"))
    sub := connecting ? TR("Процесс найден. Подготавливаем настройки…", "Game found. Preparing your settings…") : (state = "retry" ? TR("Игра запущена, но доступ к процессу пока недоступен.", "The game is running, but process access is unavailable.") : TR("Запустите Deadlock — подключение произойдёт автоматически", "Launch Deadlock — connection is automatic"))
    note := state = "retry" ? TR("Повторим автоматически. Проверьте права доступа.", "Retrying automatically. Check access permissions.") : TR("Настройки станут доступны после подключения", "Settings will become available once connected")
    TxtBox(g, title, x + S(24), y + S(156), cw - S(48), S(30), COL_WHITE, 18, 2, 1)
    TxtBox(g, sub, x + S(24), y + S(186), cw - S(48), S(26), COL_GRAY2, 12, 0, 1)
    UI_Links(g, x + cw / 2, y + S(216), 1)
    TxtBox(g, note, x + S(24), y + S(248), cw - S(48), S(24), COL_INK, 11, 0, 1)
}

UI_FilterChanged()
{
    global UI_SCROLL, UI_SCROLLT, UI_CARET
    UI_SCROLL := 0
    UI_SCROLLT := 0
    UI_CARET := 0
}

DrawSearch(g)
{
    global UI_W, UI_SEARCH, UI_SEARCHING, UI_CARET
    x := S(72)
    y := S(56)
    w := UI_W - S(96)
    h := S(34)
    clear := UI_SEARCH != "" || UI_SEARCHING
    if (clear && Hit("searchclear", x + w - S(30), y + S(5), S(24), S(24)))
    {
        UI_SEARCH := ""
        UI_SEARCHING := 1
        UI_TypeInit()
        UI_FilterChanged()
    }
    if (Hit("search", x, y, w - (clear ? S(32) : 0), h))
    {
        if (!UI_SEARCHING)
            UI_TypeInit()
        UI_SEARCHING := 1
        UI_CARET := 0
    }
    sh := Max(UI_HovGet("search"), UI_HovGet("searchclear"))
    Fill(g, x, y, w, h, S(8), Mix(COL_FIELD, COL_FIELD_H, sh))
    if (UI_SEARCHING)
        Frame(g, x, y, w, h, S(8), COL_BORDER_H, S(1.2))
    IconSearch(g, x + S(16), y + h / 2, S(6.8), Mix(COL_ICON, COL_ICON_H, sh))
    tx := x + S(30)
    tw := w - S(66)
    TxtBox(g, UI_SEARCH = "" ? TR("Поиск по конварам…", "Search convars…") : UI_SEARCH, tx, y, tw, h, UI_SEARCH = "" ? COL_INK : COL_TEXT, 13)
    if (UI_SEARCHING && Mod(Floor(UI_CARET * 2.2), 2) = 0)
    {
        cx := tx + Min(tw - S(2), TxtW(g, UI_SEARCH, 13) + S(1))
        Dash(g, cx, y + S(8), cx, y + h - S(8), COL_GRAY2, S(1.2))
    }
    if (clear)
        IconClose(g, x + w - S(18), y + h / 2, S(4), Mix(COL_GRAY, COL_WHITE, UI_HovGet("searchclear")))
}

UI_ListScroll(total, listTop, listH, cw)
{
    global UI_SCROLL, UI_SCROLLT, UI_WHEEL, UI_DT, UI_INPUTACTIVE, UI_MODAL
    maxScroll := Max(0, total - listH)
    if (UI_INPUTACTIVE && !UI_MODAL && UI_WHEEL && InRect(S(72), listTop, cw, listH))
        UI_SCROLLT += UI_WHEEL * S(40)
    UI_WHEEL := 0
    UI_SCROLLT := Clamp(UI_SCROLLT, 0, maxScroll)
    UI_SCROLL := Clamp(UI_SCROLL + (UI_SCROLLT - UI_SCROLL) * (1 - Exp(-17 * UI_DT)), 0, maxScroll)
    if (Abs(UI_SCROLL - UI_SCROLLT) < 0.7)
        UI_SCROLL := UI_SCROLLT
    return maxScroll
}

UI_ListBar(g, id, cw, top, h, total, maxScroll)
{
    global UI_SCROLL, UI_SCROLLT, UI_HITCLIP
    UI_HITCLIP := 0
    frac := total > h ? h / total : 1
    pos := maxScroll > 0 ? UI_SCROLL / maxScroll : 0
    np := Scrollbar(g, id, S(72) + cw - S(4), top, S(4), h, frac, pos, changed)
    if (changed && maxScroll > 0)
        UI_SCROLLT := np * maxScroll
}

UI_ListRows(hotkeys)
{
    global UI_CT, UI_GRPS, UI_SEARCH, UI_LANG, UI_SCALE
    static cache := {}
    signature := hotkeys "|" UI_SEARCH "|" UI_LANG "|" UI_SCALE
    if (hotkeys)
    {
        mask := ""
        for i, cv in UI_CT
            if (cv.enabled)
                mask .= i ","
        signature .= "|" mask
    }
    if (cache.HasKey(hotkeys) && cache[hotkeys].signature = signature)
        return cache[hotkeys]
    rows := []
    total := hotkeys ? S(40) : 0
    if (hotkeys)
    {
        for i, cv in UI_CT
        {
            if ((UI_SEARCH != "" || cv.enabled) && CV_Search(cv, UI_SEARCH))
            {
                rows.Push(i)
                total += S(40)
            }
        }
    }
    else
    {
        for _, grp in UI_GRPS
        {
            matches := []
            Loop, % grp.last - grp.first + 1
            {
                idx := grp.first + A_Index - 1
                if (IsObject(UI_CT[idx]) && CV_Search(UI_CT[idx], UI_SEARCH))
                    matches.Push(idx)
            }
            if (!matches.Length())
                continue
            rows.Push({kind: 1, title: UI_GroupTitle(grp.title), n: matches.Length()})
            total += S(32)
            for _, idx in matches
            {
                rows.Push({kind: 0, idx: idx})
                total += S(40)
            }
        }
    }
    cache[hotkeys] := {signature: signature, rows: rows, total: total}
    return cache[hotkeys]
}

UI_GroupTitle(title)
{
    if (title = "Lighting and shadows")
        return TR("Освещение и тени", title)
    if (title = "Sky, fog, post")
        return TR("Небо, туман и постобработка", title)
    if (title = "Geometry and textures")
        return TR("Геометрия и текстуры", title)
    if (title = "Particles and effects")
        return TR("Частицы и эффекты", title)
    if (title = "Culling and extras")
        return TR("Отсечение и дополнительные", title)
    if (title = "Heavy passes - big FPS")
        return TR("Тяжёлые проходы — прирост FPS", title)
    if (title = "Critical")
        return TR("Критические настройки", title)
    return title
}

DrawRender(g)
{
    global UI_W, UI_H, UI_SCROLL, UI_SEARCH, UI_CT, UI_GRPS, UI_HK, UI_HITCLIP
    DrawSearch(g)
    cw := UI_W - S(96)
    top := S(100)
    h := UI_H - top - S(38)
    data := UI_ListRows(0)
    rows := data.rows
    total := data.total
    maxScroll := UI_ListScroll(total, top, h, cw)
    if (!rows.Length())
    {
        DrawEmpty(g, S(72), top + S(14), cw, TR("Ничего не найдено", "Nothing found"), TR("Попробуйте другое имя или очистите поиск", "Try another name or clear the search"))
        return
    }
    st := GP_ClipPush(g, S(72), top, cw - S(14), h)
    UI_HITCLIP := {x: S(72), y: top, w: cw - S(14), h: h}
    y := top - UI_SCROLL
    for _, row in rows
    {
        rh := row.kind = 1 ? S(32) : S(40)
        if (y + rh > top && y < top + h)
        {
            if (row.kind = 1)
            {
                TxtBox(g, row.title, S(74), y + S(2), cw - S(62), S(24), COL_GRAY, 12)
                TxtBox(g, row.n, S(72) + cw - S(52), y + S(2), S(32), S(24), COL_INK, 11.5, 0, 2)
                Dash(g, S(72), y + S(29), S(72) + cw - S(14), y + S(29), COL_BORDER, S(1))
            }
            else
            {
                cv := UI_CT[row.idx]
                act := ToggleRow(g, "cv" row.idx, S(72), y, cw - S(14), CV_Label(cv), cv.name, cv.enabled ? 1 : 0, UI_HK[row.idx], 1, CV_Tip(cv), cv.pending, (cv.failed && !cv.resolved))
                if (act = 1)
                    UI_Pick(row.idx)
                else if (act = 2)
                    UI_BeginCapture(row.idx)
                else if (act = 3)
                    UI_HK_Done(row.idx, "")
            }
        }
        y += rh
    }
    GP_ClipPop(g, st)
    UI_ListBar(g, "sb", cw, top, h, total, maxScroll)
}

DrawEmpty(g, x, y, w, title, sub)
{
    Card(g, x, y, w, S(90))
    TxtBox(g, title, x + S(20), y + S(18), w - S(40), S(26), COL_GRAY2, 13, 1, 1)
    TxtBox(g, sub, x + S(20), y + S(46), w - S(40), S(24), COL_INK, 11.5, 0, 1)
}

UI_Pick(idx)
{
    global UI_OFFSCREEN, UI_STATUS
    if (!UI_OFFSCREEN && UI_STATUS.ok && IsFunc("UI_OnToggle"))
        UI_OnToggle(idx)
}

UI_BeginCapture(idx, mode := "")
{
    global UI_CAPIDX, UI_CAPMODE, UI_SEARCHING, UI_MODAL, UI_CLICK, UI_OFFSCREEN, UI_STATUS, UI_RCLICK
    if (UI_OFFSCREEN || !UI_STATUS.ok || UI_CAPIDX >= 0)
        return
    UI_RCLICK := 0
    UI_CAPIDX := idx
    UI_CAPMODE := mode
    UI_SEARCHING := 0
    UI_MODAL := 1
    UI_CLICK := 0
    DD_Close()
    UI_KeyListInit()
    UI_Act("capture_begin")
}

UI_HK_Done(idx, k)
{
    global UI_OFFSCREEN
    if (!UI_OFFSCREEN && IsFunc("UI_OnHotkey"))
        UI_OnHotkey(idx, k)
}

DrawCapture(g)
{
    global UI_CAPIDX, UI_CAPMODE, UI_CT, UI_W, UI_H, UI_CLICK, UI_INPUTACTIVE, UI_OFFSCREEN, UI_HITCLIP
    if (UI_CAPIDX < 0)
        return
    UI_HITCLIP := 0
    Fill(g, S(56), S(48), UI_W - S(56), UI_H - S(76), 0, 0xC0101115)
    w := Min(S(440), UI_W - S(128))
    h := S(194)
    x := S(56) + (UI_W - S(56) - w) / 2
    y := (UI_H - h) / 2
    Card(g, x, y, w, h)
    name := CV_Label(UI_CT[UI_CAPIDX])
    TxtBox(g, name, x + S(24), y + S(16), w - S(48), S(22), COL_GRAY2, 12, 1, 1)
    TxtBox(g, TR("Нажмите клавишу…", "Press a key…"), x + S(24), y + S(46), w - S(48), S(32), COL_WHITE, 19, 2, 1)
    TxtBox(g, TR("Можно с Ctrl, Alt или Shift. Esc — отмена.", "Ctrl, Alt or Shift supported. Esc to cancel."), x + S(20), y + S(88), w - S(40), S(24), COL_GRAY2, 11.5, 0, 1)
    bx := x + (w - S(136)) / 2
    by := y + S(136)
    cancel := HitIn("capture_cancel", bx, by, S(136), S(34))
    hov := UI_HovGet("capture_cancel")
    Fill(g, bx, by, S(136), S(34), S(7), Mix(COL_FIELD, COL_FIELD_H, hov))
    Frame(g, bx, by, S(136), S(34), S(7), COL_BORDER_H, S(1))
    TxtBox(g, TR("Отмена", "Cancel"), bx + S(8), by, S(120), S(34), COL_TEXT, 13, 1, 1)
    if (!UI_OFFSCREEN && UI_INPUTACTIVE && (cancel || (UI_CLICK && !InRect(x, y, w, h))))
        UI_ResetInput()
    UI_CLICK := 0
}

Card(g, x, y, w, h)
{
    Fill(g, x, y, w, h, S(10), COL_GROUP)
    Frame(g, x, y, w, h, S(10), COL_BORDER, S(1.2))
}

DrawAspect(g)
{
    global UI_W, UI_H, UI_ASPITEMS, UI_CFG, UI_ASPFOCUS, UI_ASPDRAFT, UI_CARET
    x := S(72)
    cw := UI_W - S(96)
    y := S(66)
    bw := cw - S(36)
    Card(g, x, y, cw, S(84))
    TxtBox(g, TR("Аспект", "Aspect ratio"), x + S(18), y + S(14), bw, S(24), COL_TEXT, 13, 1)
    inx := x + S(18)
    iny := y + S(42)
    inw := bw
    inh := S(34)
    if (Hit("asp_input", inx, iny, inw, inh) && !UI_ASPFOCUS)
    {
        UI_ASPDRAFT := ""
        UI_ASPFOCUS := 1
        UI_ASPKeyInit()
        UI_TypeInit()
    }
    hov := UI_HovGet("asp_input")
    Fill(g, inx, iny, inw, inh, S(8), Mix(COL_FIELD, COL_FIELD_H, hov))
    if (UI_ASPFOCUS)
        Frame(g, inx, iny, inw, inh, S(8), COL_BORDER_H, S(1.2))
    txt := UI_ASPFOCUS ? UI_ASPDRAFT : (UI_CFG.aspect <= 0 ? TR("Нативный", "Native") : Format("{:.2f}", UI_CFG.aspect / 100.0))
    TxtBox(g, txt = "" ? (TR("Введите аспект…", "Enter aspect…")) : txt, inx + S(12), iny, inw - S(18), inh, UI_ASPFOCUS ? COL_TEXT : (UI_CFG.aspect <= 0 ? COL_TEXT : COL_GRAY2), 13)
    if (UI_ASPFOCUS && Mod(Floor(UI_CARET * 2.2), 2) = 0)
    {
        cx := inx + S(12) + Min(inw - S(20), TxtW(g, UI_ASPDRAFT, 13) + S(1))
        Dash(g, cx, iny + S(8), cx, iny + inh - S(8), COL_GRAY2, S(1.2))
    }
    TxtBox(g, TR("соотношение сторон камеры", "camera aspect ratio"), x + S(18), y + S(84), bw, S(20), COL_INK, 11)
}

UI_ASPKeyInit()
{
    global UI_ASPKEYS, UI_ASPKEYPREV
    for _, k in UI_ASPKEYS
        UI_ASPKEYPREV[k] := GetKeyState(k, "P") ? 1 : 0
}

UI_ASPTypeTick()
{
    global UI_ASPFOCUS, UI_ASPDRAFT, UI_ASPKEYS, UI_ASPKEYPREV
    if (!UI_ASPKEYS.MaxIndex())
        return
    for _, k in UI_ASPKEYS
    {
        d := GetKeyState(k, "P") ? 1 : 0
        p := UI_ASPKEYPREV.HasKey(k) ? UI_ASPKEYPREV[k] : 0
        if (d && !p)
        {
            if (k = "Enter" || k = "NumpadEnter")
            {
                UI_ASPKEYPREV[k] := 1
                UI_ASPFOCUS := 0
                if (UI_ASPDRAFT != "")
                    UI_Act("aspect_set")
                return
            }
            else if (k = "Backspace")
                UI_ASPDRAFT := SubStr(UI_ASPDRAFT, 1, -1)
            else if (k = "Delete")
                UI_ASPDRAFT := ""
            else if (StrLen(UI_ASPDRAFT) < 5)
            {
                digit := InStr(k, "Numpad") = 1 ? SubStr(k, 7) : k
                UI_ASPDRAFT .= digit
            }
            UI_ASPKEYPREV[k] := 1
        }
        else if (!d)
            UI_ASPKEYPREV[k] := 0
    }
}

DrawHotkeys(g)
{
    global UI_W, UI_H, UI_CT, UI_HK, UI_SCROLL, UI_SEARCH, UI_HITCLIP
    DrawSearch(g)
    cw := UI_W - S(96)
    top := S(100)
    h := UI_H - top - S(38)
    data := UI_ListRows(1)
    rows := data.rows
    total := data.total
    maxScroll := UI_ListScroll(total, top, h, cw)
    st := GP_ClipPush(g, S(72), top, cw - S(14), h)
    UI_HITCLIP := {x: S(72), y: top, w: cw - S(14), h: h}
    y := top - UI_SCROLL
    TxtBox(g, UI_HotkeyTip(), S(74), y + S(4), cw - S(18), S(28), COL_INK, 12)
    y += S(40)
    for _, i in rows
    {
        cv := UI_CT[i]
        if (y + S(40) > top && y < top + h)
        {
            act := ToggleRow(g, "hkr" i, S(72), y, cw - S(14), CV_Label(cv), cv.name, cv.enabled ? 1 : 0, UI_HK[i], 1, CV_Tip(cv), cv.pending, (cv.failed && !cv.resolved))
            if (act = 2)
                UI_BeginCapture(i)
            else if (act = 1)
                UI_Pick(i)
            else if (act = 3)
                UI_HK_Done(i, "")
        }
        y += S(40)
    }
    if (!rows.Length())
        DrawEmpty(g, S(72), top + S(48), cw - S(14), UI_SEARCH != "" ? TR("Ничего не найдено", "Nothing found") : TR("Нет включённых конваров", "No convars enabled yet"), UI_SEARCH != "" ? TR("Попробуйте другое имя или очистите поиск", "Try another name or clear the search") : TR("Включите настройку на странице рендера или найдите её в поиске", "Enable a setting on the Rendering page or find it in search"))
    GP_ClipPop(g, st)
    UI_ListBar(g, "sb_hk", cw, top, h, total, maxScroll)
}

DrawInfo(g)
{
    global UI_W, UI_H, UI_STATUS, UI_CT, UI_CFG, UI_TIME
    x := S(72)
    cw := UI_W - S(96)
    y := S(66)
    Card(g, x, y, cw, S(86))
    connected := UI_STATUS.ok
    pulse := 0.5 + 0.5 * Sin(UI_TIME * 2.2)
    if (connected)
    {
        Ring(g, x + S(34), y + S(43), S(15), Al(0xFF3FB950, 0.12 + pulse * 0.18), S(2))
        Ring(g, x + S(34), y + S(43), S(10), Al(0xFF3FB950, 0.25 + pulse * 0.25), S(1))
        Dot(g, x + S(34), y + S(43), S(6), 0xFF3FB950)
        Dot(g, x + S(34), y + S(43), S(14), Al(0xFF3FB950, 0.20 + pulse * 0.20))
    }
    else
    {
        Ring(g, x + S(34), y + S(43), S(14), Al(COL_GRAY, 0.18), S(1.5))
        Dot(g, x + S(34), y + S(43), S(6), COL_GRAY)
        Dot(g, x + S(34), y + S(43), S(10), Al(COL_GRAY, 0.15 + pulse * 0.15))
    }
    TxtBox(g, UI_STATUS.title, x + S(60), y + S(16), cw - S(78), S(26), connected ? COL_WHITE : COL_GRAY2, 15, 2)
    TxtBox(g, UI_STATUS.sub, x + S(60), y + S(44), cw - S(78), S(24), COL_INK, 12)
    y += S(102)
    Card(g, x, y, cw, S(188))
    TxtBox(g, TR("Диагностика", "Diagnostics"), x + S(18), y + S(12), cw - S(36), S(24), COL_TEXT, 13, 1)
    lines := []
    lines.Push([TR("Разрешено адресов (по запросу)", "Addresses resolved (on demand)"), UI_STATUS.resolved " / " UI_CT.Length()])
    lines.Push([TR("Процесс", "Process"), UI_STATUS.pid ? ("deadlock.exe (pid " UI_STATUS.pid ")") : TR("не запущен", "not running")])
    lines.Push([TR("Аспект", "Aspect ratio"), UI_CFG.aspect <= 0 ? TR("нативный", "native") : Format("{:.2f}", UI_CFG.aspect / 100.0)])
    lines.Push([TR("Хоткей окна", "Window hotkey"), UI_CFG.key_gui])
    for i, ln in lines
    {
        ly := y + S(44) + (i - 1) * S(26)
        TxtBox(g, ln[1], x + S(18), ly, (cw - S(52)) / 2, S(24), COL_GRAY2, 12)
        TxtBox(g, ln[2], x + cw / 2, ly, cw / 2 - S(18), S(24), COL_TEXT, 12, 1, 2)
    }
    y += S(204)
    if (GhostButton(g, "open_settings", x, y, S(196), S(34), TR("Открыть settings.json", "Open settings.json")))
        UI_Act("open_settings")
    if (GhostButton(g, "reload", x + S(206), y, S(120), S(34), TR("Перезапуск", "Reload")))
        UI_Act("reload")
    if (GhostButton(g, "exit", x + S(336), y, S(120), S(34), TR("Выход", "Exit")))
        UI_Act("exit")
    ly := y + S(44)
    note := TR("Все значения возвращаются при выходе", "All values are restored on exit")
    nw := TxtW(g, note, 11.5)
    TxtBox(g, note, x, ly, Min(nw + S(6), cw - S(240)), S(24), COL_INK, 11.5)
    UI_Links(g, x + Min(nw + S(6), cw - S(240)), ly)
}

UI_Links(g, lx, ly, center := 0)
{
    tips := TR("Поддержка", "Support")
    tgW := TxtW(g, "dysonbehind", 12)
    tpsW := TxtW(g, tips, 12)
    if (center)
        lx -= (tgW + S(14) + tpsW) / 2
    tgH := UI_HovGet("##open_tg")
    if (Hit("##open_tg", lx, ly, tgW + S(16), S(24)))
        UI_Act("open_tg")
    TxtV(g, "dysonbehind", lx + S(8), ly + S(12), Mix(COL_GRAY2, COL_WHITE, tgH), 12)
    if (tgH)
        Dash(g, lx + S(8), ly + S(20), lx + S(8) + tgW, ly + S(20), Mix(COL_GRAY2, COL_WHITE, tgH), S(1))
    lx += tgW + S(14)
    tpsH := UI_HovGet("##open_tips")
    if (Hit("##open_tips", lx, ly, tpsW + S(16), S(24)))
        UI_Act("open_tips")
    TxtV(g, tips, lx + S(8), ly + S(12), Mix(COL_GRAY2, COL_WHITE, tpsH), 12)
    if (tpsH)
        Dash(g, lx + S(8), ly + S(20), lx + S(8) + tpsW, ly + S(20), Mix(COL_GRAY2, COL_WHITE, tpsH), S(1))
}

DrawStatus(g)
{
    global UI_W, UI_H, UI_STATUS
    y := UI_H - S(28)
    Fill(g, S(56), y, UI_W - S(56), S(28), 0, COL_SIDE)
    Dash(g, S(56), y, UI_W, y, COL_BORDER, S(1.2))
    Dot(g, S(74), y + S(14), S(3.4), UI_STATUS.ok ? 0xFF3FB950 : (UI_STATUS.state = "retry" ? 0xFFD7A42B : COL_GRAY))
    w := UI_W - S(110)
    hasMiss := UI_STATUS.miss != ""
    TxtBox(g, UI_STATUS.title, S(86), y, hasMiss ? w * 0.58 : w, S(28), COL_GRAY, 11.5)
    if (hasMiss)
        TxtBox(g, UI_STATUS.miss, S(86) + w * 0.60, y, w * 0.40, S(28), 0xFFD7A42B, 11.5, 0, 2)
}

UI_Notify(text)
{
    global UI_TOAST, UI_TOASTUNTIL, UI_TIME, UI_OFFSCREEN
    if (UI_OFFSCREEN)
        return
    UI_TOAST := text
    UI_TOASTUNTIL := UI_TIME + 4.5
}

DrawToast(g)
{
    global UI_TOAST, UI_TOASTUNTIL, UI_TIME, UI_W, UI_H
    if (UI_TOAST = "" || UI_TIME >= UI_TOASTUNTIL)
        return
    x := S(88)
    w := UI_W - S(128)
    y := UI_H - S(88)
    Fill(g, x, y, w, S(42), S(8), 0xFF282126)
    Frame(g, x, y, w, S(42), S(8), Al(COL_RED, 0.65), S(1))
    TxtBox(g, UI_TOAST, x + S(14), y, w - S(28), S(42), COL_TEXT, 12, 0, 1)
}

UI_Act(name)
{
    global UI_OFFSCREEN
    if (!UI_OFFSCREEN && IsFunc("UI_OnAction"))
        UI_OnAction(name)
}
