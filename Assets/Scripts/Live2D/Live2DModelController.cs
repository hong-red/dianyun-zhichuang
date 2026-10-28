using System.Collections;
using System.IO;
using UnityEngine;
using UnityEngine.UI;
#if LIVE2D_CUBISM
using Live2D.Cubism.Core;
using Live2D.Cubism.Framework.Json;
#endif

/// <summary>
/// 运行时加载并显示《公羊传》立绘。
///
/// - 若项目里定义了 LIVE2D_CUBISM 宏（即已导入 Live2D Cubism SDK for Unity）：
///   用 SDK 原生渲染 Live2D（眨眼/呼吸/眼珠游移）。
/// - 若没有导入 SDK：退化为显示一张静态立绘（Resources/Portraits），保证游戏能编译、
///   不白屏。导入 SDK 后，在 Player Settings 加 LIVE2D_CUBISM 宏即可切换到动态 Live2D。
/// </summary>
public class Live2DModelController : MonoBehaviour
{
    [Header("模型路径（相对 StreamingAssets，仅 SDK 模式使用）")]
    public string model3JsonPath = "Live2D/Gongyangzhuan/gongyangzhuan.model3.json";

    [Header("SDK 模式显示")]
    [Tooltip("模型专用相机（正交）的 orthographicSize，决定可见世界高度的一半")]
    public float cameraSize = 6f;
    [Tooltip("模型应占相机可视高度的比例（0~1），自动缩放会套用它")]
    public float targetHeightFill = 0.82f;
    [Tooltip("自动缩放前的初始缩放（会被 autoFit 覆盖）")]
    public float modelScale = 0.01f;
    [Tooltip("模型中心相对屏幕中心的偏移（世界单位）")]
    public Vector2 modelOffset = new Vector2(0f, -0.4f);

    [Header("SDK 模式动画")]
    public bool enableBlink = true;
    public float blinkInterval = 3.2f;
    public float blinkDuration = 0.12f;
    public bool enableBreath = true;
    public float breathSpeed = 1.1f;
    public float breathAmount = 0.35f;
    public bool enableIdleLook = true;
    public float lookRange = 0.35f;
    public bool autoLipSync = false;

    [Header("无 SDK 时的静态立绘")]
    [Tooltip("相对 Resources 的路径，无扩展名")]
    public string fallbackPortraitPath = "Portraits/gongyangzhuan_portrait";
    [Tooltip("静态立绘占屏幕高度的比例")]
    public float fallbackHeightFill = 0.7f;

    void Start()
    {
#if LIVE2D_CUBISM
        LoadModel();
#else
        ShowFallbackPortrait();
#endif
    }

#if LIVE2D_CUBISM
    public CubismModel Model { get; private set; }

    // 结构：本物体(不缩放) → ModelRoot(缩放) → 模型；相机与 ModelRoot 平级，避免相机被缩放。
    private Transform modelRoot;
    private Camera modelCamera;

    private CubismParameter eyeLOpen;
    private CubismParameter eyeROpen;
    private CubismParameter mouthOpenY;
    private CubismParameter breath;
    private CubismParameter eyeBallX;
    private CubismParameter eyeBallY;

    private float blinkTimer;
    private float nextBlinkIn;
    private bool blinking;
    private float lookTimer;

    void LoadModel()
    {
        string full = Path.Combine(Application.streamingAssetsPath, model3JsonPath);
        if (!File.Exists(full))
        {
            Debug.LogError("[Live2DModelController] 找不到模型文件：" + full);
            return;
        }

        CubismModel3Json model3Json = CubismModel3Json.LoadAtPath(full);
        Model = model3Json.ToModel();

        modelRoot = new GameObject("ModelRoot").transform;
        modelRoot.SetParent(transform, false);
        modelRoot.localPosition = new Vector3(modelOffset.x, modelOffset.y, 0f);
        modelRoot.localScale = Vector3.one * modelScale;
        Model.transform.SetParent(modelRoot, false);

        CacheParameters();
        SetupRenderToUI();
        StartCoroutine(AutoFit());

        Debug.Log("[Live2DModelController] Live2D 模型加载完成：" + Model.name);
    }

    void CacheParameters()
    {
        eyeLOpen = FindParam("ParamEyeLOpen");
        eyeROpen = FindParam("ParamEyeROpen");
        mouthOpenY = FindParam("ParamMouthOpenY");
        breath = FindParam("ParamBreath");
        eyeBallX = FindParam("ParamEyeBallX");
        eyeBallY = FindParam("ParamEyeBallY");
    }

    CubismParameter FindParam(string id)
    {
        if (Model == null || Model.Parameters == null) return null;
        foreach (CubismParameter p in Model.Parameters)
            if (p.Id == id) return p;
        return null;
    }

    void SetupRenderToUI()
    {
        Canvas canvas = FindObjectOfType<Canvas>();
        if (canvas == null)
        {
            Debug.LogWarning("[Live2DModelController] 场景里没有 Canvas，模型将直接渲染在 3D 世界里。");
            return;
        }

        int w = Screen.width > 0 ? Screen.width : 1920;
        int h = Screen.height > 0 ? Screen.height : 1080;
        RenderTexture rt = new RenderTexture(w, h, 24, RenderTextureFormat.ARGB32);
        rt.Create();

        GameObject camGo = new GameObject("Live2DCamera", typeof(Camera));
        camGo.transform.SetParent(transform, false);
        camGo.transform.localPosition = new Vector3(0f, 0f, -10f);
        modelCamera = camGo.GetComponent<Camera>();
        modelCamera.orthographic = true;
        modelCamera.orthographicSize = cameraSize;
        modelCamera.clearFlags = CameraClearFlags.SolidColor;
        modelCamera.backgroundColor = new Color(0f, 0f, 0f, 0f);
        modelCamera.cullingMask = 1 << LayerMask.NameToLayer("Default");
        modelCamera.targetTexture = rt;
        modelCamera.enabled = true;

        GameObject imgGo = new GameObject("Live2DImage", typeof(RectTransform), typeof(RawImage));
        imgGo.transform.SetParent(canvas.transform, false);
        RectTransform irt = (RectTransform)imgGo.transform;
        irt.anchorMin = Vector2.zero;
        irt.anchorMax = Vector2.one;
        irt.offsetMin = Vector2.zero;
        irt.offsetMax = Vector2.zero;
        RawImage img = imgGo.GetComponent<RawImage>();
        img.texture = rt;
        img.color = Color.white;
        img.raycastTarget = false;
        imgGo.transform.SetSiblingIndex(2);
    }

