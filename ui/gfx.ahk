#NoEnv

global UI_SCALE := 1.0
global UI_DT := 0.016
global UI_TIME := 0
global UI_ANIM := {}
global UI_FONTS := {}
global UI_TH := {}
global UI_FAM_R := 0
global UI_FAM_M := 0
global UI_FAM_S := 0
global UI_FAM_L := 0
global UI_LANG := 0
global UI_LOGO := 0

global COL_BG := 0xFF101115
global COL_SIDE := 0xFF131519
global COL_PANEL := 0xFF131519
global COL_FIELD := 0xFF1C1F24
global COL_FIELD_H := 0xFF202329
global COL_GROUP := 0xFF171A1E
global COL_BORDER := 0xFF26282C
global COL_BORDER_H := 0xFF34373E
global COL_RED := 0xFFCE3535
global COL_RED_H := 0xFFD94242
global COL_RED_P := 0xFFB92F2F
global COL_WHITE := 0xFFF2F3F5
global COL_TEXT := 0xFFE4E5E8
global COL_GRAY := 0xFF80828B
global COL_GRAY2 := 0xFFA3A5AB
global COL_ICON := 0xFF8D9097
global COL_ICON_H := 0xFFB8BAC0
global COL_ROW := 0xFF181B1F
global COL_SEL := 0xFF26181C
global COL_SB := 0xFF2E3035
global COL_SB_H := 0xFF3A3D43
global COL_SB_A := 0xFF45484F
global COL_INK := 0xFF6C6F77

S(v)
{
    global UI_SCALE
    return v * UI_SCALE
}

R(v)
{
    return Round(v)
}

Al(c, a)
{
    if (a >= 1)
        return c
    if (a <= 0)
        return c & 0x00FFFFFF
    return ((Round(a * 255) << 24) | (c & 0x00FFFFFF))
}

Mix(c1, c2, t)
{
    if (t <= 0)
        return c1
    if (t >= 1)
        return c2
    a1 := (c1 >> 24) & 0xFF
    r1 := (c1 >> 16) & 0xFF
    g1 := (c1 >> 8) & 0xFF
    b1 := c1 & 0xFF
    a2 := (c2 >> 24) & 0xFF
    r2 := (c2 >> 16) & 0xFF
    g2 := (c2 >> 8) & 0xFF
    b2 := c2 & 0xFF
    return (((Round(a1 + (a2 - a1) * t)) << 24) | ((Round(r1 + (r2 - r1) * t)) << 16) | ((Round(g1 + (g2 - g1) * t)) << 8) | (Round(b1 + (b2 - b1) * t)))
}

Anim(id, target, speed := 14.0)
{
    global UI_ANIM, UI_DT
    v := UI_ANIM.HasKey(id) ? UI_ANIM[id] : target
    v := v + (target - v) * (1 - Exp(-speed * UI_DT))
    if (Abs(v - target) < 0.001)
        v := target
    UI_ANIM[id] := v
    return v
}

UI_AnimReset(id, target)
{
    global UI_ANIM
    UI_ANIM[id] := target
}

Fnt(css, w := 0)
{
    global UI_FONTS, UI_FAM_R, UI_FAM_M, UI_FAM_S
    fam := (w = 2) ? UI_FAM_S : ((w = 1) ? UI_FAM_M : UI_FAM_R)
    key := fam "_" S(css) "_" w
    if (UI_FONTS.HasKey(key))
        return UI_FONTS[key]
    f := GP_Font(fam, S(css), 0, 2)
    UI_FONTS[key] := f
    return f
}

TH(g, css, w := 0)
{
    global UI_TH
    key := Fnt(css, w)
    if (UI_TH.HasKey(key))
        return UI_TH[key]
    h := GP_Measure(g, "Hg", Fnt(css, w)).h
    UI_TH[key] := h
    return h
}

TxtW(g, t, css, w := 0)
{
    return TxtMeasure(g, t, css, w).w
}

TxtMeasure(g, text, css, weight := 0, width := 8000, height := 800, wrap := 0)
{
    static cache := {}, context := ""
    global UI_SCALE, UI_LANG, UI_FAM_R, UI_FAM_M, UI_FAM_S
    current := UI_SCALE "|" UI_LANG "|" UI_FAM_R "|" UI_FAM_M "|" UI_FAM_S
    if (current != context)
    {
        cache := {}
        context := current
    }
    font := Fnt(css, weight)
    key := font "|" width "|" height "|" wrap "|" text
    if (cache.HasKey(key))
        return cache[key]
    if (cache.Count() >= 1024)
        cache := {}
    size := GP_Measure(g, text, font, width, height, wrap)
    cache[key] := size
    return size
}

Txt(g, t, x, y, col, css, w := 0)
{
    GP_TextL(g, t, x, y, col, Fnt(css, w))
}

