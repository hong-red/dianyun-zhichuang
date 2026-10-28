using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

/// <summary>
/// 一键生成《十三经》Demo 的 16 个场景、IPButton 预制体，并写入 Build Settings。
/// 通过菜单 Tools/十三经/Build All Scenes 触发。
/// 场景：MainMenu、WorldMap、13 个关卡（2 个 Live2D + 11 个剧情关）、Ending。
/// </summary>
public static class SceneBuilder
{
    static Font _font;
    static Font BuiltinFont
    {
        get
        {
            if (_font == null)
            {
                _font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
                if (_font == null) _font = Resources.GetBuiltinResource<Font>("Arial.ttf");
            }
            return _font;
        }
    }

    static Sprite _uiSprite;
    static Sprite BuiltinUISprite
    {
        get
        {
            if (_uiSprite == null)
                _uiSprite = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/UISprite.psd");
            return _uiSprite;
        }
    }

    [MenuItem("Tools/十三经/Build All Scenes")]
    public static void BuildAll()
    {
        GameObject prefab = BuildIPButtonPrefab();

        BuildMainMenu();
        BuildWorldMap(prefab);

        // 2 个 Live2D 关卡（保留原有体验页玩法）
        BuildGongyangLevel();
        BuildGuliangLevel();

        // 11 个新剧情关卡
        BuildDialogueLevel("ZhouyiLevel", "《周易》 · 观复山八易", "zhouyi_bg", typeof(ZhouyiLevel));
        BuildShangshuLevel();
        BuildShijingLevel();
        BuildDialogueLevel("ZhouliLevel", "《周礼》 · 礼域六官", "zhouli_bg", typeof(ZhouliLevel));
        BuildDialogueLevel("YiliLevel", "《仪礼》 · 正名定分", "yili_bg", typeof(YiliLevel));
        BuildDialogueLevel("LijiLevel", "《礼记》 · 通经致用", "liji_bg", typeof(LijiLevel));
        BuildZuozhuanLevel();
        BuildDialogueLevel("LunyuLevel", "《论语》 · 学城六艺", "lunyu_bg", typeof(LunyuLevel));
        BuildXiaojingLevel();
        BuildDialogueLevel("EryaLevel", "《尔雅》 · 名物之辨", "erya_bg", typeof(EryaLevel));
        BuildDialogueLevel("MengziLevel", "《孟子》 · 义理台", "mengzi_bg", typeof(MengziLevel));

        BuildEnding();

        SetBuildSettings();

        // 建完后打开入口场景，方便直接点 Play 看效果
        EditorSceneManager.OpenScene("Assets/Scenes/MainMenu.unity");

        Debug.Log("[SceneBuilder] 完成：16 个场景 + IPButton 预制体 + Build Settings 已生成。");
    }

    // ---------- 通用工具 ----------

    static Scene NewScene(string name)
    {
        Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        GameObject camGo = new GameObject("Main Camera", typeof(Camera), typeof(AudioListener));
        camGo.tag = "MainCamera";
        Camera cam = camGo.GetComponent<Camera>();
        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.backgroundColor = new Color(0.10f, 0.12f, 0.18f, 1f);
        cam.orthographic = true;
        cam.transform.position = new Vector3(0, 0, -10);
        return scene;
    }

    static void Save(Scene scene, string name)
    {
        if (!AssetDatabase.IsValidFolder("Assets/Scenes"))
            AssetDatabase.CreateFolder("Assets", "Scenes");
        EditorSceneManager.SaveScene(scene, "Assets/Scenes/" + name + ".unity");
    }

    static Canvas CreateCanvas()
    {
        GameObject go = new GameObject("Canvas", typeof(Canvas), typeof(CanvasScaler), typeof(GraphicRaycaster));
        Canvas c = go.GetComponent<Canvas>();
        c.renderMode = RenderMode.ScreenSpaceOverlay;
        CanvasScaler cs = go.GetComponent<CanvasScaler>();
        cs.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        cs.referenceResolution = new Vector2(1920f, 1080f);
        cs.screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
        cs.matchWidthOrHeight = 0.5f;
        EnsureEventSystem();
        return c;
    }

    static void EnsureEventSystem()
    {
        if (Object.FindObjectOfType<EventSystem>() != null) return;
        new GameObject("EventSystem", typeof(EventSystem), typeof(StandaloneInputModule));
    }

