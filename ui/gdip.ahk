#NoEnv

global GP_Token := 0
global GP_Ready := 0
global GP_UnitPixel := 2

GP_Startup()
{
    global GP_Token, GP_Ready
    if (GP_Ready)
        return true
    if (!DllCall("GetModuleHandle", "Str", "gdiplus.dll", "Ptr"))
        DllCall("LoadLibrary", "Str", "gdiplus.dll", "Ptr")
    VarSetCapacity(si, 24, 0)
    NumPut(1, si, 0, "UInt")
    t := 0
    if (DllCall("gdiplus\GdiplusStartup", "Ptr*", t, "Ptr", &si, "Ptr", 0) != 0)
        return false
    GP_Token := t
    GP_Ready := 1
    return true
}

GP_Shutdown()
{
    global GP_Token, GP_Ready
    if (!GP_Ready)
        return
    DllCall("gdiplus\GdiplusShutdown", "Ptr", GP_Token)
    GP_Ready := 0
}

GP_Log(logObj, msg)
{
    if (IsObject(logObj))
        logObj.Call(msg)
}

GP_FamilyName(fam)
{
    VarSetCapacity(nm, 256, 0)
    DllCall("gdiplus\GdipGetFamilyName", "Ptr", fam, "Ptr", &nm, "Int", 0)
    return StrGet(&nm, "UTF-16")
}

GP_LoadFamily(fontDir, wantName, logObj := 0)
{
    pfc := 0
    if (DllCall("gdiplus\GdipNewPrivateFontCollection", "Ptr*", pfc) != 0 || !pfc)
    {
        GP_Log(logObj, "ui: private font collection failed")
        return 0
    }
    Loop, %fontDir%\*.ttf
        DllCall("gdiplus\GdipPrivateAddFontFile", "Ptr", pfc, "WStr", A_LoopFileFullPath)
    Loop, %fontDir%\*.otf
        DllCall("gdiplus\GdipPrivateAddFontFile", "Ptr", pfc, "WStr", A_LoopFileFullPath)
    n := 0
    DllCall("gdiplus\GdipGetFontCollectionFamilyCount", "Ptr", pfc, "Int*", n)
    if (n <= 0)
    {
        GP_Log(logObj, "ui: no families in " fontDir)
        return 0
    }
    VarSetCapacity(list, 8 * n, 0)
    found := 0
    DllCall("gdiplus\GdipGetFontCollectionFamilyList", "Ptr", pfc, "Int", n, "Ptr", &list, "Int*", found)
    first := 0, exact := 0
    Loop, %found%
    {
        fam := NumGet(list, (A_Index - 1) * 8, "Ptr")
        if (!first)
            first := fam
        if (GP_FamilyName(fam) = wantName && !exact)
            exact := fam
    }
    if (!exact)
    {
        Loop, %found%
        {
            fam := NumGet(list, (A_Index - 1) * 8, "Ptr")
            if (InStr(GP_FamilyName(fam), wantName) && !exact)
                exact := fam
        }
    }
    picked := exact ? exact : first
    GP_Log(logObj, "ui: font family '" GP_FamilyName(picked) "' from " fontDir)
    return picked
}

