ClockMs()
{
    static freq := 0
    if (!freq)
        DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", ticks)
    return ticks * 1000.0 / freq
}

ResolverReset()
{
    global RS, CT
    gen := IsObject(RS) ? RS.generation + 1 : 1
    RS := { generation: gen, queue: [], current: "", requests: {}, serial: 0, exiting: false, initial: false }
    for _, cv in CT
        cv.pending := false
}

ResolverCancel(idx)
{
    global RS, CT
    RS.requests.Delete("ct" idx)
    CT[idx].pending := false
    CT[idx].failed := false
}

ResolverQueue(kind, idx := 0, manual := false)
{
    global RS, CT
    key := kind = "ct" ? "ct" idx : kind
    if (RS.exiting)
        return
    if (RS.requests.HasKey(key))
    {
        if (kind = "ct" && manual)
        {
            if (IsObject(RS.current) && RS.current.key = key)
                RS.current.manual := true
            for _, pend in RS.queue
                if (pend.key = key)
                    pend.manual := true
        }
        return
    }
    if (kind = "ct")
        cv := CT[idx]
    name := kind = "aspect" ? "r_aspectratio" : cv.name
    mod := kind = "ct" ? cv.module : (kind = "aspect" ? "engine2.dll" : "client.dll")
    id := ++RS.serial
    job := { key: key, id: id, generation: RS.generation, kind: kind, idx: idx, manual: manual, name: name, module: mod, stage: "init", targets: [], si: 1, ti: 1, j: 0, ci: 0, loaded: false }
    RS.requests[key] := id
    RS.queue.Push(job)
    if (kind = "ct")
    {
        cv.pending := true
        cv.failed := false
    }
}

ResolverValid(job)
{
    global RS, mem, lastPID
    return !RS.exiting && job.generation = RS.generation && RS.requests[job.key] = job.id && IsObject(mem) && mem.PID = lastPID
}

ResolverStart()
{
    global RS
    RS.initial := true
    ResolverQueue("aspect")
    ResolverRetry()
}

ResolverRetry()
{
    global CT, AspectAddr
    if (!AspectAddr)
        ResolverQueue("aspect")
    for idx, cv in CT
        if (cv.enabled && !cv.resolved)
            ResolverQueue("ct", idx)
}

ResolverSlice(deadline)
{
    global RS, attachState
    while (ClockMs() < deadline && !RS.exiting)
    {
        if (!IsObject(RS.current))
        {
            if (!RS.queue.Length())
            {
                if (RS.initial)
                {
                    RS.initial := false
                    attachState := "ready"
                    UI_Sync()
                }
                return
            }
            RS.current := RS.queue.RemoveAt(1)
        }
        job := RS.current
        if (!ResolverValid(job))
        {
            RS.current := ""
            continue
        }
        done := ResolverStep(job, deadline)
        if (done)
        {
            ResolverFinish(job, done = 1)
            RS.current := ""
        }
    }
}

ResolverFindStrings(job, deadline)
{
    global mem
    while (job.si <= job.secs.Length())
    {
        if (ClockMs() >= deadline)
            return 0
        sec := job.secs[job.si]
        job.si++
        if (sec.vsize < job.patLen)
            continue
        if (!mem.readRaw(job.modBase + sec.va, buf, sec.vsize))
            continue
        off := 0
        Loop
        {
            r := mem.bufferScanForMaskedPattern(&buf, sec.vsize, job.mask, job.GetAddress("needle"), off)
            if (r < 0)
                break
            if (r = 0 || NumGet(buf, r - 1, "UChar") = 0)
                job.targets.Push(job.modBase + sec.va + r)
            off := r + 1
            if (job.targets.Length() >= 8)
                return 1
        }
    }
    return job.targets.Length() ? 1 : -1
}