    static Text CreateText(Transform parent, string name, string content, int fontSize, Color color, Vector2 anchoredPos, Vector2 size, bool wrap = false)
    {
        GameObject go = new GameObject(name, typeof(RectTransform));
        go.transform.SetParent(parent, false);
        Text t = go.AddComponent<Text>();
        t.font = BuiltinFont;
        t.text = content;
        t.fontSize = fontSize;
        t.color = color;
        t.alignment = TextAnchor.MiddleCenter;
        t.horizontalOverflow = wrap ? HorizontalWrapMode.Wrap : HorizontalWrapMode.Overflow;
        t.verticalOverflow = VerticalWrapMode.Overflow;
        RectTransform rt = (RectTransform)go.transform;
        rt.anchorMin = new Vector2(0.5f, 0.5f);
        rt.anchorMax = new Vector2(0.5f, 0.5f);
        rt.anchoredPosition = anchoredPos;
        rt.sizeDelta = size;
        return t;
    }

    static Button CreateButton(Transform parent, string name, string label, Vector2 anchoredPos, Vector2 size, int fontSize = 30, bool wrap = false)
    {
        GameObject go = new GameObject(name, typeof(RectTransform), typeof(Image), typeof(Button));
        go.transform.SetParent(parent, false);
        RectTransform rt = (RectTransform)go.transform;
        rt.anchorMin = new Vector2(0.5f, 0.5f);
        rt.anchorMax = new Vector2(0.5f, 0.5f);
        rt.anchoredPosition = anchoredPos;
        rt.sizeDelta = size;
        Image img = go.GetComponent<Image>();
        img.sprite = BuiltinUISprite;
        img.type = Image.Type.Sliced;
        img.color = Color.white;
        Button btn = go.GetComponent<Button>();
        btn.targetGraphic = img;

        GameObject lbl = new GameObject("Text", typeof(RectTransform));
        lbl.transform.SetParent(go.transform, false);
        Text t = lbl.AddComponent<Text>();
        t.font = BuiltinFont;
        t.text = label;
        t.fontSize = fontSize;
        t.color = new Color(0.1f, 0.1f, 0.1f, 1f);
        t.alignment = TextAnchor.MiddleCenter;
        t.horizontalOverflow = wrap ? HorizontalWrapMode.Wrap : HorizontalWrapMode.Overflow;
        t.verticalOverflow = VerticalWrapMode.Overflow;
        RectTransform lrt = (RectTransform)lbl.transform;
        lrt.anchorMin = Vector2.zero;
        lrt.anchorMax = Vector2.one;
        lrt.offsetMin = Vector2.zero;
        lrt.offsetMax = Vector2.zero;
        return btn;
    }

    // ---------- 预制体 ----------

    static GameObject BuildIPButtonPrefab()
    {
        GameObject go = new GameObject("IPButton", typeof(RectTransform), typeof(Image), typeof(Button), typeof(IPButton));
        Image img = go.GetComponent<Image>();
        img.sprite = BuiltinUISprite;
        img.type = Image.Type.Sliced;
        img.color = Color.white;
        Button btn = go.GetComponent<Button>();
        btn.targetGraphic = img;

        GameObject lbl = new GameObject("Text", typeof(RectTransform));
        lbl.transform.SetParent(go.transform, false);
        Text t = lbl.AddComponent<Text>();
        t.font = BuiltinFont;
        t.text = "Button";
        t.fontSize = 30;
        t.color = Color.black;
        t.alignment = TextAnchor.MiddleCenter;
        t.horizontalOverflow = HorizontalWrapMode.Overflow;
        t.verticalOverflow = VerticalWrapMode.Overflow;
        RectTransform lrt = (RectTransform)lbl.transform;
        lrt.anchorMin = Vector2.zero;
        lrt.anchorMax = Vector2.one;
        lrt.offsetMin = Vector2.zero;
        lrt.offsetMax = Vector2.zero;

        if (!AssetDatabase.IsValidFolder("Assets/Prefabs"))
            AssetDatabase.CreateFolder("Assets", "Prefabs");
        GameObject prefabAsset = PrefabUtility.SaveAsPrefabAsset(go, "Assets/Prefabs/IPButton.prefab");
        Object.DestroyImmediate(go);
        AssetDatabase.SaveAssets();
        return prefabAsset;
    }

    // ---------- 对话式关卡通用生成 ----------

