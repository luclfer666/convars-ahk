#NoEnv
SetWorkingDir %A_ScriptDir%
#SingleInstance force
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
#KeyHistory 0

Process, Priority, , BelowNormal
DllCall("Winmm\timeBeginPeriod", "UInt", 1)

CommandLine := DllCall("GetCommandLine", "Str")
If !(A_IsAdmin || RegExMatch(CommandLine, " /restart(?![^\s])")) {
    Try {
        If (A_IsCompiled)
            Run *RunAs "%A_ScriptFullPath%" /restart
        Else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

#include %A_ScriptDir%\data\classMemory.ahk
_ClassMemory.setSeDebugPrivilege()

gameEXE := "ahk_exe deadlock.exe"
engineDLL := "engine2.dll"
clientDLL := "client.dll"

LogFile := A_ScriptDir "\data\convars_debug.txt"
SettingsFile := A_ScriptDir "\data\settings.json"

AspectPat := "48 83 EC 28 48 8D 0D ?? ?? ?? ?? E8 ?? ?? ?? ?? 0F 57 C9 0F 2F C1 76 ?? 48 8D 0D ?? ?? ?? ?? 48 83 C4 28 E9"

VALUE_OFF := 0x58

FovPresets := [90, 100, 105, 110, 115, 120, 125, 130, 135, 140, 150, 165]
AspectPresets := [0, 133, 150, 160, 178, 200, 235, 300]

modBases := {}
modSizes := {}
modSecs := {}
tagMap := {}
hkMap := {}
NoVal := "___absent___"

CT := []
CT.Push({ module: "engine2.dll", tag: "Direct Lighting", name: "r_directlighting", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Shadows", name: "r_shadows", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Cull Bounce", name: "lb_cull_onscreen_bounce_light_shadows", type: "UChar", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Cull Empty Mixed", name: "lb_shadow_map_cull_empty_mixed", type: "UChar", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Shadow Dist", name: "csm_max_shadow_dist_override", type: "Float", target: 600.0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Dyn Lights", name: "lb_enable_dynamic_lights", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Stationary", name: "lb_enable_stationary_lights", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Sunlight", name: "lb_enable_sunlight", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Baked Shadows", name: "lb_enable_baked_shadows", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Mixed Shadows", name: "lb_mixed_shadows", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Max Lights", name: "lb_max_visible_barn_lights_override", type: "Int", target: 8, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Fullbright", name: "mat_fullbright", type: "Int", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "engine2.dll", tag: "Skybox", name: "r_drawskybox", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "Volume Fog", name: "r_enable_volume_fog", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "Cubemap Fog", name: "r_enable_cubemap_fog", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "Grad Fog", name: "r_enable_gradient_fog", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "DF FarField", name: "r_citadel_distancefield_farfield_enable", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "DF Down", name: "r_citadel_distancefield_down_sample", type: "Int", target: 2, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "DF Blur", name: "r_citadel_distancefield_blur", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "DF Dist", name: "r_citadel_distancefield_max_distance", type: "Float", target: 512.0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Force LOD", name: "sc_force_lod_level", type: "Int", target: 2, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Fade Dist", name: "sc_fade_distance_scale_override", type: "Float", target: 0.5, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Texture LOD", name: "r_texture_lod_scale", type: "Float", target: 0.5, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Fallback LOD", name: "r_fallback_texture_lod_scale", type: "Float", target: 0.5, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "GPU Cull", name: "r_citadel_gpu_culling_shadows", type: "UChar", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "particles.dll", tag: "Cables", name: "r_particle_cables_render", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "particles.dll", tag: "Cable Shad", name: "r_particle_cables_cast_shadows", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "NPR Outlines", name: "r_citadel_npr_outlines", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "Outline Dist", name: "r_citadel_npr_outlines_max_dist", type: "Float", target: 0.0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "No Glow", name: "citadel_player_glow_disabled", type: "UChar", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Shadow Path", name: "sc_disable_shadow_fastpath", type: "UChar", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "SS LOD", name: "sc_screen_size_lod_scale_override", type: "Float", target: 0.5, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Light Cull", name: "lb_shadow_map_culling", type: "UChar", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "No Lights", name: "lb_enable_lights", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Hair", name: "r_render_hair", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Hair Cull", name: "r_haircull_percent", type: "Float", target: 0.0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Uncap Exp", name: "mat_tonemap_uncap_exposure", type: "Int", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Pix Vis", name: "r_pixelvisibility_partial", type: "Int", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "No Tracers", name: "r_drawtracers", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "No Ropes", name: "r_drawropes", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "No Ragdolls", name: "cl_disable_ragdolls", type: "UChar", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "particles.dll", tag: "Part Dist", name: "r_particle_max_draw_distance", type: "Float", target: 3000.0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "No Pix Vis", name: "r_dopixelvisibility", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "engine2.dll", tag: "No Decals", name: "r_drawdecals", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "engine2.dll", tag: "No Sun", name: "r_rendersun", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "No Skinning", name: "r_skinning_enabled", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Reject Objs", name: "sc_reject_all_objects", type: "UChar", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Skip Travel", name: "sc_skip_traversal", type: "UChar", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "particles.dll", tag: "Particles", name: "r_drawparticles", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Opaque Only", name: "sc_only_render_opaque", type: "UChar", target: 1, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Envmaps", name: "lb_enable_envmaps", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "client.dll", tag: "Post-process", name: "r_postprocess_enable", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "scenesystem.dll", tag: "Max Envmaps", name: "lb_max_visible_envmaps_override", type: "Int", target: 2, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })
CT.Push({ module: "engine2.dll", tag: "No Indirect", name: "r_indirectlighting", type: "UChar", target: 0, slot: 0, value: 0, orig: 0, origSet: false, resolved: false, enabled: false, forced: 0 })


Loop, % CT.Length()
    tagMap[CT[A_Index].tag] := A_Index

RenderGroups := [ { first: 1, last: 13, title: "Lighting and shadows" }
                , { first: 14, last: 22, title: "Sky, fog, post" }
                , { first: 23, last: 27, title: "Geometry and textures" }
                , { first: 28, last: 32, title: "Particles and effects" }
                , { first: 33, last: 44, title: "Culling and extras" }
                , { first: 45, last: 45, title: "Heavy passes - big FPS" }
                , { first: 46, last: 54, title: "Critical" } ]

grpMap := {}

cfg := { fov_enabled: false, fov: 120, aspect: 150, key_fov: "F5", key_exit: "F8" }
Loop, % CT.Length()
    cfg[CT[A_Index].tag] := false

hkKeys := []
Loop, % CT.Length()
    hkKeys.Push("")
hkKeys[1] := "F6"
hkKeys[13] := "F7"

trayOpen := false
trayX := ""
trayY := ""
popupX := ""
popupY := ""
activeMenu := "Tray"
keepUntil := 0
CoordMode, Mouse, Screen

mem := ""
lastPID := 0
nextRetry := 0
nextResolve := 0
engineBase := 0
engineSize := 0

FormatHex(n)
{
    if (n = "")
        return "(null)"
    return "0x" Format("{:X}", n)
}

LogConvar(msg)
{
    global LogFile
    FormatTime, ts, , yyyy-MM-dd HH:mm:ss
    FileAppend, [%ts%] %msg%`n, %LogFile%
}

JsonGet(txt, key, def)
{
    if RegExMatch(txt, "m)""\Q" key "\E""\s*:\s*(?:""(?<Str>[^""]*)""|(?<Val>true|false|-?[0-9.]+))", m)
        return (mVal != "") ? mVal : mStr
    return def
}

JsonBool(txt, key, def)
{
    v := JsonGet(txt, key, "")
    if (v = "")
        return def
    return (v = "true" || v = "1")
}

JsonNum(txt, key, def)
{
    v := JsonGet(txt, key, "")
    if v is not number
        return def
    return v + 0
}

JsonHas(txt, key)
{
    return RegExMatch(txt, "m)""\Q" key "\E""\s*:") ? true : false
}

LegacyState(txt, oldKey, tag)
{
    global cfg
    if (JsonHas(txt, oldKey) && !JsonHas(txt, tag))
        cfg[tag] := JsonBool(txt, oldKey, false)
}

SettingsLoad()
{
    global cfg, CT, hkKeys, SettingsFile, NoVal
    FileRead, txt, %SettingsFile%
    if (ErrorLevel)
    {
        SettingsSave()
        return
    }
    cfg.fov_enabled := JsonBool(txt, "fov_enabled", cfg.fov_enabled)
    cfg.fov := Round(JsonNum(txt, "fov", cfg.fov))
    cfg.aspect := Round(JsonNum(txt, "aspect", cfg.aspect / 100.0) * 100)
    cfg.key_fov := JsonGet(txt, "key_fov", cfg.key_fov)
    cfg.key_exit := JsonGet(txt, "key_exit", cfg.key_exit)

    Loop, % CT.Length()
        cfg[CT[A_Index].tag] := JsonBool(txt, CT[A_Index].tag, false)

    LegacyState(txt, "directlighting_off", "Direct Lighting")
    LegacyState(txt, "skybox_off", "Skybox")
    LegacyState(txt, "cullbounce_on", "Cull Bounce")
    LegacyState(txt, "cullemptymixed_on", "Cull Empty Mixed")

    Loop, % hkKeys.Length()
    {
        v := JsonGet(txt, "hk_" A_Index, NoVal)
        if (v != NoVal)
            hkKeys[A_Index] := v
    }
    v := JsonGet(txt, "key_directlighting", NoVal)
    if (v != NoVal)
        hkKeys[1] := v
    v := JsonGet(txt, "key_skybox", NoVal)
    if (v != NoVal)
        hkKeys[13] := v
    v := JsonGet(txt, "key_cullbounce", NoVal)
    if (v != NoVal)
        hkKeys[3] := v
    v := JsonGet(txt, "key_cullemptymixed", NoVal)
    if (v != NoVal)
        hkKeys[4] := v

    if (cfg.fov < 40)
        cfg.fov := 40
    if (cfg.fov > 165)
        cfg.fov := 165
    if (cfg.aspect < 0)
        cfg.aspect := 0
    if (cfg.aspect > 300)
        cfg.aspect := 300
}

SettingsSave()
{
    global cfg, CT, hkKeys, SettingsFile
    parts := []
    parts.Push("  ""fov_enabled"": " (cfg.fov_enabled ? "true" : "false"))
    parts.Push("  ""fov"": " cfg.fov)
    parts.Push("  ""aspect"": " Format("{:.2f}", cfg.aspect / 100.0))
    parts.Push("  ""key_fov"": """ cfg.key_fov """")
    parts.Push("  ""key_exit"": """ cfg.key_exit """")
    Loop, % CT.Length()
        parts.Push("  """ CT[A_Index].tag """: " (cfg[CT[A_Index].tag] ? "true" : "false"))
    Loop, % hkKeys.Length()
        parts.Push("  ""hk_" A_Index """: """ hkKeys[A_Index] """")

    j := "{`n"
    Loop, % parts.Length()
        j .= parts[A_Index] . (A_Index < parts.Length() ? ",`n" : "`n")
    j .= "}`n"

    FileDelete, %SettingsFile%
    FileAppend, %j%, %SettingsFile%
}

InitEngine()
{
    global mem, engineBase, engineSize, engineDLL
    modInfo := ""
    engineBase := mem.getModuleBaseAddress(engineDLL, modInfo)
    if (engineBase > 0)
        engineSize := modInfo.SizeOfImage
    else
    {
        engineBase := 0
        engineSize := 0
        LogConvar("engine2.dll not loaded yet")
        return false
    }
    LogConvar("engine2.dll base=" FormatHex(engineBase) " size=" engineSize)
    return true
}

ReadSections(base)
{
    global mem
    secs := []
    e_lfanew := mem.read(base + 0x3C, "UInt")
    if (e_lfanew = "" || e_lfanew <= 0 || e_lfanew > 0x1000)
        return secs
    nt := base + e_lfanew
    nSec := mem.read(nt + 6, "UShort")
    optSize := mem.read(nt + 20, "UShort")
    tbl := nt + 24 + optSize
    Loop, %nSec%
    {
        s := tbl + (A_Index - 1) * 40
        vsize := mem.read(s + 8, "UInt")
        va := mem.read(s + 12, "UInt")
        ch := mem.read(s + 36, "UInt")
        secs.Push({ va: va, vsize: vsize, exec: (ch & 0x20000000) != 0 })
    }
    return secs
}

ModBase(mod)
{
    global mem, modBases, modSizes
    if (!IsObject(mem))
        return 0
    if (modBases.HasKey(mod) && modBases[mod] > 0)
        return modBases[mod]
    info := ""
    base := mem.getModuleBaseAddress(mod, info)
    if (!base || base <= 0)
        return 0
    modBases[mod] := base
    modSizes[mod] := info.SizeOfImage
    return base
}

ModSecs(mod)
{
    global modSecs
    if (!modSecs.HasKey(mod))
        modSecs[mod] := ReadSections(ModBase(mod))
    return modSecs[mod]
}

FindStringsInModule(base, secs, name)
{
    global mem
    list := []
    pat := mem.stringToPattern(name, "UTF-8", true)
    if (!IsObject(pat))
        return list
    nLen := mem.getNeedleFromAOBPattern(mask, needle, pat*)
    for i, sec in secs
    {
        if (sec.vsize < nLen)
            continue
        if (!mem.readRaw(base + sec.va, buf, sec.vsize))
            continue
        off := 0
        Loop
        {
            r := mem.bufferScanForMaskedPattern(&buf, sec.vsize, mask, &needle, off)
            if (r < 0)
                break
            if (r = 0 || NumGet(buf, r - 1, "UChar") = 0)
                list.Push(base + sec.va + r)
            off := r + 1
            if (list.Length() >= 8)
                return list
        }
    }
    return list
}

FindLeaTo(byRef buf, bufSize, secVA, target, op)
{
    global mem
    list := []
    chunk := 0x10000
    mask := "xxx??xx"
    VarSetCapacity(needle, 7, 0)
    NumPut(0x48, needle, 0, "UChar")
    NumPut(0x8D, needle, 1, "UChar")
    NumPut(op, needle, 2, "UChar")

    c0 := 0
    while (c0 + 7 <= bufSize)
    {
        c1 := c0 + chunk
        if (c1 > bufSize)
            c1 := bufSize
        h0 := ((target - (secVA + c0 + 7)) >> 16) & 0xFFFF
        h1 := ((target - (secVA + c1 - 1 + 7)) >> 16) & 0xFFFF
        end := c1 + 6
        if (end > bufSize)
            end := bufSize

        Loop, % (h0 = h1) ? 1 : 2
        {
            h := (A_Index = 1) ? h0 : h1
            NumPut(h & 0xFF, needle, 5, "UChar")
            NumPut((h >> 8) & 0xFF, needle, 6, "UChar")
            off := c0
            Loop
            {
                r := mem.bufferScanForMaskedPattern(&buf, end, mask, &needle, off)
                if (r < 0)
                    break
                disp := NumGet(buf, r + 3, "Int")
                if (secVA + r + 7 + disp = target)
                    list.Push(r)
                off := r + 1
            }
        }
        c0 := c1
    }
    return list
}

VerifyName(ptr, name)
{
    global mem
    need := StrLen(name)
    for _, off in [0, 8, 16, 24, 32, 40]
    {
        p := mem.read(ptr + off, "Int64")
        if (p = "" || !p)
            continue
        s := mem.readString(p, need + 1)
        if (IsObject(s) || s = "")
            continue
        if (SubStr(s, 1, need) = name)
            return true
    }
    return false
}

FindRegistrationSlot(base, secs, name)
{
    global mem
    strs := FindStringsInModule(base, secs, name)
    if (!strs.Length())
        return 0

    firstAny := 0
    for i, sec in secs
    {
        if (!sec.exec || sec.vsize < 40)
            continue
        if (!mem.readRaw(base + sec.va, buf, sec.vsize))
            continue
        secVA := base + sec.va

        for k, target in strs
        {
            leas := FindLeaTo(buf, sec.vsize, secVA, target, 0x15)
            for n, pos in leas
            {
                j := 3
                while (j <= 96)
                {
                    if (pos + j + 7 > sec.vsize)
                        break
                    if (NumGet(buf, pos + j, "UChar") = 0x48 && NumGet(buf, pos + j + 1, "UChar") = 0x8D && NumGet(buf, pos + j + 2, "UChar") = 0x0D)
                    {
                        disp2 := NumGet(buf, pos + j + 3, "Int")
                        obj := secVA + pos + j + 7 + disp2
                        slot := obj + 8
                        nCached := mem.read(slot, "Int64")
                        if (nCached = "" || !nCached)
                            continue
                        if (VerifyName(nCached, name))
                            return slot
                        if (!firstAny)
                            firstAny := slot
                    }
                    j += 1
                }
            }
        }
    }
    return firstAny
}

ResolveOne(byRef cv)
{
    global mem, VALUE_OFF
    cv.resolved := false
    cv.value := 0
    cv.orig := 0
    cv.origSet := false

    if (!IsObject(mem))
        return false

    base := ModBase(cv.module)
    if (!base)
    {
        LogConvar("[" cv.tag "] module " cv.module " not loaded")
        return false
    }

    slot := FindRegistrationSlot(base, ModSecs(cv.module), cv.name)
    if (!slot)
    {
        LogConvar("[" cv.tag "] '" cv.name "' registration NOT FOUND in " cv.module)
        return false
    }

    nCached := mem.read(slot, "Int64")
    if (nCached = "" || !nCached)
        return false

    cv.slot := slot
    cv.value := nCached + VALUE_OFF
    cv.resolved := true
    LogConvar("[" cv.tag "] '" cv.name "' slot " FormatHex(slot) " convar " FormatHex(nCached) " value @ " FormatHex(cv.value) " (now=" mem.read(cv.value, cv.type) ")")
    return true
}

ResolveEnabled()
{
    global CT, cfg
    Loop, % CT.Length()
    {
        cv := CT[A_Index]
        cv.enabled := cfg[cv.tag] ? true : false
        if (!cv.enabled || cv.resolved)
            continue
        if (ResolveOne(cv))
            LogConvar("[" cv.tag "] re-armed from settings")
    }
}

TickConVar(byRef cv)
{
    global mem, VALUE_OFF

    if (!IsObject(mem) || !cv.resolved)
        return

    nCached := mem.read(cv.slot, "Int64")
    if (nCached = "" || !nCached)
        return
    cv.value := nCached + VALUE_OFF

    if (!cv.enabled)
        return

    if (!cv.origSet)
    {
        orig := mem.read(cv.value, cv.type)
        if (orig = "")
        {
            LogConvar("[" cv.tag "] read value @ " FormatHex(cv.value) " failed err=" A_LastError)
            return
        }
        cv.orig := orig
        cv.origSet := true
        cv.forced := 0
        LogConvar("[" cv.tag "] orig=" orig " target=" cv.target)
    }

    cur := mem.read(cv.value, cv.type)
    if (cur = "")
        return

    need := (cv.type = "Float") ? (Abs(cur - cv.target) > 0.0001) : (cur != cv.target)
    if (need)
    {
        if (mem.write(cv.value, cv.target, cv.type))
            cv.forced += 1
        else
            LogConvar("[" cv.tag "] WriteProcessMemory failed @ " FormatHex(cv.value) " err=" A_LastError)
    }
}

RestoreConVar(byRef cv)
{
    global mem, VALUE_OFF

    if (!IsObject(mem) || !cv.resolved || !cv.origSet)
        return

    nCached := mem.read(cv.slot, "Int64")
    if (nCached = "" || !nCached)
        return
    cv.value := nCached + VALUE_OFF

    if (!mem.write(cv.value, cv.orig, cv.type))
        LogConvar("[" cv.tag "] restore write failed @ " FormatHex(cv.value) " err=" A_LastError)
    cv.origSet := false
}

ToggleIdx(idx)
{
    global CT, cfg
    cv := CT[idx]
    if (!cv.resolved)
    {
        if (!ResolveOne(cv))
        {
            LogConvar("[" cv.tag "] not resolved - toggle ignored")
            return
        }
    }

    if (cv.enabled)
    {
        RestoreConVar(cv)
        cv.enabled := false
    }
    else
        cv.enabled := true

    cfg[cv.tag] := cv.enabled
    LogConvar("[" cv.tag "] " (cv.enabled ? "ON" : "OFF"))
    SettingsSave()
    Menu, % cv.menu, % (cv.enabled ? "Check" : "UnCheck"), % cv.tag
}

ToggleFov()
{
    global cfg
    cfg.fov_enabled := !cfg.fov_enabled
    SettingsSave()
    SyncFovChecks()
}

SetFov(val)
{
    global cfg
    cfg.fov := val
    cfg.fov_enabled := true
    SettingsSave()
    SyncFovChecks()
}

SetAspect(val)
{
    global cfg
    cfg.aspect := val
    cfg.fov_enabled := true
    SettingsSave()
    SyncFovChecks()
}

SyncFovChecks()
{
    global cfg, FovItems, AspectItems
    if (cfg.fov_enabled)
        Menu, FovMenu, Check, Enabled
    else
        Menu, FovMenu, UnCheck, Enabled
    for i, v in FovItems
    {
        if (v = cfg.fov)
            Menu, FovValMenu, Check, %v%
        else
            Menu, FovValMenu, UnCheck, %v%
    }
    for i, v in AspectItems
    {
        label := AspectLabel(v)
        if (v = cfg.aspect)
            Menu, AspectMenu, Check, %label%
        else
            Menu, AspectMenu, UnCheck, %label%
    }
}

AspectLabel(a)
{
    return (a <= 0) ? "Native" : Format("{:.2f}", a / 100.0)
}


ResetState()
{
    global CT, modBases, modSizes, modSecs, HeroFov, DesiredFov, AspectAddr, FovResolved, FovApplied, giParsed
    Loop, % CT.Length()
    {
        cv := CT[A_Index]
        cv.resolved := false
        cv.slot := 0
        cv.value := 0
        cv.orig := 0
        cv.origSet := false
        cv.forced := 0
    }
    modBases := {}
    modSizes := {}
    modSecs := {}
    HeroFov.resolved := false, HeroFov.patched := false
    DesiredFov.resolved := false, DesiredFov.patched := false
    AspectAddr := 0
    FovResolved := false
    FovApplied := false
    giParsed := false
}

ResolveFovConVar(byRef cv, base, secs)
{
    global mem
    cv.resolved := false

    strs := FindStringsInModule(base, secs, cv.name)
    if (!strs.Length())
    {
        LogConvar("[FOV] '" cv.name "': string NOT found in any section")
        return false
    }

    foundNameLea := false
    for i, sec in secs
    {
        if (!sec.exec || sec.vsize < 40)
            continue
        if (!mem.readRaw(base + sec.va, buf, sec.vsize))
            continue
        secVA := base + sec.va

        for k, target in strs
        {
            leas := FindLeaTo(buf, sec.vsize, secVA, target, 0x15)
            for n, pos in leas
            {
                foundNameLea := true
                j := 7
                while (j <= 32)
                {
                    if (pos + j + 7 > sec.vsize)
                        break
                    if (NumGet(buf, pos + j, "UChar") = 0x48 && NumGet(buf, pos + j + 1, "UChar") = 0x8D && NumGet(buf, pos + j + 2, "UChar") = 0x0D)
                    {
                        disp2 := NumGet(buf, pos + j + 3, "Int")
                        mirror := secVA + pos + j + 7 + disp2
                        state := mem.read(mirror + 8, "Int64")
                        if (state != "" && state)
                        {
                            pVal := mem.read(state + 0x08, "Int64")
                            pMin := mem.read(state + 0x10, "Int64")
                            pMax := mem.read(state + 0x18, "Int64")
                            if (pVal && pMin && pMax)
                            {
                                cv.pVal := pVal
                                cv.pMin := pMin
                                cv.pMax := pMax
                                cv.patched := false
                                cv.resolved := true
                                LogConvar("[FOV] '" cv.name "' resolved (value=" Format("{:.1f}", mem.read(pVal, "Float")) " min=" Format("{:.1f}", mem.read(pMin, "Float")) " max=" Format("{:.1f}", mem.read(pMax, "Float")) ") lea @ " FormatHex(secVA + pos) " value @ " FormatHex(pVal))
                                return true
                            }
                        }
                    }
                    j += 1
                }
            }
        }
    }

    LogConvar("[FOV] '" cv.name "': FAILED (" (foundNameLea ? "name lea found, no valid mirror" : "no lea rdx -> string") ")")
    return false
}

ResolveAspect()
{
    global mem, engineDLL, AspectPat, AspectAddr, VALUE_OFF
    AspectAddr := 0

    pattern := mem.hexStringToPattern(AspectPat)
    match := mem.modulePatternScan(engineDLL, pattern*)
    if (!match || match <= 0)
    {
        LogConvar("[FOV] r_aspectratio NOT FOUND (aspect off, ret=" match ")")
        return false
    }

    obj1 := match + 11 + mem.read(match + 7, "Int")
    obj2 := match + 31 + mem.read(match + 27, "Int")
    get1 := match + 16 + mem.read(match + 12, "Int")
    get2 := match + 40 + mem.read(match + 36, "Int")
    if (obj1 != obj2 || get1 != get2)
    {
        LogConvar("[FOV] r_aspectratio self-check failed @ " FormatHex(match))
        return false
    }

    state := mem.read(obj1 + 8, "Int64")
    if (state = "" || !state)
    {
        LogConvar("[FOV] r_aspectratio state null @ " FormatHex(obj1 + 8))
        return false
    }

    AspectAddr := state + VALUE_OFF
    LogConvar("[FOV] r_aspectratio resolved @ " FormatHex(AspectAddr) " (now=" Format("{:.2f}", mem.read(AspectAddr, "Float")) ")")
    return true
}

ParseGameInfo()
{
    global mem, clientDLL, giHero, giDesired, giAspect, giParsed
    if (giParsed)
        return
    giParsed := true

    info := ""
    mem.getModuleBaseAddress(clientDLL, info)
    path := info.Name
    if (path = "")
    {
        LogConvar("[FOV] gameinfo — client.dll path failed")
        return
    }
    SplitPath, path, , dir
    gi := ""
    Loop, 8
    {
        if FileExist(dir "\gameinfo.gi")
        {
            gi := dir "\gameinfo.gi"
            break
        }
        SplitPath, dir, , parent
        if (parent = "" || parent = dir)
            break
        dir := parent
    }
    if (gi = "")
    {
        LogConvar("[FOV] gameinfo not found near '" path "' — engine defaults")
        return
    }

    FileRead, txt, %gi%
    hasHero := false, hasDesired := false, hasAspect := false
    Loop, Parse, txt, `n, `r
    {
        if RegExMatch(A_LoopField, "^\s*citadel_camera_hero_fov\s*""([^""]+)""", m)
            giHero := m1 + 0, hasHero := true
        else if RegExMatch(A_LoopField, "^\s*fov_desired\s*""([^""]+)""", m)
            giDesired := m1 + 0, hasDesired := true
        else if RegExMatch(A_LoopField, "^\s*r_aspectratio\s*""([^""]+)""", m)
            giAspect := m1 + 0, hasAspect := true
    }
    LogConvar("[FOV] gameinfo '" gi "': hero_fov=" (hasHero ? "" : "def:") giHero " fov_desired=" (hasDesired ? "" : "def:") giDesired " aspect=" (hasAspect ? "" : "native:") giAspect)
}

ResolveFov()
{
    global mem, clientDLL, HeroFov, DesiredFov, FovResolved, FovApplied
    FovResolved := false
    FovApplied := false

    base := mem.getModuleBaseAddress(clientDLL)
    if (base <= 0)
    {
        LogConvar("[FOV] client.dll not loaded")
        return false
    }
    secs := ReadSections(base)
    if (!secs.Length())
    {
        LogConvar("[FOV] client.dll: PE sections unreadable")
        return false
    }

    ResolveFovConVar(HeroFov, base, secs)
    ResolveFovConVar(DesiredFov, base, secs)
    ResolveAspect()
    ParseGameInfo()

    FovResolved := HeroFov.resolved || DesiredFov.resolved
    return FovResolved
}

FovPatchBounds(byRef cv, lo, hi)
{
    global mem
    if (!cv.resolved || cv.patched)
        return
    cv.origMin := mem.read(cv.pMin, "Float")
    cv.origMax := mem.read(cv.pMax, "Float")
    mem.write(cv.pMin, lo, "Float")
    mem.write(cv.pMax, hi, "Float")
    cv.patched := true
}

FovRestoreBounds(byRef cv)
{
    global mem
    if (!cv.patched)
        return
    mem.write(cv.pMin, cv.origMin, "Float")
    mem.write(cv.pMax, cv.origMax, "Float")
    cv.patched := false
}

FovWriteValue(byRef cv, val)
{
    global mem
    if (!cv.resolved)
        return
    cur := mem.read(cv.pVal, "Float")
    if (cur = "" || Abs(cur - val) >= 0.01)
        mem.write(cv.pVal, val, "Float")
}

WriteAspect(val)
{
    global mem, AspectAddr
    if (!AspectAddr)
        return
    cur := mem.read(AspectAddr, "Float")
    if (cur = "" || Abs(cur - val) >= 0.005)
        mem.write(AspectAddr, val, "Float")
}

TickFov()
{
    global mem, cfg, HeroFov, DesiredFov, FovResolved, FovApplied, giAspect
    if (!IsObject(mem) || !FovResolved)
        return

    if (!cfg.fov_enabled)
    {
        if (FovApplied)
            FovOff()
        return
    }

    FovPatchBounds(HeroFov, 40.0, 200.0)
    FovPatchBounds(DesiredFov, 40.0, 200.0)

    target := cfg.fov + 0.0
    FovWriteValue(HeroFov, target)
    FovWriteValue(DesiredFov, target)
    WriteAspect(cfg.aspect > 0 ? cfg.aspect / 100.0 : giAspect + 0.0)
    FovApplied := true
}

FovOff()
{
    global HeroFov, DesiredFov, FovApplied, giHero, giDesired, giAspect
    FovRestoreBounds(HeroFov)
    FovRestoreBounds(DesiredFov)
    FovWriteValue(HeroFov, giHero + 0.0)
    FovWriteValue(DesiredFov, giDesired + 0.0)
    WriteAspect(giAspect + 0.0)
    FovApplied := false
}


TrayIconMsg(wParam, lParam)
{
    global trayX, trayY, trayOpen, activeMenu
    if (lParam = 0x205 || lParam = 0x202)
    {
        MouseGetPos, trayX, trayY
        trayOpen := true
        activeMenu := "Tray"
        SetTimer, ShowTrayMenu, -1
        return 0
    }
    return 0
}

ReshowTray()
{
    global trayOpen, activeMenu
    if (!trayOpen)
        return
    if (activeMenu = "" || activeMenu = "Tray")
        return
    SetTimer, ReshowMenu, -10
}


BuildTrayMenu()
{
    global cfg, FovPresets, AspectPresets, FovItems, AspectItems, CT, RenderGroups

    FovItems := []
    inserted := false
    for i, v in FovPresets
    {
        if (!inserted && cfg.fov < v)
            FovItems.Push(cfg.fov), inserted := true
        if (v = cfg.fov)
            inserted := true
        FovItems.Push(v)
    }
    if (!inserted)
        FovItems.Push(cfg.fov)

    AspectItems := []
    inserted := false
    for i, v in AspectPresets
    {
        if (!inserted && cfg.aspect < v)
            AspectItems.Push(cfg.aspect), inserted := true
        if (v = cfg.aspect)
            inserted := true
        AspectItems.Push(v)
    }
    if (!inserted)
        AspectItems.Push(cfg.aspect)

    Menu, FovValMenu, Add
    Menu, FovValMenu, DeleteAll
    for i, v in FovItems
        Menu, FovValMenu, Add, %v%, FovPresetSel

    Menu, AspectMenu, Add
    Menu, AspectMenu, DeleteAll
    for i, v in AspectItems
    {
        label := AspectLabel(v)
        Menu, AspectMenu, Add, %label%, AspectPresetSel
    }

    Menu, FovMenu, Add
    Menu, FovMenu, DeleteAll
    Menu, FovMenu, Add, Enabled, FovToggleSel
    Menu, FovMenu, Add
    Menu, FovMenu, Add, Field of view, :FovValMenu
    Menu, FovMenu, Add, Aspect ratio, :AspectMenu

    Menu, RenderMenu, Add
    Menu, RenderMenu, DeleteAll
    for gi, grp in RenderGroups
    {
        mname := "GrpMenu" gi
        Menu, %mname%, Add
        Menu, %mname%, DeleteAll
        Loop, % grp.last - grp.first + 1
        {
            cv := CT[grp.first + A_Index - 1]
            cv.menu := mname
            Menu, %mname%, Add, % cv.tag, ToggleItem
        }
        grpMap[grp.title] := mname
        Menu, RenderMenu, Add, % grp.title, :%mname%
    }

    Menu, Tray, Icon, %A_ScriptDir%\data\icon.ico
    Menu, Tray, Tip, convars
    Menu, Tray, NoStandard
    Menu, Tray, DeleteAll
    Menu, Tray, Add, FOV Changer, :FovMenu
    Menu, Tray, Add, Rendering, :RenderMenu
    Menu, Tray, Add
    Menu, Tray, Add, Open settings.json, OpenSettings
    Menu, Tray, Add, Reload, ReloadScript
    Menu, Tray, Add, Exit, DoExit
}

UpdateTray()
{
    global cfg, CT

    SyncFovChecks()

    Loop, % CT.Length()
    {
        cv := CT[A_Index]
        if (cv.enabled)
            Menu, % cv.menu, Check, % cv.tag
        else
            Menu, % cv.menu, UnCheck, % cv.tag
    }
}

BindHotkeys()
{
    global cfg, hkKeys, hkMap, CT
    hkMap := {}
    if (cfg.key_fov != "")
    {
        Try
            Hotkey, % cfg.key_fov, FovHotkey, On
        Catch
            LogConvar("hotkey '" cfg.key_fov "' invalid - skipped")
    }
    Loop, % CT.Length()
    {
        k := hkKeys[A_Index]
        if (k = "")
            continue
        Try
        {
            Hotkey, %k%, TglHotkey, On
            hkMap[k] := A_Index
        }
        Catch
            LogConvar("hotkey '" k "' for [" CT[A_Index].tag "] invalid - skipped")
    }
    if (cfg.key_exit != "")
    {
        Try
            Hotkey, % cfg.key_exit, ExitHotkey, On
        Catch
            LogConvar("hotkey '" cfg.key_exit "' invalid - skipped")
    }
}

FileDelete, %LogFile%
SettingsLoad()
LogConvar("=== convars.ahk started - convars=" CT.Length() " fov=" cfg.key_fov " exit=" cfg.key_exit " ===")

OnExit, OnExitSub

BuildTrayMenu()
UpdateTray()
BindHotkeys()
OnMessage(0x404, "TrayIconMsg")

Loop
{
    Process, Exist, deadlock.exe
    pid := ErrorLevel

    if (pid)
    {
        if (!IsObject(mem) || pid != lastPID)
        {
            if (A_TickCount >= nextRetry)
            {
                mem := new _ClassMemory(gameEXE)
                if (IsObject(mem))
                {
                    lastPID := pid
                    nextRetry := 0
                    InitEngine()
                    ResolveFov()
                    ResolveEnabled()
                    UpdateTray()
                    LogConvar("attached to pid " pid)
                }
                else
                {
                    nextRetry := A_TickCount + 2000
                    LogConvar("OpenProcess failed (pid=" pid ") - game running as admin?")
                }
            }
        }
        else
        {
            due := (A_TickCount >= nextResolve)
            Loop, % CT.Length()
            {
                cv := CT[A_Index]
                if (cv.enabled && !cv.resolved)
                {
                    if (due)
                        ResolveOne(cv)
                }
                else
                    TickConVar(cv)
            }
            if (due)
                nextResolve := A_TickCount + 3000
            TickFov()
        }
    }
    else
    {
        if (IsObject(mem) || lastPID)
        {
            mem := ""
            lastPID := 0
            nextRetry := 0
            nextResolve := 0
            engineBase := 0
            engineSize := 0
            ResetState()
            UpdateTray()
            LogConvar("process gone - state reset")
        }
    }
    Sleep, 100
}

return

FovHotkey:
    ToggleFov()
return

ExitHotkey:
    ExitApp
return

TglHotkey:
    k := A_ThisHotkey
    if (hkMap.HasKey(k))
        ToggleIdx(hkMap[k])
return

ToggleItem:
    k := A_ThisMenuItem
    activeMenu := A_ThisMenu
    if (tagMap.HasKey(k))
        ToggleIdx(tagMap[k])
    ReshowTray()
return

FovToggleSel:
    activeMenu := A_ThisMenu
    ToggleFov()
    ReshowTray()
return

FovPresetSel:
    activeMenu := A_ThisMenu
    SetFov(A_ThisMenuItem + 0)
    ReshowTray()
return

AspectPresetSel:
    activeMenu := A_ThisMenu
    SetAspect((A_ThisMenuItem = "Native") ? 0 : Round(A_ThisMenuItem * 100))
    ReshowTray()
return

ShowTrayMenu:
    popupX := ""
    popupY := ""
    Menu, Tray, Show, %trayX%, %trayY%
    keepUntil := A_TickCount + 500
    SetTimer, PollMenu, -200
return

ReshowMenu:
    global trayOpen, activeMenu, popupX, popupY, keepUntil
    if (!trayOpen)
        return
    if (activeMenu = "" || activeMenu = "Tray")
        return
    WinGetPos, px, py, pw, ph, ahk_class #32768
    if (ErrorLevel = 0)
    {
        popupX := px
        popupY := py
    }
    if (popupX = "" || popupY = "")
        return
    keepUntil := A_TickCount + 600
    SetTimer, PollMenu, -150
    Menu, %activeMenu%, Show, %popupX%, %popupY%
return

PollMenu:
    global trayOpen, activeMenu, popupX, popupY, keepUntil
    if (!trayOpen)
        return
    WinGetPos, px, py, pw, ph, ahk_class #32768
    if (ErrorLevel = 0)
    {
        popupX := px
        popupY := py
        keepUntil := A_TickCount + 500
        SetTimer, PollMenu, -150
        return
    }
    if (A_TickCount < keepUntil)
    {
        SetTimer, PollMenu, -80
        return
    }
    trayOpen := false
    activeMenu := "Tray"
    popupX := ""
    popupY := ""

OpenSettings:
    Run, notepad.exe "%SettingsFile%"
return

DoExit:
    ExitApp
return

ReloadScript:
    Reload
return

OnExitSub:
    Try
    {
        Loop, % CT.Length()
            RestoreConVar(CT[A_Index])
        if (FovApplied)
            FovOff()
    }
    DllCall("Winmm\timeEndPeriod", "UInt", 1)
ExitApp
return