GP_SysFamily(name)
{
    fam := 0
    if (DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", name, "Ptr", 0, "Ptr*", fam) != 0)
        return 0
    return fam
}

GP_FamilyFromFile(path)
{
    pfc := 0
    if (!FileExist(path))
        return 0
    if (DllCall("gdiplus\GdipNewPrivateFontCollection", "Ptr*", pfc) != 0 || !pfc)
        return 0
    if (DllCall("gdiplus\GdipPrivateAddFontFile", "Ptr", pfc, "WStr", path) != 0)
        return 0
    n := 0
    DllCall("gdiplus\GdipGetFontCollectionFamilyCount", "Ptr", pfc, "Int*", n)
    if (n <= 0)
        return 0
    VarSetCapacity(list, 8 * n, 0)
    found := 0
    DllCall("gdiplus\GdipGetFontCollectionFamilyList", "Ptr", pfc, "Int", n, "Ptr", &list, "Int*", found)
    if (found <= 0)
        return 0
    return NumGet(list, 0, "Ptr")
}

GP_Font(fam, size, style := 0, unit := 2)
{
    fnt := 0
    if (DllCall("gdiplus\GdipCreateFont", "Ptr", fam, "Float", size, "Int", style, "Int", unit, "Ptr*", fnt) != 0)
        return 0
    return fnt
}

GP_FreeFont(f)
{
    if (f)
        DllCall("gdiplus\GdipDeleteFont", "Ptr", f)
}

GP_Backbuffer(w, h, clearColor := 0xFF101115)
{
    global GP_UnitPixel
    hdcScr := DllCall("GetDC", "Ptr", 0, "Ptr")
    VarSetCapacity(bmi, 40, 0)
    NumPut(40, bmi, 0, "UInt")
    NumPut(w, bmi, 4, "Int")
    NumPut(-h, bmi, 8, "Int")
    NumPut(1, bmi, 12, "UShort")
    NumPut(32, bmi, 14, "UShort")
    NumPut(0, bmi, 16, "UInt")
    NumPut(w * h * 4, bmi, 20, "UInt")
    bits := 0
    hbm := DllCall("CreateDIBSection", "Ptr", hdcScr, "Ptr", &bmi, "UInt", 0, "Ptr*", bits, "Ptr", 0, "UInt", 0, "Ptr")
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdcScr)
    memdc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
    oldbm := DllCall("SelectObject", "Ptr", memdc, "Ptr", hbm, "Ptr")
    bmp := 0, g := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", w, "Int", h, "Int", w * 4, "Int", 0x0026200A, "Ptr", bits, "Ptr*", bmp)
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", bmp, "Ptr*", g)
    DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipSetInterpolationMode", "Ptr", g, "Int", 7)
    DllCall("gdiplus\GdipSetCompositingQuality", "Ptr", g, "Int", 2)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipGraphicsClear", "Ptr", g, "UInt", clearColor)
    return { hbm: hbm, memdc: memdc, oldbm: oldbm, bmp: bmp, g: g, bits: bits, w: w, h: h }
}

GP_FreeBackbuffer(bc)
{
    if (bc.g)
        DllCall("gdiplus\GdipDeleteGraphics", "Ptr", bc.g)
    if (bc.bmp)
        DllCall("gdiplus\GdipDisposeImage", "Ptr", bc.bmp)
    if (bc.memdc && bc.oldbm)
        DllCall("SelectObject", "Ptr", bc.memdc, "Ptr", bc.oldbm, "Ptr")
    if (bc.hbm)
        DllCall("DeleteObject", "Ptr", bc.hbm)
    if (bc.memdc)
        DllCall("DeleteDC", "Ptr", bc.memdc)
    bc.g := 0, bc.bmp := 0, bc.hbm := 0, bc.memdc := 0, bc.bits := 0
}

GP_ScaleBackbuffer(bc, w, h)
{
    if (w = bc.w && h = bc.h)
        return bc
    GP_FreeBackbuffer(bc)
    return GP_Backbuffer(w, h)
}