    static void BuildDialogueLevel(string sceneName, string title, string bgName, System.Type levelType)
    {
        Scene scene = NewScene(sceneName);
        Canvas canvas = CreateCanvas();

        AddBackground(canvas, bgName);

        CreateText(canvas.transform, "Title", title, 52, Color.white, new Vector2(0, 340), new Vector2(1600, 80));
        Text progress = CreateText(canvas.transform, "ProgressText", "", 28, Color.white, new Vector2(0, 270), new Vector2(800, 50));
        Text question = CreateText(canvas.transform, "QuestionText", "", 34, Color.white, new Vector2(0, 140), new Vector2(1500, 130), true);

        Button o1 = CreateButton(canvas.transform, "Option1", "", new Vector2(-360, -30), new Vector2(340, 96), 26, true);
        Button o2 = CreateButton(canvas.transform, "Option2", "", new Vector2(0, -30), new Vector2(340, 96), 26, true);
        Button o3 = CreateButton(canvas.transform, "Option3", "", new Vector2(360, -30), new Vector2(340, 96), 26, true);

        Text response = CreateText(canvas.transform, "ResponseText", "", 30, new Color(1f, 0.9f, 0.5f), new Vector2(0, -160), new Vector2(1400, 110), true);

        Button next = CreateButton(canvas.transform, "NextButton", "继续", new Vector2(0, -270), new Vector2(340, 80));
        Button back = CreateButton(canvas.transform, "BackButton", "返回地图", new Vector2(0, -350), new Vector2(340, 80));

        GameObject controller = new GameObject("Controller");
        DialogueLevelBase lvl = (DialogueLevelBase)controller.AddComponent(levelType);
        lvl.questionText = question;
        lvl.responseText = response;
        lvl.progressText = progress;
        lvl.optionButtons = new Button[] { o1, o2, o3 };
        lvl.nextButton = next;
        lvl.backButton = back;

        Save(scene, sceneName);
    }

    // ---------- 16 个场景 ----------

    static void BuildMainMenu()
    {
        Scene scene = NewScene("MainMenu");
        Canvas canvas = CreateCanvas();

        AddBackground(canvas, "mainmenu_bg");

        CreateText(canvas.transform, "Title", "十三经", 80, Color.white, new Vector2(0, 220), new Vector2(900, 140));
        Button start = CreateButton(canvas.transform, "StartButton", "开始游戏", new Vector2(0, 0), new Vector2(340, 90));
        Button quit = CreateButton(canvas.transform, "QuitButton", "退出游戏", new Vector2(0, -140), new Vector2(340, 90));

        GameObject gm = new GameObject("GameManager");
        gm.AddComponent<GameManager>();
        gm.AddComponent<LocalServerLauncher>();

        GameObject controller = new GameObject("Controller");
        MainMenu mm = controller.AddComponent<MainMenu>();
        mm.startButton = start;
        mm.quitButton = quit;

        AddBGM("DragonDance_Loop");

        Save(scene, "MainMenu");
    }