ResolverFindSlot(job, deadline)
{
    global mem
    minJ := job.kind = "ct" ? 3 : 7
    maxJ := job.kind = "ct" ? 96 : 32
    while (job.si <= job.secs.Length())
    {
        sec := job.secs[job.si]
        if (!sec.exec || sec.vsize < 40)
        {
            job.si++
            continue
        }
        if (!job.loaded)
        {
            if (ClockMs() >= deadline)
                return 0
            if (!mem.readRaw(job.modBase + sec.va, buf, sec.vsize))
            {
                job.si++
                continue
            }
            job.SetCapacity("buf", sec.vsize)
            DllCall("RtlMoveMemory", "Ptr", job.GetAddress("buf"), "Ptr", &buf, "UPtr", sec.vsize)
            job.bufSize := sec.vsize
            job.bufVA := job.modBase + sec.va
            job.leas := []
            job.ti := 1
            job.ci := 0
            job.loaded := true
        }
        if (!job.leas.Length())
        {
            if (job.ti > job.targets.Length())
            {
                job.si++
                job.loaded := false
                continue
            }
            if (ClockMs() >= deadline)
                return 0
            target := job.targets[job.ti]
            job.ti++
            job.leas := ResolverLeas(job.GetAddress("buf"), job.bufSize, job.bufVA, target)
            job.ci := 0
            continue
        }
        if (job.ci >= job.leas.Length())
        {
            job.leas := []
            continue
        }
        pos := job.leas[job.ci + 1]
        j := job.j ? job.j : minJ
        while (j <= maxJ)
        {
            if (pos + j + 7 > job.bufSize)
                break
            if (ClockMs() >= deadline && j > minJ)
                return 0
            res := ResolverCandidate(job, pos, j)
            if (res = 1)
                return 1
            j++
        }
        job.j := 0
        job.ci++
        if (ClockMs() >= deadline)
            return 0
    }
    return -1
}

ResolverLeas(buf, bufSize, secVA, target, op := 0x15)
{
    global mem
    p := buf + 0
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
                r := mem.bufferScanForMaskedPattern(p, end, mask, &needle, off)
                if (r < 0)
                    break
                disp := NumGet(p + r + 3, 0, "Int")
                if (secVA + r + 7 + disp = target)
                    list.Push(r)
                off := r + 1
            }
        }
        c0 := c1
    }
    return list
}

ResolverCandidate(job, pos, j)
{
    global mem, VALUE_OFF
    p := job.GetAddress("buf")
    if (NumGet(p + pos + j, 0, "UChar") != 0x48 || NumGet(p + pos + j + 1, 0, "UChar") != 0x8D || NumGet(p + pos + j + 2, 0, "UChar") != 0x0D)
        return 0
    obj := job.bufVA + pos + j + 7 + NumGet(p + pos + j + 3, 0, "Int")
    if (job.kind = "ct")
    {
        slot := obj + 8
        state := mem.read(slot, "Int64")
        if (state = "" || !state || !VerifyName(state, job.name))
            return 0
        orig := mem.read(state + VALUE_OFF, "" ResolverType(job.idx))
        if (orig = "")
            return 0
        job.result := { slot: slot, state: state, value: state + VALUE_OFF, orig: orig }
        return 1
    }
    state := mem.read(obj + 8, "Int64")
    if (state = "" || !state || !VerifyName(state, job.name))
        return 0
    pVal := mem.read(state + 8, "Int64")
    pMin := mem.read(state + 16, "Int64")
    pMax := mem.read(state + 24, "Int64")
    if (!pVal || !pMin || !pMax)
        return 0
    val := mem.read(pVal, "Float")
    lo := mem.read(pMin, "Float")
    hi := mem.read(pMax, "Float")
    if (val = "" || lo = "" || hi = "")
        return 0
    job.result := { slot: obj + 8, state: state, pVal: pVal, pMin: pMin, pMax: pMax, orig: val, origMin: lo, origMax: hi }
    return 1
}