TxtR(g, t, xr, cy, col, css, w := 0)
{
    GP_TextR(g, t, xr, cy, col, Fnt(css, w))
}

TxtC(g, t, cx, cy, col, css, w := 0, align := 1)
{
    GP_TextV(g, t, cx, cy, col, Fnt(css, w), align)
}

TxtV(g, t, x, cy, col, css, w := 0, align := 0)
{
    GP_TextV(g, t, x, cy, col, Fnt(css, w), align)
}

TxtBox(g, t, x, y, w, h, col, css, weight := 0, align := 0)
{
    GP_TextRect(g, t, x, y, w, h, col, Fnt(css, weight), align)
}

Fill(g, x, y, w, h, r, col)
{
    p := GP_RoundRect(x, y, w, h, r)
    GP_Fill(g, p, col)
    GP_FreePath(p)
}

Frame(g, x, y, w, h, r, col, t := 1.3)
{
    p := GP_RoundRect(x, y, w, h, r)
    GP_Stroke(g, p, t, col)
    GP_FreePath(p)
}

Dot(g, cx, cy, r, col)
{
    p := GP_Circle(cx, cy, r)
    GP_Fill(g, p, col)
    GP_FreePath(p)
}

Ring(g, cx, cy, r, col, t := 1.3)
{
    p := GP_Circle(cx, cy, r)
    GP_Stroke(g, p, t, col)
    GP_FreePath(p)
}

Dash(g, x1, y1, x2, y2, col, t := 1.0)
{
    p := GP_Line(x1, y1, x2, y2)
    GP_Stroke(g, p, t, col)
    GP_FreePath(p)
}

IconChr(g, cp, cx, cy, size, col)
{
    global UI_FAM_L
    f := GP_Font(UI_FAM_L, size, 0, 2)
    if (!f)
        return
    m := GP_Measure(g, Chr(cp), f)
    GP_TextL(g, Chr(cp), cx - m.w / 2, cy - m.h / 2, col, f)
}

IconClose(g, cx, cy, r, col)
{
    IconChr(g, 0xE1B2, cx, cy, r * 2.0, col)
}

IconMin(g, cx, cy, r, col)
{
    IconChr(g, 0xE11C, cx, cy, r * 2.0, col)
}

IconChevron(g, cx, cy, r, col, up := 0)
{
    IconChr(g, up ? 0xE070 : 0xE06D, cx, cy, r * 1.5, col)
}

IconSearch(g, cx, cy, r, col)
{
    IconChr(g, 0xE151, cx, cy, r * 1.5, col)
}

IconSliders(g, cx, cy, r, col)
{
    IconChr(g, 0xE29A, cx, cy, r * 1.5, col)
}

IconGear(g, cx, cy, r, col, bg)
{
    IconChr(g, 0xE154, cx, cy, r * 1.5, col)
}

IconSun(g, cx, cy, r, col)
{
    IconChr(g, 0xE178, cx, cy, r * 1.5, col)
}

IconSnowflake(g, cx, cy, r, col)
{
    IconChr(g, 0xE165, cx, cy, r * 1.5, col)
}

IconCloud(g, cx, cy, r, col)
{
    IconChr(g, 0xE088, cx, cy, r * 1.5, col)
}

IconCube(g, cx, cy, r, col)
{
    IconChr(g, 0xE061, cx, cy, r * 1.5, col)
}

IconSpark(g, cx, cy, r, col)
{
    IconChr(g, 0xE47E, cx, cy, r * 1.5, col)
}

IconTarget(g, cx, cy, r, col)
{
    IconChr(g, 0xE180, cx, cy, r * 1.5, col)
}

IconBolt(g, cx, cy, r, col)
{
    IconChr(g, 0xE58C, cx, cy, r * 1.5, col)
}

IconWarn(g, cx, cy, r, col)
{
    IconChr(g, 0xE193, cx, cy, r * 1.5, col)
}

IconAperture(g, cx, cy, r, col)
{
    IconChr(g, 0xE040, cx, cy, r * 1.5, col)
}

IconHash(g, cx, cy, r, col)
{
    IconChr(g, 0xE0EF, cx, cy, r * 1.8, col)
}

IconPower(g, cx, cy, r, col)
{
    IconChr(g, 0xE140, cx, cy, r * 1.5, col)
}

IconRefresh(g, cx, cy, r, col)
{
    IconChr(g, 0xE145, cx, cy, r * 1.5, col)
}

IconFlag(g, cx, cy, r, col, ru)
{
    IconChr(g, 0xE0D1, cx, cy, r * 1.5, col)
}

TR(ru, en)
{
    global UI_LANG
    return UI_LANG ? en : ru
}

LC(s)
{
    StringLower, s, s
    return s
}

UC(s)
{
    StringUpper, s, s
    return s
}