GP_Present(bc, hwnd)
{
    hdc := DllCall("GetDC", "Ptr", hwnd, "Ptr")
    r := DllCall("BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", bc.w, "Int", bc.h, "Ptr", bc.memdc, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
    DllCall("ReleaseDC", "Ptr", hwnd, "Ptr", hdc)
    return r
}

GP_Save(bc, path)
{
    if (FileExist(path))
        FileDelete, %path%
    VarSetCapacity(clsid, 16, 0)
    if (DllCall("ole32\CLSIDFromString", "WStr", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "Ptr", &clsid) != 0)
        return 0
    return DllCall("gdiplus\GdipSaveImageToFile", "Ptr", bc.bmp, "WStr", path, "Ptr", &clsid, "Ptr", 0)
}

GP_Clear(g, color)
{
    DllCall("gdiplus\GdipGraphicsClear", "Ptr", g, "UInt", color)
}

GP_Flush(bc)
{
    if (bc.g)
        DllCall("gdiplus\GdipFlush", "Ptr", bc.g, "Int", 1)
}

GP_Blend(g, mode)
{
    DllCall("gdiplus\GdipSetCompositingMode", "Ptr", g, "Int", mode)
}

GP_Quality(g, smooth)
{
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", smooth)
}

GP_Fill(g, path, color)
{
    if (!path)
        return
    br := GP_Brush(color)
    if (br)
        DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", br, "Ptr", path)
}

GP_Stroke(g, path, thick, color, cap := 2)
{
    if (!path)
        return
    pen := GP_Pen(color, thick, cap)
    if (pen)
        DllCall("gdiplus\GdipDrawPath", "Ptr", g, "Ptr", pen, "Ptr", path)
}

GP_Rect(x, y, w, h)
{
    p := 0
    if (DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", p) != 0)
        return 0
    DllCall("gdiplus\GdipAddPathRectangle", "Ptr", p, "Float", x, "Float", y, "Float", w, "Float", h)
    return p
}

GP_RoundRect(x, y, w, h, r)
{
    if (r > w / 2)
        r := w / 2
    if (r > h / 2)
        r := h / 2
    if (r < 0.5)
        return GP_Rect(x, y, w, h)
    d := r * 2
    p := 0
    if (DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", p) != 0)
        return 0
    DllCall("gdiplus\GdipAddPathArc", "Ptr", p, "Float", x, "Float", y, "Float", d, "Float", d, "Float", 180.0, "Float", 90.0)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", p, "Float", x + w - d, "Float", y, "Float", d, "Float", d, "Float", 270.0, "Float", 90.0)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", p, "Float", x + w - d, "Float", y + h - d, "Float", d, "Float", d, "Float", 0.0, "Float", 90.0)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", p, "Float", x, "Float", y + h - d, "Float", d, "Float", d, "Float", 90.0, "Float", 90.0)
    DllCall("gdiplus\GdipClosePathFigure", "Ptr", p)
    return p
}

GP_RoundRectTop(x, y, w, h, r)
{
    if (r > w / 2)
        r := w / 2
    if (r > h)
        r := h
    if (r < 0.5)
        return GP_Rect(x, y, w, h)
    d := r * 2
    p := 0
    if (DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", p) != 0)
        return 0
    DllCall("gdiplus\GdipAddPathArc", "Ptr", p, "Float", x, "Float", y, "Float", d, "Float", d, "Float", 180.0, "Float", 90.0)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", p, "Float", x + w, "Float", y + r, "Float", x + w, "Float", y + h)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", p, "Float", x + w, "Float", y + h, "Float", x, "Float", y + h)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", p, "Float", x, "Float", y + h, "Float", x, "Float", y + r)
    DllCall("gdiplus\GdipClosePathFigure", "Ptr", p)
    return p
}

GP_Line(x1, y1, x2, y2)
{
    p := 0
    if (DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", p) != 0)
        return 0
    DllCall("gdiplus\GdipAddPathLine", "Ptr", p, "Float", x1, "Float", y1, "Float", x2, "Float", y2)
    return p
}

GP_Poly(points, closed := 0)
{
    p := 0
    if (DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", p) != 0)
        return 0
    n := points.MaxIndex()
    i := 3
    While (i + 1 <= n)
    {
        DllCall("gdiplus\GdipAddPathLine", "Ptr", p, "Float", points[i - 2], "Float", points[i - 1], "Float", points[i], "Float", points[i + 1])
        i += 2
    }
    if (closed && n >= 4)
        DllCall("gdiplus\GdipAddPathLine", "Ptr", p, "Float", points[n - 1], "Float", points[n], "Float", points[1], "Float", points[2])
    return p
}

GP_PolyClosed(points)
{
    p := GP_Poly(points)
    if (p)
        DllCall("gdiplus\GdipClosePathFigure", "Ptr", p)
    return p
}

GP_Arrow(cx, cy, r, angDeg, width)
{
    a := angDeg * 0.017453292519943295
    hw := width / 2
    p := 0
    if (DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", p) != 0)
        return 0
    DllCall("gdiplus\GdipAddPathLine", "Ptr", p
        , "Float", cx - Cos(a) * r + Sin(a) * hw, "Float", cy - Sin(a) * r - Cos(a) * hw
        , "Float", cx + Cos(a) * r, "Float", cy + Sin(a) * r)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", p
        , "Float", cx + Cos(a) * r, "Float", cy + Sin(a) * r
        , "Float", cx - Cos(a) * r - Sin(a) * hw, "Float", cy - Sin(a) * r + Cos(a) * hw)
    return p
}

GP_Circle(cx, cy, r)
{
    p := 0
    if (DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", p) != 0)
        return 0
    DllCall("gdiplus\GdipAddPathEllipse", "Ptr", p, "Float", cx - r, "Float", cy - r, "Float", r * 2, "Float", r * 2)
    return p
}

GP_Ellipse(cx, cy, rx, ry)
{
    p := 0
    if (DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", p) != 0)
        return 0
    DllCall("gdiplus\GdipAddPathEllipse", "Ptr", p, "Float", cx - rx, "Float", cy - ry, "Float", rx * 2, "Float", ry * 2)
    return p
}

GP_Arc(cx, cy, r, a0, sweep)
{
    p := 0
    if (DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", p) != 0)
        return 0
    DllCall("gdiplus\GdipAddPathArc", "Ptr", p, "Float", cx - r, "Float", cy - r, "Float", r * 2, "Float", r * 2, "Float", a0, "Float", sweep)
    return p
}

GP_Pie(cx, cy, rx, ry, a0, sweep)
{
    p := 0
    if (DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", p) != 0)
        return 0
    DllCall("gdiplus\GdipAddPathPie", "Ptr", p, "Float", cx - rx, "Float", cy - ry, "Float", rx * 2, "Float", ry * 2, "Float", a0, "Float", sweep)
    return p
}

GP_FreePath(p)
{
    if (p)
        DllCall("gdiplus\GdipDeletePath", "Ptr", p)
}

GP_ClipPush(g, x, y, w, h)
{
    st := 0
    if (DllCall("gdiplus\GdipSaveGraphics", "Ptr", g, "UInt*", st) != 0)
        return 0
    DllCall("gdiplus\GdipSetClipRectI", "Ptr", g, "Int", Round(x), "Int", Round(y), "Int", Max(0, Round(w)), "Int", Max(0, Round(h)), "Int", 1)
    return st
}

GP_ClipPop(g, state)
{
    DllCall("gdiplus\GdipRestoreGraphics", "Ptr", g, "UInt", state)
}

GP_ClipPathPush(g, path)
{
    st := 0
    if (!path)
        return 0
    if (DllCall("gdiplus\GdipSaveGraphics", "Ptr", g, "UInt*", st) != 0)
        return 0
    DllCall("gdiplus\GdipSetClipPath", "Ptr", g, "Ptr", path, "Int", 1)
    return st
}

GP_SetWorld(g, x, y)
{
    DllCall("gdiplus\GdipResetWorldTransform", "Ptr", g)
    if (x != 0 || y != 0)
        DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", g, "Float", x + 0.0, "Float", y + 0.0, "Int", 0)
}

GP_SF(align, wrap := 0, trim := 4)
{
    static cache := {}
    key := align "|" wrap "|" trim
    if (cache.HasKey(key))
        return cache[key]
    sf := 0
    if (DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", sf) != 0)
        return 0
    DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", sf, "Int", align)
    DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", sf, "Int", 1)
    DllCall("gdiplus\GdipSetStringFormatTrimming", "Ptr", sf, "Int", trim)
    if (!wrap)
        DllCall("gdiplus\GdipSetStringFormatFlags", "Ptr", sf, "Int", 0x1000)
    cache[key] := sf
    return sf
}

GP_Brush(color)
{
    static cache := {}
    if (cache.HasKey(color))
        return cache[color]
    br := 0
    if (DllCall("gdiplus\GdipCreateSolidFill", "UInt", color, "Ptr*", br) != 0)
        return 0
    cache[color] := br
    return br
}

GP_Pen(color, thick, cap := 2)
{
    static cache := {}
    key := color "_" thick "_" cap
    if (cache.HasKey(key))
        return cache[key]
    pen := 0
    if (DllCall("gdiplus\GdipCreatePen1", "UInt", color, "Float", thick, "Int", 2, "Ptr*", pen) != 0)
        return 0
    DllCall("gdiplus\GdipSetPenLineJoin", "Ptr", pen, "Int", 2)
    DllCall("gdiplus\GdipSetPenStartCap", "Ptr", pen, "Int", cap)
    DllCall("gdiplus\GdipSetPenEndCap", "Ptr", pen, "Int", cap)
    cache[key] := pen
    return pen
}

GP_TextRect(g, text, x, y, w, h, color, font, align := 0, wrap := 0)
{
    if (!font || text = "" || w <= 0 || h <= 0)
        return
    sf := GP_SF(align, wrap)
    VarSetCapacity(rc, 16, 0)
    NumPut(x + 0.0, rc, 0, "Float")
    NumPut(y + 0.0, rc, 4, "Float")
    NumPut(w + 0.0, rc, 8, "Float")
    NumPut(h + 0.0, rc, 12, "Float")
    br := GP_Brush(color)
    if (br)
        DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", text, "Int", StrLen(text), "Ptr", font, "Ptr", &rc, "Ptr", sf, "Ptr", br)
}

GP_TextL(g, text, x, y, color, font)
{
    GP_TextRect(g, text, x, y - 400.0, 8000.0, 800.0, color, font, 0)
}

GP_TextR(g, text, xr, y, color, font)
{
    GP_TextRect(g, text, xr - 8000.0, y - 400.0, 8000.0, 800.0, color, font, 2)
}

GP_TextC(g, text, cx, y, color, font)
{
    GP_TextRect(g, text, cx - 4000.0, y - 400.0, 8000.0, 800.0, color, font, 1)
}

GP_Measure(g, text, font, width := 8000, height := 800, wrap := 0)
{
    res := { w: 0, h: 0 }
    if (!font || text = "" || width <= 0 || height <= 0)
        return res
    sf := GP_SF(0, wrap)
    VarSetCapacity(rc, 16, 0)
    NumPut(0.0, rc, 0, "Float")
    NumPut(0.0, rc, 4, "Float")
    NumPut(width + 0.0, rc, 8, "Float")
    NumPut(height + 0.0, rc, 12, "Float")
    VarSetCapacity(bb, 16, 0)
    DllCall("gdiplus\GdipMeasureString", "Ptr", g, "WStr", text, "Int", StrLen(text), "Ptr", font, "Ptr", &rc, "Ptr", sf, "Ptr", &bb, "Ptr", 0, "Ptr", 0)
    res.w := NumGet(bb, 8, "Float")
    res.h := NumGet(bb, 12, "Float")
    return res
}

GP_TextV(g, text, x, cy, color, font, align := 0, h := -1000)
{
    if (align = 1)
        GP_TextC(g, text, x, cy, color, font)
    else if (align = 2)
        GP_TextR(g, text, x, cy, color, font)
    else
        GP_TextL(g, text, x, cy, color, font)
}

GP_Image(path)
{
    img := 0
    if (DllCall("gdiplus\GdipCreateBitmapFromFile", "WStr", path, "Ptr*", img) != 0)
        return 0
    w := 0, h := 0
    DllCall("gdiplus\GdipGetImageWidth", "Ptr", img, "UInt*", w)
    DllCall("gdiplus\GdipGetImageHeight", "Ptr", img, "UInt*", h)
    return { p: img, w: w, h: h }
}

GP_FreeImage(img)
{
    if (img)
        DllCall("gdiplus\GdipDisposeImage", "Ptr", img.p)
}

GP_DrawImage(g, img, x, y, w, h)
{
    global GP_UnitPixel
    if (!img)
        return
    DllCall("gdiplus\GdipDrawImageRectRect", "Ptr", g, "Ptr", img.p
        , "Float", x, "Float", y, "Float", w, "Float", h
        , "Float", 0, "Float", 0, "Float", img.w, "Float", img.h
        , "Int", GP_UnitPixel, "Ptr", 0, "Ptr", 0, "Ptr", 0)
}