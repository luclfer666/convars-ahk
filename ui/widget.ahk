#NoEnv

global UI_MX := 0
global UI_MY := 0
global UI_LMB := 0
global UI_CLICK := 0
global UI_RMB := 0
global UI_RCLICK := 0
global UI_ANYHIT := 0
global UI_HOV := {}
global UI_HOT := ""
global UI_MODAL := 0
global UI_INPUTACTIVE := 0
global UI_HITCLIP := 0
global UI_TIP := ""
global UI_TIPX := 0
global UI_TIPY := 0
global UI_TIPID := ""
global UI_TIPSTART := 0
global UI_DRAGOFFSET := 0
global UI_KEYS := []
global UI_KEYPREV := {}
global UI_TYPEKEYS := []
global UI_TYPEPREV := {}

UI_HovGet(id)
{
    global UI_HOV
    return UI_HOV.HasKey(id) ? UI_HOV[id] : 0
}

InRect(x, y, w, h)
{
    global UI_MX, UI_MY
    return (UI_MX >= x && UI_MX < x + w && UI_MY >= y && UI_MY < y + h) ? 1 : 0
}

Hit(id, x, y, w, h, enabled := 1)
{
    global UI_CLICK, UI_ANYHIT, UI_HOV, UI_MODAL, UI_HOT, UI_INPUTACTIVE, UI_HITCLIP
    inside := (enabled && UI_INPUTACTIVE && !UI_MODAL && InRect(x, y, w, h)) ? 1 : 0
    if (inside && IsObject(UI_HITCLIP))
        inside := InRect(UI_HITCLIP.x, UI_HITCLIP.y, UI_HITCLIP.w, UI_HITCLIP.h)
    if (inside)
    {
        UI_ANYHIT := 1
        UI_HOT := id
    }
    UI_HOV[id] := Anim("h_" id, inside ? 1.0 : 0.0)
    if (inside && UI_CLICK)
    {
        UI_CLICK := 0
        return 1
    }
    return 0
}

HitRight(id, x, y, w, h, enabled := 1)
{
    global UI_RCLICK, UI_INPUTACTIVE, UI_MODAL, UI_HITCLIP, UI_OFFSCREEN
    if (!enabled || !UI_RCLICK || !UI_INPUTACTIVE || UI_MODAL || UI_OFFSCREEN || !InRect(x, y, w, h))
        return 0
    if (IsObject(UI_HITCLIP) && !InRect(UI_HITCLIP.x, UI_HITCLIP.y, UI_HITCLIP.w, UI_HITCLIP.h))
        return 0
    UI_RCLICK := 0
    return 1
}

HitIn(id, x, y, w, h)
{
    global UI_CLICK, UI_ANYHIT, UI_HOV, UI_HOT, UI_INPUTACTIVE
    inside := (UI_INPUTACTIVE && InRect(x, y, w, h)) ? 1 : 0
    if (inside)
    {
        UI_ANYHIT := 1
        UI_HOT := id
    }
    UI_HOV[id] := Anim("h_" id, inside ? 1.0 : 0.0)
    if (inside && UI_CLICK)
    {
        UI_CLICK := 0
        return 1
    }
    return 0
}

Tip(id, text)
{
    global UI_TIP, UI_TIPX, UI_TIPY, UI_MX, UI_MY, UI_HOT, UI_INPUTACTIVE
    if (UI_INPUTACTIVE && UI_HOT = id && UI_HovGet(id) > 0.05)
    {
        UI_TIP := text
        UI_TIPX := UI_MX
        UI_TIPY := UI_MY + S(18)
    }
}

Clamp(v, lo, hi)
{
    if (v < lo)
        return lo
    if (v > hi)
        return hi
    return v
}

UI_Hand()
{
    global UI_HOT
    if (UI_HOT != "")
        DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32649, "Ptr"))
}

Lerp(a, b, t)
{
    return a + (b - a) * t
}

Switch(g, x, y, on, hov)
{
    tw := S(34)
    th := S(19)
    Fill(g, x, y, tw, th, th / 2, Mix(Mix(COL_FIELD, COL_FIELD_H, hov), COL_RED, on))
    if (on < 0.5)
        Frame(g, x, y, tw, th, th / 2, Mix(COL_BORDER, COL_BORDER_H, hov), S(1.2))
    Dot(g, x + th / 2 + (tw - th) * on, y + th / 2, th / 2 - S(2.6), Mix(COL_GRAY2, COL_WHITE, Max(on, hov)))
}