    static void BuildWorldMap(GameObject ipButtonPrefab)
    {
        Scene scene = NewScene("WorldMap");
        Canvas canvas = CreateCanvas();

        AddBackground(canvas, "worldmap_bg");

        CreateText(canvas.transform, "Title", "典籍大陆 · 大地图", 50, Color.white, new Vector2(0, 380), new Vector2(1200, 80));

        GameObject gridGo = new GameObject("Grid", typeof(RectTransform));
        gridGo.transform.SetParent(canvas.transform, false);
        RectTransform gridRt = (RectTransform)gridGo.transform;
        gridRt.anchorMin = new Vector2(0.5f, 0.5f);
        gridRt.anchorMax = new Vector2(0.5f, 0.5f);
        gridRt.anchoredPosition = new Vector2(0, 40);
        gridRt.sizeDelta = new Vector2(1500, 500);
        GridLayoutGroup grid = gridGo.AddComponent<GridLayoutGroup>();
        grid.cellSize = new Vector2(200, 60);
        grid.spacing = new Vector2(12, 12);
        grid.padding = new RectOffset(0, 0, 0, 0);
        grid.childAlignment = TextAnchor.MiddleCenter;

        // 即将开放面板（Awake 里会自动隐藏）
        GameObject panelGo = new GameObject("ComingSoonPanel", typeof(RectTransform), typeof(Image));
        panelGo.transform.SetParent(canvas.transform, false);
        RectTransform panelRt = (RectTransform)panelGo.transform;
        panelRt.anchorMin = new Vector2(0.5f, 0.5f);
        panelRt.anchorMax = new Vector2(0.5f, 0.5f);
        panelRt.anchoredPosition = Vector2.zero;
        panelRt.sizeDelta = new Vector2(640, 320);
        Image panelImg = panelGo.GetComponent<Image>();
        panelImg.sprite = BuiltinUISprite;
        panelImg.color = new Color(0.06f, 0.08f, 0.12f, 0.97f);

        Text titleText = CreateText(panelGo.transform, "TitleText", "", 34, Color.white, new Vector2(0, 80), new Vector2(520, 60));
        Button closeBtn = CreateButton(panelGo.transform, "CloseButton", "关闭", new Vector2(0, -80), new Vector2(200, 70));

        ComingSoonPanel csp = panelGo.AddComponent<ComingSoonPanel>();
        csp.panel = panelGo;
        csp.titleText = titleText;
        csp.closeButton = closeBtn;

        Button toEnding = CreateButton(canvas.transform, "ToEndingButton", "进入结局", new Vector2(0, -300), new Vector2(340, 80));

        GameObject controller = new GameObject("Controller");
        WorldMap wm = controller.AddComponent<WorldMap>();
        wm.ipButtonPrefab = ipButtonPrefab;
        wm.buttonContainer = gridRt;
        wm.comingSoonPanel = csp;
        wm.toEndingButton = toEnding;

        AddBGM("LotusPond_Loop");

        Save(scene, "WorldMap");
    }

    static void BuildGongyangLevel()
    {
        Scene scene = NewScene("GongyangLevel");
        Canvas canvas = CreateCanvas();

        AddBackground(canvas, "gongyangzhuan_bg");

        CreateText(canvas.transform, "Title", "《公羊传》 · 春秋义海", 60, Color.white, new Vector2(0, 260), new Vector2(900, 100));
        Text hint = CreateText(canvas.transform, "HintText", "", 30, Color.white, new Vector2(0, 80), new Vector2(1200, 80));

        Button openUrl = CreateButton(canvas.transform, "OpenUrlButton", "打开公羊传体验页", new Vector2(0, -40), new Vector2(400, 90));
        Button complete = CreateButton(canvas.transform, "CompleteButton", "完成", new Vector2(0, -160), new Vector2(400, 90));

        GameObject controller = new GameObject("Controller");
        GongyangLevel gl = controller.AddComponent<GongyangLevel>();
        gl.openUrlButton = openUrl;
        gl.completeButton = complete;
        gl.hintText = hint;
        gl.experienceUrl = "http://localhost:12393/gongyangzhuan";
        gl.remoteUrl = "https://4252434c.r3.cpolar.cn/gongyangzhuan";

        Save(scene, "GongyangLevel");
    }

    static void BuildGuliangLevel()
    {
        Scene scene = NewScene("GuliangLevel");
        Canvas canvas = CreateCanvas();

        AddBackground(canvas, "guliangzhuan_bg");

        CreateText(canvas.transform, "Title", "《谷梁传》 · 春秋正名", 60, Color.white, new Vector2(0, 260), new Vector2(900, 100));
        Text hint = CreateText(canvas.transform, "HintText", "", 30, Color.white, new Vector2(0, 80), new Vector2(1200, 80));

        Button openUrl = CreateButton(canvas.transform, "OpenUrlButton", "打开谷梁传体验页", new Vector2(0, -40), new Vector2(400, 90));
        Button complete = CreateButton(canvas.transform, "CompleteButton", "完成", new Vector2(0, -160), new Vector2(400, 90));

        GameObject controller = new GameObject("Controller");
        GuliangLevel gl = controller.AddComponent<GuliangLevel>();
        gl.openUrlButton = openUrl;
        gl.completeButton = complete;
        gl.hintText = hint;
        gl.experienceUrl = "http://localhost:12393/guliangzhuan";
        gl.remoteUrl = "https://4252434c.r3.cpolar.cn/guliangzhuan";

        Save(scene, "GuliangLevel");
    }