ResolverStep(job, deadline)
{
    global mem
    if (job.stage = "init")
    {
        job.modBase := ModBase(job.module)
        if (!job.modBase)
            return -1
        job.secs := ModSecs(job.module)
        if (!job.secs.Length())
            return -1
        if (job.kind = "aspect")
        {
            job.stage := "aspect"
            return ResolverAspect(job)
        }
        pat := mem.stringToPattern(job.name, "UTF-8", true)
        if (!IsObject(pat))
            return -1
        job.patLen := mem.getNeedleFromAOBPattern(mask, needle, pat*)
        job.mask := mask
        job.SetCapacity("needle", job.patLen)
        DllCall("RtlMoveMemory", "Ptr", job.GetAddress("needle"), "Ptr", &needle, "UPtr", job.patLen)
        job.stage := "str"
        return 0
    }
    if (job.stage = "str")
    {
        r := ResolverFindStrings(job, deadline)
        if (r = 0)
            return 0
        if (r = -1)
            return -1
        job.si := 1
        job.loaded := false
        job.j := 0
        job.ci := 0
        job.stage := "slot"
        return 0
    }
    if (job.stage = "slot")
        return ResolverFindSlot(job, deadline)
    return -1
}

ResolverAspect(job)
{
    global mem, AspectPat, VALUE_OFF
    pattern := mem.hexStringToPattern(AspectPat)
    match := mem.modulePatternScan(job.module, pattern*)
    if (!match || match <= 0)
        return -1
    obj1 := match + 11 + mem.read(match + 7, "Int")
    obj2 := match + 31 + mem.read(match + 27, "Int")
    get1 := match + 16 + mem.read(match + 12, "Int")
    get2 := match + 40 + mem.read(match + 36, "Int")
    if (obj1 != obj2 || get1 != get2)
        return -1
    state := mem.read(obj1 + 8, "Int64")
    if (state = "" || !state || !VerifyName(state, job.name))
        return -1
    orig := mem.read(state + VALUE_OFF, "Float")
    if (orig = "")
        return -1
    job.result := { slot: obj1 + 8, state: state, value: state + VALUE_OFF, orig: orig }
    return 1
}

ResolverType(idx)
{
    global CT
    return CT[idx].type
}

ResolverFinish(job, success)
{
    global RS, mem, CT, cfg, AspectAddr, AspectSlot, AspectState, AspectOrig, AspectOrigSet
    Critical, On
    if (!ResolverValid(job))
    {
        Critical, Off
        return
    }
    result := job.result
    if (success)
        success := mem.isHandleValid() && mem.read(result.slot, "Int64") = result.state && VerifyName(result.state, job.name)
    RS.requests.Delete(job.key)
    if (job.kind = "ct")
    {
        cv := CT[job.idx]
        cv.pending := false
        cv.failed := !success
        if (success)
        {
            cv.slot := result.slot
            cv.state := result.state
            cv.value := result.value
            cv.resolved := true
            if (!cv.origSet)
            {
                cv.orig := result.orig
                cv.origSet := true
            }
            if (job.manual)
            {
                cv.enabled := true
                cfg[cv.tag] := true
            }
        }
    }
    else if (success && job.kind = "aspect")
    {
        AspectSlot := result.slot
        AspectState := result.state
        AspectAddr := result.value
        if (!AspectOrigSet)
        {
            AspectOrig := result.orig
            AspectOrigSet := true
        }
    }
    Critical, Off
    LogConvar("[resolver] " job.name " " (success ? "resolved" : "not found"))
    if (job.kind = "ct" && job.manual && !success)
        UI_Notify(TR("Не удалось найти конвар: ", "Could not resolve convar: ") CV_Label(CT[job.idx]))
    UI_Sync()
}

PerfSample(name, value)
{
    global PERF_ENABLED, PERF
    if (!PERF_ENABLED)
        return
    if (!IsObject(PERF))
        PERF := {}
    if (!PERF.HasKey(name))
        PERF[name] := []
    values := PERF[name]
    values.Push(value)
    if (values.Length() > 600)
        values.RemoveAt(1)
}

PerfSummary(name)
{
    global PERF
    if (!IsObject(PERF) || !PERF.HasKey(name) || !PERF[name].Length())
        return ""
    values := PERF[name]
    list := ""
    for _, value in values
        list .= value "`n"
    Sort, list, N
    sorted := StrSplit(RTrim(list, "`n"), "`n")
    n := sorted.Length()
    return { count: n, p50: sorted[Ceil(n * 0.50)] + 0, p95: sorted[Ceil(n * 0.95)] + 0, max: sorted[n] + 0 }
}