ToggleRow(g, id, x, y, w, tag, name, enabled, hk, showSwitch := 1, description := "", pending := 0, fail := 0)
{
    global UI_HOT
    act := 0
    rh := S(40)
    swW := S(34)
    swX := x + w - swW - S(12)
    badge := hk != "" ? hk : "—"
    bw := Clamp(TxtW(g, badge, 11.5, 1) + S(16), S(54), S(104))
    bx := swX - S(12) - bw
    if (Hit(id "_hk", bx, y + S(9), bw, S(22)))
        act := 2
    right := HitRight(id "_hk", bx, y + S(9), bw, S(22))
    childHot := UI_HOT = id "_hk" ? UI_HOT : ""
    if (showSwitch && Hit(id "_sw", swX, y + S(10.5), swW, S(19)))
        act := 1
    if (UI_HOT = id "_sw")
        childHot := UI_HOT
    if (Hit(id, x, y, w, rh))
        act := 1
    if (childHot != "")
        UI_HOT := childHot
    if (right)
        act := hk != "" ? 3 : 0
    hov := UI_HovGet(id)
    if (hov > 0.004)
        Fill(g, x, y, w, rh, S(7), Al(COL_ROW, hov * (enabled ? 1.0 : 0.8)))
    bhov := UI_HovGet(id "_hk")
    Fill(g, bx, y + S(9), bw, S(22), S(5), Mix(COL_GROUP, COL_FIELD_H, bhov))
    Frame(g, bx, y + S(9), bw, S(22), S(5), Mix(COL_BORDER, COL_BORDER_H, bhov), S(1.1))
    TxtBox(g, badge, bx + S(4), y + S(9), bw - S(8), S(22), Mix(COL_GRAY2, COL_WHITE, bhov), 11.5, 1, 1)
    col := enabled ? COL_WHITE : Mix(COL_TEXT, COL_WHITE, hov)
    tx := x + S(12)
    textW := Max(0, bx - S(10) - tx)
    TxtBox(g, tag, tx, y + (name != "" ? S(1) : 0), textW, name != "" ? S(22) : rh, col, 13.5, 1)
    if (name != "")
        TxtBox(g, name, tx, y + S(22), textW, S(16), Mix(COL_INK, COL_GRAY2, hov), 10.5)
    if (pending)
    {
        Fill(g, swX, y + S(10.5), swW, S(19), S(9.5), Al(COL_WHITE, 0.18))
        Ring(g, swX + swW / 2, y + rh / 2, S(6.0), Al(COL_WHITE, 0.90), S(1.4))
        Tip(id "_sw", UI_PendingText())
    }
    else if (fail)
    {
        Fill(g, swX, y + S(10.5), swW, S(19), S(9.5), Al(COL_RED, 0.20))
        Ring(g, swX + swW / 2, y + rh / 2, S(6.0), Al(COL_RED, 0.95), S(1.4))
        Tip(id "_sw", TR("не удалось найти в памяти игры", "could not be found in game memory"))
    }
    else if (showSwitch)
        Switch(g, swX, y + S(10.5), enabled, UI_HovGet(id "_sw"))
    else
        TxtBox(g, enabled ? TR("вкл", "on") : TR("выкл", "off"), swX, y, swW, rh, enabled ? 0xFF3FB950 : COL_INK, 11.5, 0, 2)
    detail := tag (name != "" ? "`n" name : "") (description != "" ? "`n`n" description : "")
    if (pending)
        detail .= "`n`n" UI_PendingText()
    Tip(id, detail)
    if (!pending)
        Tip(id "_sw", detail)
    Tip(id "_hk", (hk != "" ? hk "`n" : "") UI_HotkeyTip())
    return act
}

RedButton(g, id, x, y, w, h, label, css := 14, disabled := 0)
{
    c := Hit(id, x, y, w, h, disabled ? 0 : 1)
    hov := disabled ? 0 : UI_HovGet(id)
    Fill(g, x, y, w, h, S(8), disabled ? COL_FIELD : Mix(COL_RED, COL_RED_H, hov))
    TxtBox(g, label, x + S(8), y, Max(0, w - S(16)), h, disabled ? COL_INK : COL_WHITE, css, 1, 1)
    return c
}