    static void BuildShijingLevel()
    {
        Scene scene = NewScene("ShijingLevel");
        Canvas canvas = CreateCanvas();

        AddBackground(canvas, "shijing_bg");

        CreateText(canvas.transform, "Title", "《诗经》 · 情丝花海", 56, Color.white, new Vector2(0, 300), new Vector2(1200, 90));
        Text count = CreateText(canvas.transform, "CountText", "已集诗魂：0 / 3（风·雅·颂）", 32, Color.white, new Vector2(0, 210), new Vector2(800, 60));
        Text hint = CreateText(canvas.transform, "HintText", "", 28, new Color(1f, 0.9f, 0.5f), new Vector2(0, 130), new Vector2(1400, 60), true);

        GameObject f1 = CreateButton(canvas.transform, "Fragment1", "诗魂", new Vector2(-320, 0), new Vector2(150, 150), 26, true).gameObject;
        GameObject f2 = CreateButton(canvas.transform, "Fragment2", "诗魂", new Vector2(0, 0), new Vector2(150, 150), 26, true).gameObject;
        GameObject f3 = CreateButton(canvas.transform, "Fragment3", "诗魂", new Vector2(320, 0), new Vector2(150, 150), 26, true).gameObject;

        Button back = CreateButton(canvas.transform, "BackButton", "返回地图", new Vector2(0, -220), new Vector2(340, 80));

        GameObject controller = new GameObject("Controller");
        ShijingLevel sl = controller.AddComponent<ShijingLevel>();
        sl.fragments = new GameObject[] { f1, f2, f3 };
        sl.countText = count;
        sl.hintText = hint;
        sl.backButton = back;

        Save(scene, "ShijingLevel");
    }

    static void BuildShangshuLevel()
    {
        Scene scene = NewScene("ShangshuLevel");
        Canvas canvas = CreateCanvas();

        AddBackground(canvas, "shangshu_bg");

        CreateText(canvas.transform, "Title", "《尚书》 · 寻隐问诤臣", 56, Color.white, new Vector2(0, 320), new Vector2(1200, 90));
        Text count = CreateText(canvas.transform, "CountText", "已找到心灵钥匙：0 / 3", 32, Color.white, new Vector2(0, 240), new Vector2(800, 60));

        GameObject f1 = CreateButton(canvas.transform, "Key1", "心灵钥匙", new Vector2(-320, 60), new Vector2(130, 130), 26, true).gameObject;
        GameObject f2 = CreateButton(canvas.transform, "Key2", "心灵钥匙", new Vector2(0, 60), new Vector2(130, 130), 26, true).gameObject;
        GameObject f3 = CreateButton(canvas.transform, "Key3", "心灵钥匙", new Vector2(320, 60), new Vector2(130, 130), 26, true).gameObject;

        Button persuade = CreateButton(canvas.transform, "PersuadeButton", "说服尚书", new Vector2(0, -90), new Vector2(340, 80));

        // 说服对话区（初始隐藏）
        GameObject panel = new GameObject("PersuasionPanel", typeof(RectTransform));
        panel.transform.SetParent(canvas.transform, false);
        RectTransform prt = (RectTransform)panel.transform;
        prt.anchorMin = Vector2.zero;
        prt.anchorMax = Vector2.one;
        prt.offsetMin = Vector2.zero;
        prt.offsetMax = Vector2.zero;

        Text question = CreateText(panel.transform, "QuestionText", "", 34, Color.white, new Vector2(0, 140), new Vector2(1500, 130), true);
        Button o1 = CreateButton(panel.transform, "Option1", "", new Vector2(-360, -30), new Vector2(340, 96), 26, true);
        Button o2 = CreateButton(panel.transform, "Option2", "", new Vector2(0, -30), new Vector2(340, 96), 26, true);
        Button o3 = CreateButton(panel.transform, "Option3", "", new Vector2(360, -30), new Vector2(340, 96), 26, true);
        Text response = CreateText(panel.transform, "ResponseText", "", 30, new Color(1f, 0.9f, 0.5f), new Vector2(0, -160), new Vector2(1400, 110), true);
        Button next = CreateButton(panel.transform, "NextButton", "继续", new Vector2(0, -270), new Vector2(340, 80));

        Button back = CreateButton(canvas.transform, "BackButton", "返回地图", new Vector2(0, -340), new Vector2(340, 80));

        GameObject controller = new GameObject("Controller");
        ShangshuLevel sl = controller.AddComponent<ShangshuLevel>();
        sl.keyFragments = new GameObject[] { f1, f2, f3 };
        sl.countText = count;
        sl.persuadeButton = persuade;
        sl.persuasionPanel = panel;
        sl.questionText = question;
        sl.optionButtons = new Button[] { o1, o2, o3 };
        sl.responseText = response;
        sl.nextButton = next;
        sl.backButton = back;

        Save(scene, "ShangshuLevel");
    }

