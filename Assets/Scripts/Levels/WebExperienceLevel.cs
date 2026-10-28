using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using Gree.UnityWebView;

/// <summary>
/// 内嵌网页体验关卡的基类：在游戏内全屏显示网页（gree/unity-webview，Windows 用 WebView2）。
/// 点按钮显示带进度条的加载页；加载完成显示网页；按 Esc 关闭网页返回关卡界面。
/// </summary>
public abstract class WebExperienceLevel : MonoBehaviour
{
    public Button openUrlButton;   // 打开体验按钮
    public Button completeButton;  // 完成按钮
    public Text hintText;          // 提示文字（可选）
    public string experienceUrl = "http://localhost:12393/gongyangzhuan"; // 本地体验页地址（快）
    public string remoteUrl = "https://4252434c.r3.cpolar.cn/gongyangzhuan"; // 公网地址（慢，兜底）

    /// <summary>过关时标记的 IP 拼音。</summary>
    protected abstract string CompletedPinyin { get; }
    /// <summary>提示文字。</summary>
    protected abstract string HintMessage { get; }

    private WebViewObject webViewObject;
    private bool webViewVisible;
    private bool webViewLoaded;

    // 加载进度条 UI
    private GameObject loadingPanel;
    private Image loadingFill;
    private Text loadingText;

    void Start()
    {
        if (hintText != null)
            hintText.text = HintMessage + "\n（体验页打开后按 Esc 键关闭，再点「返回地图」离开）";

        openUrlButton.onClick.AddListener(OpenExperience);

        // 「完成」按钮已移除，隐藏它
        if (completeButton != null)
            completeButton.gameObject.SetActive(false);

        // 注意：WebView 改成点按钮时才创建（懒加载），避免关卡一进来就被白色 bg 盖住
        CreateLoadingUI();
        CreateBackButton();
    }

    /// <summary>补一个「返回地图」按钮（替代已移除的「完成」按钮；WebView 打开时会被盖住，Esc 关闭后再点）。</summary>
    void CreateBackButton()
    {
        Canvas canvas = FindObjectOfType<Canvas>();
        if (canvas == null) return;

        GameObject go = new GameObject("BackButton", typeof(RectTransform), typeof(Image), typeof(Button));
        go.transform.SetParent(canvas.transform, false);
        RectTransform rt = (RectTransform)go.transform;
        rt.anchorMin = new Vector2(0.5f, 0.5f);
        rt.anchorMax = new Vector2(0.5f, 0.5f);
        rt.anchoredPosition = new Vector2(0, -160);
        rt.sizeDelta = new Vector2(400, 90);

        Image img = go.GetComponent<Image>();
        img.color = Color.white; // 白色背景，与其它按钮一致（运行时无内置 UISprite 可用）

        Button btn = go.GetComponent<Button>();
        btn.targetGraphic = img;

        GameObject lbl = new GameObject("Text", typeof(RectTransform));
        lbl.transform.SetParent(go.transform, false);
        Text t = lbl.AddComponent<Text>();
        t.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        t.text = "返回地图";
        t.fontSize = 30;
        t.color = new Color(0.1f, 0.1f, 0.1f, 1f);
        t.alignment = TextAnchor.MiddleCenter;
        t.horizontalOverflow = HorizontalWrapMode.Overflow;
        t.verticalOverflow = VerticalWrapMode.Overflow;
        RectTransform lrt = (RectTransform)lbl.transform;
        lrt.anchorMin = Vector2.zero;
        lrt.anchorMax = Vector2.one;
        lrt.offsetMin = Vector2.zero;
        lrt.offsetMax = Vector2.zero;

        btn.onClick.AddListener(() => LevelFlow.Complete(CompletedPinyin));
    }

    void Update()
    {
        // Esc 关闭网页（WebView2 纹理显示在最上层，会盖住 UGUI 按钮，所以用键盘关闭）
        if (webViewVisible && Input.GetKeyDown(KeyCode.Escape))
            CloseExperience();
    }

    void OpenExperience()
    {
        if (webViewObject == null)
            CreateWebView();
        StartCoroutine(OpenExperienceCoroutine());
    }

    IEnumerator OpenExperienceCoroutine()
    {
        ShowLoading(true);
        SetLoadingProgress(0.05f, "正在启动本地服务…");

        // 等本地服务就绪（服务由 LocalServerLauncher 自动启动，首次冷启动加载模型较慢，放宽到 60s）
        float timeout = 60f;
        float elapsed = 0f;
        while (!LocalServerLauncher.IsReady() && elapsed < timeout)
        {
            SetLoadingProgress(0.05f + 0.35f * (elapsed / timeout), "正在启动本地服务…");
            elapsed += Time.deltaTime;
            yield return null;
        }

        // 双通道：本地就绪用本地（快），否则兜底用公网 cpolar（慢但可用）
        bool localReady = LocalServerLauncher.IsReady();
        string url = localReady ? experienceUrl : remoteUrl;
        if (string.IsNullOrEmpty(url))
            url = experienceUrl;
        Debug.Log("[WebExperienceLevel] 使用" + (localReady ? "本地" : "公网") + "地址：" + url);

        if (webViewObject == null)
        {
            ShowLoading(false);
            yield break;
        }

        // 先加载（隐藏），等页面加载完 + 给 WebGL(SwiftShader) 一点首帧时间，再显示，避免第一次白屏
        SetLoadingProgress(0.4f, "正在加载网页…");
        webViewLoaded = false;
        webViewObject.LoadURL(url);

        float loadTimeout = 30f;
        float waited = 0f;
        while (!webViewLoaded && waited < loadTimeout)
        {
            SetLoadingProgress(0.4f + 0.5f * (waited / loadTimeout), "正在加载网页…");
            waited += Time.deltaTime;
            yield return null;
        }

        SetLoadingProgress(0.95f, "正在渲染 Live2D…");
        yield return new WaitForSeconds(3f);

        SetLoadingProgress(1f, "");
        webViewObject.SetVisibility(true);
        webViewVisible = true;
        ShowLoading(false);
    }