GhostButton(g, id, x, y, w, h, label, css := 13)
{
    c := Hit(id, x, y, w, h)
    hov := UI_HovGet(id)
    Fill(g, x, y, w, h, S(7), Mix(COL_GROUP, COL_FIELD_H, hov))
    Frame(g, x, y, w, h, S(7), Mix(COL_BORDER, COL_BORDER_H, hov), S(1.2))
    TxtBox(g, label, x + S(8), y, Max(0, w - S(16)), h, Mix(COL_GRAY2, COL_WHITE, hov), css, 0, 1)
    return c
}

IconButton(g, id, x, y, w, h, icon, active := -1)
{
    c := Hit(id, x, y, w, h)
    hov := UI_HovGet(id)
    if (active >= 0)
        hov := Max(hov, active)
    cx := x + w / 2
    cy := y + h / 2
    col := Mix(COL_ICON, COL_WHITE, hov)
    if (icon = "close")
        IconClose(g, cx, cy, S(4.6), col)
    else if (icon = "min")
        IconMin(g, cx, cy, S(5.0), col)
    else if (icon = "gear")
        IconGear(g, cx, cy, S(6.4), col, COL_SIDE)
    else if (icon = "search")
        IconSearch(g, cx, cy, S(6.6), col)
    else if (icon = "sliders")
        IconSliders(g, cx, cy, S(6.6), col)
    else if (icon = "sun")
        IconSun(g, cx, cy, S(6.6), col)
    else if (icon = "snow")
        IconSnowflake(g, cx, cy, S(6.8), col)
    else if (icon = "cloud")
        IconCloud(g, cx, cy, S(6.8), col)
    else if (icon = "cube")
        IconCube(g, cx, cy, S(6.4), col)
    else if (icon = "spark")
        IconSpark(g, cx, cy, S(4.2), col)
    else if (icon = "target")
        IconTarget(g, cx, cy, S(6.2), col)
    else if (icon = "bolt")
        IconBolt(g, cx, cy, S(4.4), col)
    else if (icon = "warn")
        IconWarn(g, cx, cy, S(6.2), col)
    else if (icon = "aperture")
        IconAperture(g, cx, cy, S(4.4), col)
    else if (icon = "hash")
        IconHash(g, cx, cy, S(4.2), col)
    else if (icon = "power")
        IconPower(g, cx, cy, S(6.2), col)
    else if (icon = "refresh")
        IconRefresh(g, cx, cy, S(6.2), col)
    else if (icon = "chevron")
        IconChevron(g, cx, cy, S(3.2), col, 0)
    return c
}

Titlebar(g, cxR, cy)
{
    res := ""
    btnS := S(30)
    cyc := cy + S(4)
    closeX := cxR - btnS - S(0)
    minX := closeX - btnS - S(0)
    if (Hit("##min", minX, cyc - btnS / 2, btnS, btnS))
        res := "min"
    IconMin(g, minX + btnS / 2, cyc, S(8.5), Mix(COL_ICON, COL_WHITE, UI_HovGet("##min")))
    Tip("##min", TR("Свернуть", "Minimize"))
    if (Hit("##close", closeX, cyc - btnS / 2, btnS, btnS))
        res := "close"
    IconClose(g, closeX + btnS / 2, cyc, S(8.5), Mix(COL_ICON, COL_WHITE, UI_HovGet("##close")))
    Tip("##close", TR("Закрыть окно", "Close window"))
    return res
}

DD_Draw(g)
{
    global UI_DD, UI_CLICK, UI_ANYHIT, UI_MX, UI_MY, UI_INPUTACTIVE
    if (!IsObject(UI_DD))
        return -1
    esc := GetKeyState("Escape", "P") ? 1 : 0
    cancel := UI_INPUTACTIVE && esc && !UI_DD.escPrev
    UI_DD.escPrev := esc
    if (cancel)
    {
        UI_CLICK := 0
        return -2
    }
    items := UI_DD.items
    n := items.MaxIndex()
    if (!n)
        return -1
    ih := S(30)
    pad := S(4)
    h := n * ih + pad * 2
    x := UI_DD.x
    w := UI_DD.w
    y := UI_DD.y
    if (y + h > UI_DD.limit)
        y := UI_DD.limit - h
    if (y < S(52))
        y := S(52)
    Fill(g, x, y, w, h, S(8), 0xFF16181C)
    Frame(g, x, y, w, h, S(8), COL_BORDER, S(1.2))
    if (UI_INPUTACTIVE && InRect(x, y, w, h))
        UI_ANYHIT := 1
    sel := -1
    fresh := UI_DD.fresh
    UI_DD.fresh := 0
    for i, it in items
    {
        iy := y + pad + (i - 1) * ih
        id := "dd_" UI_DD.id "_" i
        if (!fresh && HitIn(id, x + pad, iy, w - pad * 2, ih))
            sel := i
        hov := UI_HovGet(id)
        if (hov > 0.004 || UI_DD.cur = i)
            Fill(g, x + pad, iy, w - pad * 2, ih, S(6), 0xFF22252B)
        TxtBox(g, it.label, x + pad + S(12), iy, Max(0, w - pad * 2 - S(24)), ih, (UI_DD.cur = i) ? COL_WHITE : COL_TEXT, 13.5)
        Tip(id, it.label)
    }
    if (!fresh && UI_INPUTACTIVE && UI_CLICK && !InRect(x, y, w, h))
    {
        UI_CLICK := 0
        return -2
    }
    return sel
}