    static void BuildZuozhuanLevel()
    {
        Scene scene = NewScene("ZuozhuanLevel");
        Canvas canvas = CreateCanvas();

        AddBackground(canvas, "zuozhuan_bg");

        CreateText(canvas.transform, "Title", "《左传》 · 编年迷宫", 56, Color.white, new Vector2(0, 320), new Vector2(1200, 90));
        Text prompt = CreateText(canvas.transform, "PromptText", "", 32, new Color(1f, 0.9f, 0.5f), new Vector2(0, 245), new Vector2(1400, 60));
        Text feedback = CreateText(canvas.transform, "FeedbackText", "", 28, Color.white, new Vector2(0, 195), new Vector2(1400, 60), true);

        GameObject gridGo = new GameObject("GongGrid", typeof(RectTransform));
        gridGo.transform.SetParent(canvas.transform, false);
        RectTransform grt = (RectTransform)gridGo.transform;
        grt.anchorMin = new Vector2(0.5f, 0.5f);
        grt.anchorMax = new Vector2(0.5f, 0.5f);
        grt.anchoredPosition = new Vector2(0, -10);
        grt.sizeDelta = new Vector2(1400, 320);
        GridLayoutGroup grid = gridGo.AddComponent<GridLayoutGroup>();
        grid.cellSize = new Vector2(215, 70);
        grid.spacing = new Vector2(10, 10);
        grid.constraint = GridLayoutGroup.Constraint.FixedColumnCount;
        grid.constraintCount = 6;
        grid.childAlignment = TextAnchor.MiddleCenter;

        Button[] gongs = new Button[12];
        for (int i = 0; i < 12; i++)
            gongs[i] = CreateButton(gridGo.transform, "Gong" + i, "某公", Vector2.zero, new Vector2(215, 70), 28);

        Button back = CreateButton(canvas.transform, "BackButton", "返回地图", new Vector2(0, -290), new Vector2(340, 80));

        GameObject controller = new GameObject("Controller");
        ZuozhuanLevel zl = controller.AddComponent<ZuozhuanLevel>();
        zl.gongButtons = gongs;
        zl.promptText = prompt;
        zl.feedbackText = feedback;
        zl.backButton = back;

        Save(scene, "ZuozhuanLevel");
    }

    static void BuildXiaojingLevel()
    {
        Scene scene = NewScene("XiaojingLevel");
        Canvas canvas = CreateCanvas();

        AddBackground(canvas, "xiaojing_bg");

        CreateText(canvas.transform, "Title", "《孝经》 · 经纶阁四镜", 56, Color.white, new Vector2(0, 320), new Vector2(1200, 90));
        Text plaque = CreateText(canvas.transform, "PlaqueText", "", 30, new Color(1f, 0.9f, 0.5f), new Vector2(0, 160), new Vector2(900, 60));

        Button kneel = CreateButton(canvas.transform, "KneelButton", "跪下拜见", new Vector2(-180, 40), new Vector2(300, 90));
        Button question = CreateButton(canvas.transform, "QuestionButton", "站立发问", new Vector2(180, 40), new Vector2(300, 90));

        Button m0 = CreateButton(canvas.transform, "Mirror0", "", new Vector2(-450, -60), new Vector2(280, 90), 26, true);
        Button m1 = CreateButton(canvas.transform, "Mirror1", "", new Vector2(-150, -60), new Vector2(280, 90), 26, true);
        Button m2 = CreateButton(canvas.transform, "Mirror2", "", new Vector2(150, -60), new Vector2(280, 90), 26, true);
        Button m3 = CreateButton(canvas.transform, "Mirror3", "", new Vector2(450, -60), new Vector2(280, 90), 26, true);

        Text response = CreateText(canvas.transform, "ResponseText", "", 28, Color.white, new Vector2(0, -190), new Vector2(1400, 130), true);
        Button complete = CreateButton(canvas.transform, "CompleteButton", "完成", new Vector2(0, -300), new Vector2(340, 80));
        Button back = CreateButton(canvas.transform, "BackButton", "返回地图", new Vector2(0, -380), new Vector2(340, 80));

        GameObject controller = new GameObject("Controller");
        XiaojingLevel xl = controller.AddComponent<XiaojingLevel>();
        xl.kneelButton = kneel;
        xl.questionButton = question;
        xl.mirrorButtons = new Button[] { m0, m1, m2, m3 };
        xl.plaqueText = plaque;
        xl.responseText = response;
        xl.completeButton = complete;
        xl.backButton = back;

        Save(scene, "XiaojingLevel");
    }

