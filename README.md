convars (AHK)

Скрипт для Deadlock на AutoHotkey. Работает снаружи игры, без инжекта: находит нужные конвары в памяти процесса и переключает их из трея или по горячим клавишам. Это AHK-версия проекта unlock-convars (https://github.com/luclfer666/unlock-convars) — та же таблица конваров, те же целевые значения, только без DLL.

Что умеет:
  FOV Changer  — угол обзора 40–165 и соотношение сторон. При выключении возвращает значения из gameinfo.gi игры
  Rendering    — 54 конвара, разбитых на группы (свет и тени, небо/туман/постобработка, геометрия и текстуры,
                 частицы и эффекты, куллинг и прочее, тяжёлые проходы, критичные). Список и порядок совпадают
                 с меню DLL-версии, группа Critical — последняя


СОСТАВ

  convars-ahk/
  ├─ AutoHotkey_1.1.37.02_setup.exe   установщик AutoHotkey
  ├─ convars.ahk                      сам скрипт
  └─ data/
     ├─ classMemory.ahk               библиотека работы с памятью
     ├─ icon.ico                      иконка в трее
     ├─ settings.json                 настройки (создаётся при первом запуске)
     └─ convars_debug.txt             лог (создаётся при первом запуске)


УСТАНОВКА

  1. Запустите AutoHotkey_1.1.37.02_setup.exe.
  2. Нажмите Express Installation, дождитесь окончания и закройте установщик кнопкой Exit.
  3. Запустите convars.ahk двойным кликом. Скрипт сам запросит права администратора — они нужны, чтобы читать и писать память игры.
  4. В трее появится иконка convars. Игру можно запускать до или после скрипта — он сам подхватит deadlock.exe.

  Нужна именно ветка AutoHotkey 1.1 (v1). На AutoHotkey v2 скрипт не запустится.


ИСПОЛЬЗОВАНИЕ

  Правый или левый клик по иконке в трее открывает меню:

  FOV Changer               ▸
     ├ Enabled
     ├ Field of view         ▸  90 / 100 / 105 / 110 / 115 / 120 / 125 / 130 / 135 / 140 / 150 / 165
     └ Aspect ratio          ▸  Native / 1.33 / 1.50 / 1.60 / 1.78 / 2.00 / 2.35 / 3.00
  Rendering                 ▸
     ├ Lighting and shadows    ▸  13 конваров
     ├ Sky, fog, post          ▸  9
     ├ Geometry and textures   ▸  5
     ├ Particles and effects   ▸  5
     ├ Culling and extras      ▸  12
     ├ Heavy passes - big FPS  ▸  1
     └ Critical                ▸  9
  ──────────────
  Open settings.json
  Reload
  Exit

  - Галочка показывает, что фича включена.
  - Выбор пресета FOV или аспекта сам включает FOV Changer — отдельно тыкать Enabled не надо.
  - После выбора пункта меню не закрывается: остаётся открытым ровно то подменю, из которого вы кликали,
    и тыкать в него можно сколько угодно раз подряд. Закрыть — клик мимо меню или Esc.
  - Aspect ratio → Native оставляет соотношение сторон таким, как задано в игре.
  - Подменю Rendering строится из того же списка, что и меню DLL-версии: те же названия, тот же порядок,
    тот же смысл галочки.

  Горячие клавиши по умолчанию:
    F5  — FOV Changer вкл/выкл
    F6  — Direct Lighting вкл/выкл
    F7  — Skybox вкл/выкл
    F8  — закрыть скрипт

  На остальные 52 конвара горячих клавиш по умолчанию нет — назначаются в settings.json (hk_<номер>).
  Номер — позиция конвара в таблице, 1..54, в том же порядке, что и в меню Rendering.

  Все переключения сохраняются и применяются сами при следующем запуске игры. При выходе из скрипта
  (Exit, F8, закрытие игры) все изменённые конвары возвращаются к значениям, которые были до первого включения.


НАСТРОЙКИ

  data\settings.json — создаётся при первом запуске, правится в любом редакторе (Open settings.json в трее). После правки — Reload в трее.

  {
    "fov_enabled": false,
    "fov": 120,
    "aspect": 1.50,
    "key_fov": "F5",
    "key_exit": "F8",
    "Direct Lighting": false,
    "Shadows": false,
    ...
    "No Indirect": false,
    "hk_1": "F6",
    "hk_2": "",
    ...
    "hk_13": "F7",
    ...
    "hk_54": ""
  }

  fov     — 40–165. Нестандартное число (например 117) появится в меню отдельным пунктом.
  aspect  — 0.50–3.00, 0 = Native.
  <тег>   — по одному булеву ключу на каждый конвар, имя ключа = короткое имя пункта меню
            (Direct Lighting, Shadows, Skybox, No Sun и т.д.). true = конвар переопределён скриптом.
  hk_<1..54> — горячая клавиша для конвара с этим номером; по умолчанию пусто, кроме hk_1 (F6) и hk_13 (F7).
  key_*   — клавиша в синтаксисе AutoHotkey (https://www.autohotkey.com/docs/v1/KeyList.htm):
            F5, ^F5 (Ctrl+F5), !x (Alt+X), Numpad1. Пустая строка — без клавиши.

  Из старых версий скрипта настройки переносятся сами: directlighting_off, skybox_off, cullbounce_on,
  cullemptymixed_on, key_directlighting, key_skybox, key_cullbounce, key_cullemptymixed.


ЛОГ

  data\convars_debug.txt перезаписывается при каждом запуске и содержит результат поиска конваров:

  === convars.ahk started - convars=54 fov=F5 exit=F8 ===
  engine2.dll base=0x7FFF2D2B0000 size=9461760
  [Direct Lighting] 'r_directlighting' value @ 0x... (now=1)
  [Skybox] 'r_drawskybox' value @ 0x... (now=1)
  [No Sun] 'lb_enable_sunlight' value @ 0x... (now=1)
  [FOV] 'citadel_camera_hero_fov' resolved (value=100.0 min=75.0 max=90.0) ...
  [FOV] 'fov_desired' resolved (value=75.0 min=1.0 max=135.0) ...
  [FOV] r_aspectratio resolved @ 0x... (now=2.50)
  [FOV] gameinfo '...\game\citadel\gameinfo.gi': hero_fov=100 fov_desired=def:75.0 aspect=2.500000

  Конвары ищутся один раз при старте и повторно раз в 3 секунды, если фича включена, но ещё не найдена —
  чтобы файл не пух.

  Если какая-то фича не работает — в первую очередь смотрите сюда.


ЕСЛИ НЕ РАБОТАЕТ

  [Something] 'name': FAILED  или  string NOT found
    Не нашлась строка с именем конвара в модуле (engine2.dll / client.dll / scenesystem.dll / particles.dll /
    listclient.dll). Игра обновилась и конвар переименован или вырезан. Смотрите LIGHTING_SKYBOX.md основного
    проекта — там разбор, как искать конвары заново.

  Значение пишется, но в игре ничего не меняется
    Часть конваров действует только если в gameinfo.gi у модуля стоит cheat/cannot_override — так же, как
    в DLL-версии. Convar без флага нельзя переопределить из памяти.

  OpenProcess failed — игра запущена под админом?
    Скрипт не смог открыть процесс. Убедитесь, что convars.ahk запущен от администратора
    (он сам запрашивает права при старте — не отказывайте в UAC).

  Скрипт не запускается / открывается в редакторе
    Не установлен AutoHotkey или установлена v2. Поставьте AutoHotkey_1.1.37.02_setup.exe из комплекта.

  Горячая клавиша не срабатывает
    Проверьте строку hotkey '...' invalid в логе — клавиша записана не в синтаксисе AutoHotkey
    или относится к конвару, который не нашёлся. Исправьте в settings.json и сделайте Reload.

  FOV не вернулся при выключении
    Посмотрите строку [FOV] gameinfo в логе. Скрипт возвращает значения из gameinfo.gi
    (citadel_camera_hero_fov, fov_desired, r_aspectratio); если файл не найден или параметра
    в нём нет — берётся дефолт движка (def:).