DD_Open(id, x, y, w, items, cur, limit, btn := 0)
{
    global UI_DD
    UI_DD := { id: id, x: x, y: y, w: w, items: items, cur: cur, limit: limit, btn: btn, fresh: 1, escPrev: GetKeyState("Escape", "P") ? 1 : 0 }
}

DD_Close()
{
    global UI_DD
    UI_DD := 0
}

DD_IsOpen(id)
{
    global UI_DD
    return (IsObject(UI_DD) && UI_DD.id = id) ? 1 : 0
}

DD_Apply(sel)
{
    global UI_DD
    if (!IsObject(UI_DD))
        return
    id := UI_DD.id
    items := UI_DD.items
    if (sel = -2)
        DD_Close()
    else if (sel > 0 && sel <= items.MaxIndex())
    {
        if (IsFunc("UI_OnPick"))
            UI_OnPick(id, items[sel].val, items[sel].label)
        DD_Close()
    }
}

DDButton(g, id, x, y, w, h, label, css := 13.5)
{
    c := Hit(id, x, y, w, h)
    hov := UI_HovGet(id)
    open := DD_IsOpen(id)
    Fill(g, x, y, w, h, S(7), Mix(COL_GROUP, COL_FIELD_H, Max(hov, open ? 0.6 : 0)))
    Frame(g, x, y, w, h, S(7), Mix(COL_BORDER, COL_BORDER_H, Max(hov, open ? 1 : 0)), S(1.2))
    TxtBox(g, label, x + S(12), y, Max(0, w - S(38)), h, Mix(COL_TEXT, COL_WHITE, hov), css)
    Tip(id, label)
    IconChevron(g, x + w - S(13), y + h / 2 + S(1), S(3.2), Mix(COL_GRAY2, COL_WHITE, hov), open)
    return c
}

Scrollbar(g, id, x, y, w, h, frac, pos, ByRef changed := 0)
{
    global UI_DRAGID, UI_DRAGOFFSET, UI_LMB, UI_MY, UI_INPUTACTIVE, UI_MODAL
    changed := 0
    if (UI_DRAGID = id && (!UI_INPUTACTIVE || UI_MODAL || !UI_LMB))
        UI_DRAGID := ""
    if (frac >= 0.999 || h <= 0)
    {
        if (UI_DRAGID = id)
            UI_DRAGID := ""
        return pos
    }
    th := Min(h, Max(S(28), h * Max(0, frac)))
    travel := h - th
    oldPos := pos
    interacted := 0
    ty := y + travel * Clamp(pos, 0, 1)
    if (Hit(id, x - S(6), y, w + S(12), h))
    {
        interacted := 1
        UI_DRAGID := id
        if (UI_MY >= ty && UI_MY < ty + th)
            UI_DRAGOFFSET := UI_MY - ty
        else
        {
            UI_DRAGOFFSET := th / 2
            pos := travel > 0 ? (UI_MY - UI_DRAGOFFSET - y) / travel : 0
        }
    }
    if (UI_DRAGID = id && UI_LMB && UI_INPUTACTIVE && !UI_MODAL)
    {
        interacted := 1
        pos := travel > 0 ? (UI_MY - UI_DRAGOFFSET - y) / travel : 0
    }
    pos := Clamp(pos, 0, 1)
    changed := (interacted && Abs(pos - oldPos) > 0.000001) ? 1 : 0
    ty := y + travel * pos
    a := Max(UI_HovGet(id), (UI_DRAGID = id) ? 1 : 0)
    Fill(g, x, ty, w, th, w / 2, a > 0.99 ? COL_SB_A : (a > 0.01 ? COL_SB_H : COL_SB))
    return pos
}

