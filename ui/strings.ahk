#NoEnv

CV_Strings()
{
    static data := 0
    if (IsObject(data))
        return data
    data := {}
    data["r_directlighting"] := {en: "Direct Lighting", ru: "Прямой свет"
        , tipEn: "Direct lighting from light sources. Off = flat, darker picture, fewer lighting passes", tipRu: "Прямое освещение от источников света. Выкл = плоская, более тёмная картинка, меньше проходов света"}
    data["r_shadows"] := {en: "Shadows", ru: "Тени"
        , tipEn: "Shadow maps for every light. Off = no shadows at all, the biggest FPS gain here", tipRu: "Карты теней для всех источников света. Выкл = теней нет вообще, самый большой прирост ФПС"}
    data["lb_cull_onscreen_bounce_light_shadows"] := {en: "Cull Bounce Shadows", ru: "Отсечь тени bounce-света"
        , tipEn: "Skips shadow maps for onscreen dynamic bounce lights that may not be visible. Visual impact and performance depend on the scene", tipRu: "Пропускает карты теней динамического bounce-света на экране, которые могут быть не видны. Влияние на картинку и производительность зависит от сцены"}
    data["lb_shadow_map_cull_empty_mixed"] := {en: "Cull Empty Mixed", ru: "Отсечь пустые mixed-тени"
        , tipEn: "Skips mixed shadow maps with no dynamic objects in view. Visual impact and performance depend on the scene", tipRu: "Пропускает mixed-карты теней без динамических объектов в поле зрения. Влияние на картинку и производительность зависит от сцены"}
    data["csm_max_shadow_dist_override"] := {en: "Shadow Dist", ru: "Дальность теней"
        , tipEn: "Cascaded shadow distance override. 600 = shadows only near the camera" Chr(59) " matters only while r_shadows stays on", tipRu: "Переопределение дальности каскадных теней. 600 = тени только рядом с камерой" Chr(59) " имеет смысл, пока r_shadows включён"}
    data["lb_enable_dynamic_lights"] := {en: "Dynamic Lights", ru: "Динамический свет"
        , tipEn: "Dynamic light sources (ability flashes, muzzle lights). Off = darker scene, ability flashes vanish", tipRu: "Динамические источники света (вспышки способностей, выстрелы). Выкл = темнее, вспышки способностей пропадают"}
    data["lb_enable_stationary_lights"] := {en: "Stationary Lights", ru: "Статичный свет"
        , tipEn: "Stationary and mixed map lights. Off = map lamps go out, very dark", tipRu: "Стационарные и mixed источники света карты. Выкл = лампы карты гаснут, очень темно"}
    data["lb_enable_sunlight"] := {en: "Sunlight", ru: "Солнце"
        , tipEn: "Sun light in the light binner. Off = no sun, darker map, one big light less", tipRu: "Солнечный свет в light binner. Выкл = солнца нет, карта темнее, минус один большой источник"}
    data["lb_enable_baked_shadows"] := {en: "Baked Shadows", ru: "Запечённые тени"
        , tipEn: "Baked (precomputed) shadows. Off = flat lightmaps, cheaper shading", tipRu: "Запечённые (предрассчитанные) тени. Выкл = плоские лайтмапы, дешевле шейдинг"}
    data["lb_mixed_shadows"] := {en: "Mixed Shadows", ru: "Mixed-тени"
        , tipEn: "Mixed static+dynamic shadow path. Off = one shadow path less" Chr(59) " mostly covered by r_shadows", tipRu: "Смешанный путь статичных+динамических теней. Выкл = минус один теневой проход" Chr(59) " в основном перекрывается r_shadows"}
    data["lb_max_visible_barn_lights_override"] := {en: "Max Lights", ru: "Лимит ламп"
        , tipEn: "Cap on lights rendered per frame, engine default 320. 8 = only the brightest few, big save in lamp-heavy spots", tipRu: "Лимит источников света за кадр, дефолт движка 320. 8 = только несколько самых ярких, большая экономия в местах с кучей ламп"}
    data["mat_fullbright"] := {en: "Fullbright", ru: "Fullbright"
        , tipEn: "Debug render mode 1: no lighting at all, everything flat-lit. Huge gain, editor-like look", tipRu: "Отладочный режим 1: освещения нет вообще, всё плоско подсвечено. Огромный выигрыш, вид как в редакторе"}
    data["r_drawskybox"] := {en: "Skybox", ru: "Небо"
        , tipEn: "2D skybox. Off = black sky, one full-screen pass less", tipRu: "2D-скайбокс. Выкл = чёрное небо, минус один полноэкранный проход"}
    data["r_enable_volume_fog"] := {en: "Volume Fog", ru: "Объёмный туман"
        , tipEn: "Volumetric fog pass. Off = no fog volumes, big GPU save, picture only", tipRu: "Проход объёмного тумана. Выкл = тумана нет, большая экономия GPU, страдает только картинка"}
    data["r_enable_cubemap_fog"] := {en: "Cubemap Fog", ru: "Кубмап-туман"
        , tipEn: "Cubemap-based distance fog. Off = plain fog, cheaper shading", tipRu: "Дистанционный туман на кубмапе. Выкл = простой туман, дешевле шейдинг"}
    data["r_enable_gradient_fog"] := {en: "Gradient Fog", ru: "Градиентный туман"
        , tipEn: "Gradient (height) fog. Off = plain fog, small save", tipRu: "Градиентный (высотный) туман. Выкл = простой туман, небольшая экономия"}
    data["r_citadel_distancefield_farfield_enable"] := {en: "DF Far Field", ru: "SDF дальний"
        , tipEn: "Far-field pass of the distance-field ambient occlusion (ray-marched SDF). Off = one of the most expensive GPU passes gone, slightly flatter shading", tipRu: "Дальний проход SDF-амбиент-окклюжена (трассировка по полю расстояний). Выкл = один из самых дорогих GPU-проходов уходит, затенение чуть площе"}
    data["r_citadel_distancefield_down_sample"] := {en: "DF Downsample", ru: "SDF даунсемпл"
        , tipEn: "Distance-field AO resolution divider. 2 = quarter resolution, much cheaper, softer occlusion", tipRu: "Делитель разрешения SDF-окклюжена. 2 = четверть разрешения, сильно дешевле, затенение мягче"}
    data["r_citadel_distancefield_blur"] := {en: "DF Blur", ru: "SDF блюр"
        , tipEn: "Blur pass over the distance-field AO. Off = noisier occlusion, one full-screen pass less", tipRu: "Проход размытия SDF-окклюжена. Выкл = шумнее затенение, минус один полноэкранный проход"}
    data["r_citadel_distancefield_max_distance"] := {en: "DF Distance", ru: "SDF дистанция"
        , tipEn: "Distance-field AO cull distance, default 2048. 512 = occlusion only near the camera", tipRu: "Дальность отсечки SDF-окклюжена, по умолчанию 2048. 512 = затенение только рядом с камерой"}
    data["sc_force_lod_level"] := {en: "Force LOD", ru: "Грубый LOD"
        , tipEn: "Force every model to LOD 2 instead of distance-based pick. Fewer polygons everywhere" Chr(59) " raise to 3 in the table if stable", tipRu: "Все модели принудительно в LOD 2 вместо выбора по дистанции. Меньше полигонов везде" Chr(59) " если стабильно — в таблице можно поднять до 3"}
    data["sc_fade_distance_scale_override"] := {en: "Fade Distance", ru: "Дальность пропов"
        , tipEn: "Scale of prop fade distances, default -1 (off). 0.5 = props disappear twice as close", tipRu: "Масштаб дистанций исчезновения пропов, дефолт -1 (выкл). 0.5 = пропы пропадают вдвое ближе"}
    data["r_texture_lod_scale"] := {en: "Texture LOD", ru: "LOD текстур"
        , tipEn: "Texture streaming size scale, default 1. 0.5 = every texture streamed at half size, less VRAM and bandwidth", tipRu: "Масштаб запрашиваемого размера текстур, дефолт 1. 0.5 = все текстуры вдвое мельче, меньше VRAM и трафика памяти"}
    data["r_fallback_texture_lod_scale"] := {en: "Fallback Tex LOD", ru: "Fallback LOD"
        , tipEn: "Texture size scale for geometry without UV density data, default 2. 0.5 = four times smaller", tipRu: "Масштаб размера текстур для геометрии без данных о плотности UV, дефолт 2. 0.5 = вчетверо мельче"}
    data["r_citadel_gpu_culling_shadows"] := {en: "GPU Cull Shadows", ru: "GPU Cull"
        , tipEn: "Engine optimisation that is off by default: GPU culling for shadow views. On = fewer shadow casters submitted", tipRu: "Оптимизация движка, выключенная по умолчанию: GPU-отсечка для теневых видов. Вкл = меньше кастеров уходит в тени"}
    data["r_particle_cables_render"] := {en: "Cables", ru: "Кабели"
        , tipEn: "Cable and rope particle systems. Off = cables not drawn", tipRu: "Системы частиц кабелей и верёвок. Выкл = кабели не рисуются"}
    data["r_particle_cables_cast_shadows"] := {en: "Cable Shadows", ru: "Тени кабелей"
        , tipEn: "Shadows cast by cable particles. Off = cables stop casting shadows", tipRu: "Тени от кабельных частиц. Выкл = кабели перестают отбрасывать тени"}
    data["r_citadel_npr_outlines"] := {en: "NPR Outlines", ru: "Обводка"
        , tipEn: "Toon outlines on characters. Off = outline pass skipped, but enemy silhouettes lose their edge", tipRu: "Toon-обводка персонажей. Выкл = проход обводки пропускается, но силуэты врагов теряют контур"}
    data["r_citadel_npr_outlines_max_dist"] := {en: "Outline Dist", ru: "Дальность обводки"
        , tipEn: "Distance where outlines still draw, default 1000. 0 = outlines only point-blank", tipRu: "Дистанция, на которой ещё рисуется обводка, дефолт 1000. 0 = обводка только в упор"}
    data["citadel_player_glow_disabled"] := {en: "Player Glow Off", ru: "Без glow игроков"
        , tipEn: "Player glow (ally highlight through walls). On = glow pass skipped", tipRu: "Свечение игроков (подсветка союзников сквозь стены). Вкл = проход свечения пропускается"}
    data["sc_disable_shadow_fastpath"] := {en: "Shadow Fastpath", ru: "Теневой fastpath"
        , tipEn: "Turns off the shadow fast-path. The slow, correct path stays, so this is a diagnosis switch more than a speed one", tipRu: "Отключает быстрый путь теней. Медленный корректный путь остаётся, так что это скорее диагностический переключатель, чем ускоритель"}
    data["sc_screen_size_lod_scale_override"] := {en: "Screenspace LOD", ru: "LOD по размеру"
        , tipEn: "Screenspace LOD scale override. 0.5 = models swap to cheaper LODs earlier, visible on distant props", tipRu: "Переопределение масштаба screenspace LOD. 0.5 = модели раньше уходят на дешёвые LOD, заметно на дальних объектах"}
    data["lb_shadow_map_culling"] := {en: "Light Culling", ru: "Отсечка теней"
        , tipEn: "Culling of shadow maps the light binner would otherwise render. Off = every shadow map in range is drawn", tipRu: "Отсечка карт теней, которые light binner иначе бы отрисовал. Выкл = рисуются все карты теней в радиусе"}
    data["lb_enable_lights"] := {en: "Disable Lights", ru: "Выключить свет"
        , tipEn: "Master switch of the light binner. Off = no lights at all, flat black-ish scene, biggest save in this batch", tipRu: "Главный выключатель light binner. Выкл = света нет вообще, почти чёрная плоская картинка, самая большая экономия в этой пачке"}
    data["r_render_hair"] := {en: "Hair", ru: "Волосы"
        , tipEn: "Hair rendering. Off = no hair geometry at all, cheap and very visible on close-ups", tipRu: "Отрисовка волос. Выкл = геометрии волос нет вообще, дёшево и сильно заметно вблизи"}
    data["r_haircull_percent"] := {en: "Hair Cull %", ru: "Отсев волос %"
        , tipEn: "Share of hair strands culled, 0 = all strands kept. Only matters while r_render_hair stays on", tipRu: "Доля отсекаемых прядей волос, 0 = все пряди остаются. Имеет смысл, пока r_render_hair включён"}
    data["mat_tonemap_uncap_exposure"] := {en: "Uncap Exposure", ru: "Снять лимит экспозиции"
        , tipEn: "Lets the tonemapper push exposure past its usual ceiling. 1 = brighter HDR range, washes out in bright maps", tipRu: "Позволяет тонмапперу вывести экспозицию выше обычного потолка. 1 = шире HDR-диапазон, на светлых картах вымывает"}
    data["r_pixelvisibility_partial"] := {en: "Pixel Vis Partial", ru: "Частичная видимость"
        , tipEn: "Partial pixel-visibility mode, engine default 2. 1 = coarser occlusion queries, less CPU per frame", tipRu: "Режим частичной pixel-visibility, дефолт движка 2. 1 = грубее occlusion-запросы, меньше CPU на кадр"}
    data["r_drawtracers"] := {en: "No Tracers", ru: "Без трассеров"
        , tipEn: "Bullet tracers and tracer FX. Off = no tracer streaks, one less particle draw", tipRu: "Трассеры пуль и их эффекты. Выкл = полосок от пуль нет, минус одна отрисовка частиц"}
    data["r_drawropes"] := {en: "No Ropes", ru: "Без верёвок"
        , tipEn: "Rope geometry. Off = ropes and cables stop drawing, useful in sections full of them", tipRu: "Геометрия верёвок. Выкл = верёвки и кабели перестают рисоваться, полезно в местах, где их много"}
    data["cl_disable_ragdolls"] := {en: "No Ragdolls", ru: "Без рэгдоллов"
        , tipEn: "Death ragdolls. Off = bodies vanish instead of simulating, saves cloth and physics work on kills", tipRu: "Рэгдоллы на смерть. Выкл = тела исчезают вместо симуляции, экономит ткань и физику при убийствах"}
    data["r_particle_max_draw_distance"] := {en: "Max Draw Dist", ru: "Дальность частиц"
        , tipEn: "Distance cap for particle drawing, engine default is far higher. 3000 = particles pop out early, big save", tipRu: "Потолок дистанции отрисовки частиц, дефолт движка куда больше. 3000 = частицы исчезают рано, большая экономия"}
    data["r_dopixelvisibility"] := {en: "No Pixel Vis", ru: "Без pixel-vis"
        , tipEn: "Turns off pixel-visibility queries used for effects such as glow and flares. This can save CPU, but those visibility effects may disappear", tipRu: "Отключает pixel-visibility запросы для эффектов вроде свечения и фларов. Может снизить нагрузку на CPU, но эти эффекты видимости могут исчезнуть"}
    data["r_drawdecals"] := {en: "No Decals", ru: "Без декалей"
        , tipEn: "Disables decals such as bullet marks and scorch marks. Small, scene-dependent GPU saving" Chr(59) " visual marks disappear", tipRu: "Отключает декали вроде следов пуль и подпалин. Небольшая, зависящая от сцены экономия GPU" Chr(59) " следы исчезнут"}
    data["r_rendersun"] := {en: "No Sun Pass", ru: "Без прохода солнца"
        , tipEn: "Disables the standalone sun render pass. May reduce GPU work on sun-heavy scenes" Chr(59) " lighting and appearance change", tipRu: "Отключает отдельный проход отрисовки солнца. Может снизить нагрузку GPU на солнечных сценах" Chr(59) " освещение и картинка изменятся"}
    data["r_skinning_enabled"] := {en: "No Skinning", ru: "Без скиннинга"
        , tipEn: "Skinned-mesh deformation for characters. Off = models stop following their bones and freeze in bind pose", tipRu: "Деформация скелетных мешей персонажей. Выкл = модели перестают следовать за костями и замирают в bind-позе"}
    data["sc_reject_all_objects"] := {en: "Reject Objects", ru: "Отсев объектов"
        , tipEn: "Rejects scene objects up front. Handy as a hard cull when you need the frame to breathe", tipRu: "Отсекает объекты сцены на входе. Полезно как жёсткая отсечка, когда нужно разгрузить кадр"}
    data["sc_skip_traversal"] := {en: "Skip Traversal", ru: "Без обхода сцены"
        , tipEn: "Skips scene-node traversal for objects that do not need it. Off = safer, but the traversal pass runs full", tipRu: "Пропуск обхода сцены для объектов, которым он не нужен. Выкл = надёжнее, но проход обхода идёт целиком"}
    data["r_drawparticles"] := {en: "Particles", ru: "Частицы"
        , tipEn: "Every particle system: ability effects, smoke, sparks. Off = big GPU save, but enemy abilities become invisible", tipRu: "Все системы частиц: эффекты способностей, дым, искры. Выкл = большая экономия GPU, но способности врагов не видно"}
    data["sc_only_render_opaque"] := {en: "Opaque Only", ru: "Только непрозрачное"
        , tipEn: "Skip every translucent surface. On = glass and effects invisible, like r_translucent 0", tipRu: "Пропускать все полупрозрачные поверхности. Вкл = стекло и эффекты невидимы, как r_translucent 0"}
    data["lb_enable_envmaps"] := {en: "Envmaps", ru: "Envmaps"
        , tipEn: "Environment-map reflections. Off = matte surfaces, no reflection lookups in shaders", tipRu: "Отражения из environment-карт. Выкл = матовые поверхности, в шейдерах нет выборок отражений"}
    data["r_postprocess_enable"] := {en: "Post-process", ru: "Постпроцесс"
        , tipEn: "Whole post-process chain: bloom, tonemap, color grading. Off = raw frame, may look darker or washed out", tipRu: "Вся цепочка постпроцесса: bloom, тонмап, цветокоррекция. Выкл = сырой кадр, может быть темнее или бледнее"}
    data["lb_max_visible_envmaps_override"] := {en: "Max Envmaps", ru: "Лимит envmap"
        , tipEn: "Cap on environment maps per frame, engine default 128. 2 = reflections from two probes at most", tipRu: "Лимит environment-карт за кадр, дефолт движка 128. 2 = отражения максимум от двух проб"}
    data["r_indirectlighting"] := {en: "No Indirect", ru: "Без непрямого света"
        , tipEn: "Disables indirect (bounce) lighting. Can remove a lighting pass, but makes shadows and interiors much flatter", tipRu: "Отключает непрямое (отражённое) освещение. Убирает один проход света, но делает тени и интерьеры заметно площе"}
    return data
}

CV_Label(cv)
{
    data := CV_Strings()
    if (!IsObject(cv))
        return ""
    if (!data.HasKey(cv.name))
        return cv.tag
    it := data[cv.name]
    return TR(it.ru, it.en)
}

CV_Tip(cv)
{
    data := CV_Strings()
    if (!IsObject(cv))
        return ""
    if (!data.HasKey(cv.name))
        return cv.name
    it := data[cv.name]
    return TR(it.tipRu, it.tipEn)
}

CV_Search(cv, query)
{
    static cache := {}
    if (query = "")
        return true
    key := cv.name "`t" cv.tag
    if (!cache.HasKey(key))
    {
        if (cache.Count() >= 256)
            cache := {}
        data := CV_Strings()
        it := data.HasKey(cv.name) ? data[cv.name] : {}
        cache[key] := LC(cv.name " " cv.tag " " it.ru " " it.en)
    }
    return InStr(cache[key], LC(query)) ? true : false
}

UI_HotkeyTip()
{
    return TR("ЛКМ — назначить, ПКМ — удалить", "Left-click to assign, right-click to remove")
}

UI_PendingText()
{
    return TR("Поиск… повторный клик отменяет", "Searching… click again to cancel")
}