    IEnumerator AutoFit()
    {
        for (int i = 0; i < 4; i++) yield return null;
        if (Model == null || modelRoot == null) yield break;

        Bounds b = ComputeRendererBounds();
        if (b.size.y < 0.0001f) yield break;

        float targetWorldHeight = cameraSize * 2f * targetHeightFill;
        float factor = targetWorldHeight / b.size.y;
        modelRoot.localScale *= factor;

        yield return null;
        b = ComputeRendererBounds();
        Vector3 delta = (Vector3)modelOffset - b.center;
        delta.z = 0f;
        modelRoot.position += delta;
    }

    Bounds ComputeRendererBounds()
    {
        Renderer[] rs = modelRoot != null
            ? modelRoot.GetComponentsInChildren<Renderer>()
            : GetComponentsInChildren<Renderer>();
        Bounds b = new Bounds(transform.position, Vector3.zero);
        bool has = false;
        foreach (Renderer r in rs)
        {
            if (r.bounds.size.sqrMagnitude < 0.0001f) continue;
            if (!has) { b = r.bounds; has = true; }
            else b.Encapsulate(r.bounds);
        }
        return b;
    }

    void Update()
    {
        if (Model == null) return;

        if (enableBlink) UpdateBlink();
        if (enableBreath) UpdateBreath();
        if (enableIdleLook) UpdateIdleLook();
        if (autoLipSync) SetMouthOpen(Mathf.Abs(Mathf.Sin(Time.time * 4f)) * 0.5f);
    }

    void UpdateBlink()
    {
        nextBlinkIn -= Time.deltaTime;
        if (!blinking && nextBlinkIn <= 0f)
        {
            blinking = true;
            blinkTimer = 0f;
        }

        float open;
        if (blinking)
        {
            blinkTimer += Time.deltaTime;
            float t = Mathf.Clamp01(blinkTimer / blinkDuration);
            open = Mathf.Cos(t * Mathf.PI) * 0.5f + 0.5f;
            if (t >= 1f)
            {
                blinking = false;
                open = 1f;
                nextBlinkIn = blinkInterval * Random.Range(0.6f, 1.4f);
            }
        }
        else
        {
            open = 1f;
        }
        if (eyeLOpen != null) eyeLOpen.Value = open;
        if (eyeROpen != null) eyeROpen.Value = open;
    }

    void UpdateBreath()
    {
        if (breath != null)
            breath.Value = (Mathf.Sin(Time.time * breathSpeed * 2f * Mathf.PI) * 0.5f + 0.5f) * breathAmount;
    }

    void UpdateIdleLook()
    {
        lookTimer -= Time.deltaTime;
        if (lookTimer <= 0f)
        {
            lookTimer = Random.Range(1.5f, 3.5f);
            SetLookAt(new Vector2(Random.Range(-1f, 1f), Random.Range(-1f, 1f)));
        }
    }

    /// <summary>设置口型开合（0=闭，1=全开）。TTS 播放时按音量调用即可。</summary>
    public void SetMouthOpen(float value)
    {
        if (mouthOpenY != null) mouthOpenY.Value = Mathf.Clamp01(value);
    }

    /// <summary>设置眼珠朝向（-1..1，x 水平 y 垂直）。</summary>
    public void SetLookAt(Vector2 normalized)
    {
        if (eyeBallX != null) eyeBallX.Value = normalized.x * lookRange;
        if (eyeBallY != null) eyeBallY.Value = normalized.y * lookRange;
    }

#else
    // ===== 无 SDK：静态立绘降级 =====

    void ShowFallbackPortrait()
    {
        Texture2D tex = Resources.Load<Texture2D>(fallbackPortraitPath);
        Canvas canvas = FindObjectOfType<Canvas>();
        if (tex == null || canvas == null)
        {
            Debug.LogWarning("[Live2DModelController] 未导入 Cubism SDK，且找不到立绘 " + fallbackPortraitPath
                + "。导入 SDK 后加 LIVE2D_CUBISM 宏即可显示动态 Live2D。");
            return;
        }

        GameObject imgGo = new GameObject("Live2DFallbackImage", typeof(RectTransform), typeof(RawImage));
        imgGo.transform.SetParent(canvas.transform, false);
        RectTransform rt = (RectTransform)imgGo.transform;
        rt.anchorMin = new Vector2(0.5f, 0.5f);
        rt.anchorMax = new Vector2(0.5f, 0.5f);
        rt.anchoredPosition = new Vector2(0f, -30f);

        float targetHeight = (Screen.height > 0 ? Screen.height : 1080f) * fallbackHeightFill;
        float scale = targetHeight / Mathf.Max(1, tex.height);
        rt.sizeDelta = new Vector2(tex.width * scale, tex.height * scale);

        RawImage img = imgGo.GetComponent<RawImage>();
        img.texture = tex;
        img.color = Color.white;
        img.raycastTarget = false;
        imgGo.transform.SetSiblingIndex(2);
    }
#endif
}