    static void BuildEnding()
    {
        Scene scene = NewScene("Ending");
        Canvas canvas = CreateCanvas();

        AddBackground(canvas, "ending_bg");

        CreateText(canvas.transform, "Title", "终章", 60, Color.white, new Vector2(0, 220), new Vector2(600, 100));
        Text summary = CreateText(canvas.transform, "SummaryText", "", 32, Color.white, new Vector2(0, 20), new Vector2(1200, 200), true);
        Button back = CreateButton(canvas.transform, "BackButton", "返回主菜单", new Vector2(0, -180), new Vector2(340, 80));

        GameObject controller = new GameObject("Controller");
        EndingScreen es = controller.AddComponent<EndingScreen>();
        es.summaryText = summary;
        es.backToMenuButton = back;

        Save(scene, "Ending");
    }

    static void AddBackground(Canvas canvas, string bgName)
    {
        if (canvas == null) return;
        Texture2D tex = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Backgrounds/" + bgName + ".png");
        if (tex == null)
        {
            Debug.LogWarning("[SceneBuilder] 找不到背景 " + bgName + "，跳过。");
            return;
        }

        GameObject go = new GameObject("Background", typeof(RectTransform), typeof(RawImage));
        go.transform.SetParent(canvas.transform, false);
        go.transform.SetSiblingIndex(0); // 最底层
        RectTransform rt = (RectTransform)go.transform;
        rt.anchorMin = Vector2.zero;
        rt.anchorMax = Vector2.one;
        rt.offsetMin = Vector2.zero;
        rt.offsetMax = Vector2.zero;
        RawImage img = go.GetComponent<RawImage>();
        img.texture = tex;
        img.color = Color.white;
        img.raycastTarget = false; // 不挡按钮点击

        // 半透明暗色遮罩，保证白色文字在背景上可读
        GameObject overlayGo = new GameObject("DimOverlay", typeof(RectTransform), typeof(Image));
        overlayGo.transform.SetParent(canvas.transform, false);
        overlayGo.transform.SetSiblingIndex(1);
        RectTransform ort = (RectTransform)overlayGo.transform;
        ort.anchorMin = Vector2.zero;
        ort.anchorMax = Vector2.one;
        ort.offsetMin = Vector2.zero;
        ort.offsetMax = Vector2.zero;
        Image overlay = overlayGo.GetComponent<Image>();
        overlay.color = new Color(0f, 0f, 0f, 0.45f);
        overlay.raycastTarget = false;
    }

    static void AddBGM(string clipName)
    {
        AudioClip clip = AssetDatabase.LoadAssetAtPath<AudioClip>("Assets/Audio/" + clipName + ".wav");
        if (clip == null)
        {
            Debug.LogWarning("[SceneBuilder] 找不到音频 " + clipName + "，跳过 BGM。");
            return;
        }

        GameObject go = new GameObject("BGM");
        AudioSource src = go.AddComponent<AudioSource>();
        src.clip = clip;
        src.loop = true;
        src.playOnAwake = true;
        src.volume = 0.6f;
    }

    static void SetBuildSettings()
    {
        string[] names =
        {
            "MainMenu", "WorldMap",
            "ZhouyiLevel", "ShangshuLevel", "ShijingLevel", "ZhouliLevel",
            "YiliLevel", "LijiLevel", "ZuozhuanLevel", "GongyangLevel",
            "GuliangLevel", "LunyuLevel", "XiaojingLevel", "EryaLevel",
            "MengziLevel", "Ending"
        };
        EditorBuildSettingsScene[] scenes = new EditorBuildSettingsScene[names.Length];
        for (int i = 0; i < names.Length; i++)
            scenes[i] = new EditorBuildSettingsScene("Assets/Scenes/" + names[i] + ".unity", true);
        EditorBuildSettings.scenes = scenes;
    }
}
