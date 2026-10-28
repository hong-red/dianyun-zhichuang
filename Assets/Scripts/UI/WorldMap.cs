using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 大地图：根据 IPDatabase 动态生成 13 个 IP 按钮（全部可玩）。
/// 点击按钮进入对应关卡；未解锁/占位时（如有）会弹出"即将开放"面板。
/// </summary>
public class WorldMap : MonoBehaviour
{
    public GameObject ipButtonPrefab;      // IP 按钮预制体（带 Button + Text + IPButton 组件）
    public RectTransform buttonContainer;  // 放按钮的容器（建议挂 GridLayoutGroup 自动排列）
    public ComingSoonPanel comingSoonPanel; // "即将开放"面板引用
    public Button toEndingButton;          // "进入结局"按钮

    void Start()
    {
        BuildMap();
        toEndingButton.onClick.AddListener(() => SceneLoader.Load("Ending"));
    }

    void BuildMap()
    {
        IPInfo[] ips = IPDatabase.GetAllIPs();
        foreach (IPInfo ip in ips)
        {
            GameObject go = Instantiate(ipButtonPrefab, buttonContainer);
            IPButton btn = go.GetComponent<IPButton>();
            btn.Init(ip, comingSoonPanel);
        }
    }
}