Tip_Draw(g)
{
    global UI_TIP, UI_TIPX, UI_TIPY
    if (UI_TIP = "")
        return
    pad := S(10)
    margin := S(6)
    tw := Min(S(440), UI_W - margin * 2)
    maxH := UI_H - margin * 2
    plain := TxtMeasure(g, UI_TIP, 12)
    tw := Min(tw, Max(S(120), plain.w + pad * 2))
    size := TxtMeasure(g, UI_TIP, 12, 0, tw - pad * 2, maxH - pad * 2, 1)
    th := Min(maxH, Ceil(size.h) + pad * 2)
    tx := Clamp(UI_TIPX + S(14), margin, UI_W - tw - margin)
    ty := Clamp(UI_TIPY, margin, UI_H - th - margin)
    Fill(g, tx, ty, tw, th, S(6), 0xFF1C1F24)
    Frame(g, tx, ty, tw, th, S(6), COL_BORDER, S(1.1))
    GP_TextRect(g, UI_TIP, tx + pad, ty + pad, tw - pad * 2, th - pad * 2, COL_TEXT, Fnt(12), 0, 1)
}

UI_KeyListInit()
{
    global UI_KEYS, UI_KEYPREV
    UI_KEYS := ["F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12"
        , "Insert", "Delete", "Home", "End", "PgUp", "PgDn", "Up", "Down", "Left", "Right", "Tab"
        , "Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5", "Numpad6", "Numpad7", "Numpad8", "Numpad9", "NumpadDot", "NumpadDiv", "NumpadMult", "NumpadAdd", "NumpadSub"
        , "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    UI_KEYPREV := {}
    for i, k in UI_KEYS
        UI_KEYPREV[k] := GetKeyState(k, "P") ? 1 : 0
}

UI_TypeInit()
{
    global UI_CARET
    UI_CARET := 0
}

UI_OnChar(wParam, lParam, msg, hwnd)
{
    global UI_HWND, UI_VISIBLE, UI_INPUTACTIVE, UI_OFFSCREEN, UI_STATUS, UI_PAGE
    global UI_SEARCHING, UI_SEARCH, UI_DD, UI_CAPIDX, UI_MODAL
    if (hwnd != UI_HWND || !UI_VISIBLE || UI_OFFSCREEN || !UI_INPUTACTIVE)
        return
    if (DllCall("GetForegroundWindow", "Ptr") != UI_HWND || DllCall("IsIconic", "Ptr", UI_HWND))
        return
    if (!UI_STATUS.ok || UI_MODAL || IsObject(UI_DD) || UI_CAPIDX >= 0)
        return
    if (GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P"))
        return
    if (wParam = 27)
    {
        UI_SEARCHING := 0
        return 0
    }
    if (UI_SEARCHING && UI_PAGE = PAGE_RENDER)
    {
        text := UI_SEARCH
        if (wParam = 8)
            text := SubStr(text, 1, -1)
        else if (wParam >= 32 && wParam != 127 && StrLen(text) < 96)
            text .= Chr(wParam)
        if (text != UI_SEARCH)
        {
            UI_SEARCH := text
            UI_FilterChanged()
        }
    }
    return 0
}

UI_CaptureTick()
{
    global UI_KEYS, UI_KEYPREV, UI_INPUTACTIVE
    if (!UI_KEYS.MaxIndex())
        UI_KeyListInit()
    if (!UI_INPUTACTIVE)
    {
        for i, k in UI_KEYS
            UI_KEYPREV[k] := GetKeyState(k, "P") ? 1 : 0
        return ""
    }
    if (GetKeyState("Escape", "P"))
        return "__cancel__"
    for i, k in UI_KEYS
    {
        d := GetKeyState(k, "P") ? 1 : 0
        if (d && !UI_KEYPREV[k])
        {
            UI_KEYPREV[k] := 1
            mods := ""
            if (GetKeyState("Ctrl", "P"))
                mods .= "^"
            if (GetKeyState("Alt", "P"))
                mods .= "!"
            if (GetKeyState("Shift", "P"))
                mods .= "+"
            return mods . k
        }
        UI_KEYPREV[k] := d
    }
    return ""
}