    void CloseExperience()
    {
        if (webViewObject != null)
            webViewObject.SetVisibility(false);
        webViewVisible = false;
    }

    void ShowLoading(bool show)
    {
        if (loadingPanel != null)
            loadingPanel.SetActive(show);
    }

    void SetLoadingProgress(float p, string msg)
    {
        if (loadingFill != null)
            loadingFill.fillAmount = Mathf.Clamp01(p);
        if (loadingText != null && !string.IsNullOrEmpty(msg))
            loadingText.text = msg;
    }

    void CreateLoadingUI()
    {
        Canvas canvas = FindObjectOfType<Canvas>();
        if (canvas == null) return;

        // 全屏遮罩（挡住点击）
        GameObject panel = new GameObject("LoadingPanel", typeof(RectTransform), typeof(Image));
        panel.transform.SetParent(canvas.transform, false);
        RectTransform prt = (RectTransform)panel.transform;
        prt.anchorMin = Vector2.zero;
        prt.anchorMax = Vector2.one;
        prt.offsetMin = Vector2.zero;
        prt.offsetMax = Vector2.zero;
        Image panelImg = panel.GetComponent<Image>();
        panelImg.color = new Color(0f, 0f, 0f, 0.75f);
        panelImg.raycastTarget = true;
        loadingPanel = panel;

        // 进度条背景
        GameObject barBg = new GameObject("BarBg", typeof(RectTransform), typeof(Image));
        barBg.transform.SetParent(panel.transform, false);
        RectTransform brt = (RectTransform)barBg.transform;
        brt.anchorMin = new Vector2(0.5f, 0.5f);
        brt.anchorMax = new Vector2(0.5f, 0.5f);
        brt.anchoredPosition = new Vector2(0, -60);
        brt.sizeDelta = new Vector2(640, 32);
        barBg.GetComponent<Image>().color = new Color(1f, 1f, 1f, 0.25f);

        // 进度条填充
        GameObject fill = new GameObject("Fill", typeof(RectTransform), typeof(Image));
        fill.transform.SetParent(barBg.transform, false);
        RectTransform frt = (RectTransform)fill.transform;
        frt.anchorMin = Vector2.zero;
        frt.anchorMax = Vector2.one;
        frt.offsetMin = Vector2.zero;
        frt.offsetMax = Vector2.zero;
        loadingFill = fill.GetComponent<Image>();
        loadingFill.type = Image.Type.Filled;
        loadingFill.fillMethod = Image.FillMethod.Horizontal;
        loadingFill.fillOrigin = 0;
        loadingFill.fillAmount = 0f;
        loadingFill.color = new Color(0.35f, 0.8f, 1f, 1f);

        // 文字
        GameObject textGo = new GameObject("LoadingText", typeof(RectTransform));
        textGo.transform.SetParent(panel.transform, false);
        RectTransform trt = (RectTransform)textGo.transform;
        trt.anchorMin = new Vector2(0.5f, 0.5f);
        trt.anchorMax = new Vector2(0.5f, 0.5f);
        trt.anchoredPosition = new Vector2(0, 20);
        trt.sizeDelta = new Vector2(900, 60);
        loadingText = textGo.AddComponent<Text>();
        loadingText.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        loadingText.alignment = TextAnchor.MiddleCenter;
        loadingText.fontSize = 28;
        loadingText.color = Color.white;
        loadingText.text = "加载中…";

        loadingPanel.SetActive(false);
    }

    void CreateWebView()
    {
        Canvas canvas = FindObjectOfType<Canvas>();
        GameObject go = new GameObject("WebViewObject");
        webViewObject = go.AddComponent<WebViewObject>();
        webViewObject.canvas = canvas != null ? canvas.gameObject : null;

        webViewObject.Init(
            cb: (msg) => Debug.Log("[WebView] JS: " + msg),
            err: (msg) => Debug.Log("[WebView] Error: " + msg),
            httpErr: (msg) => Debug.Log("[WebView] HttpError: " + msg),
            started: (msg) => Debug.Log("[WebView] Started: " + msg),
            ld: (msg) => { webViewLoaded = true; Debug.Log("[WebView] Loaded: " + msg); },
            enableWKWebView: true
        );

        webViewObject.SetMargins(0, 0, 0, 0);
        webViewObject.SetVisibility(false);

        // WebView2 离屏截图很费性能，降低截图频率（每 3 帧一次）来提 FPS
        webViewObject.bitmapRefreshCycle = 3;
    }
}
