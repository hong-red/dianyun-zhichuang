using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 单个 IP 按钮：显示经典名称，点击后按 isPlayable 决定进入关卡还是弹出"即将开放"。
/// 挂在大地图的按钮预制体上（同一个物体还需要 Button 组件，子物体要有 Text）。
/// </summary>
public class IPButton : MonoBehaviour
{
    private IPInfo info;                    // 这个按钮对应的 IP
    private ComingSoonPanel comingSoonPanel; // "即将开放"面板引用
    private Text label;                     // 显示名称的文字

    /// <summary>初始化按钮，由 WorldMap 在创建按钮时调用。</summary>
    public void Init(IPInfo info, ComingSoonPanel comingSoonPanel)
    {
        this.info = info;
        this.comingSoonPanel = comingSoonPanel;
        label = GetComponentInChildren<Text>();

        if (label != null)
            label.text = info.displayName;

        // 根据是否已唤醒 / 是否可玩，调整按钮颜色
        Image img = GetComponent<Image>();
        if (img != null)
        {
            if (GameManager.Instance != null && GameManager.Instance.IsCompleted(info.pinyin))
            {
                img.color = new Color(1f, 0.9f, 0.4f); // 金色：已唤醒
                if (label != null) label.text = info.displayName + " ✓";
            }
            else if (info.isPlayable)
            {
                img.color = new Color(0.75f, 0.9f, 1f); // 淡蓝：可玩
            }
            else
            {
                img.color = new Color(0.55f, 0.55f, 0.55f); // 灰色：占位
            }
        }

        // 自动绑定点击事件
        GetComponent<Button>().onClick.AddListener(OnClick);
    }

    /// <summary>点击处理：可玩进关卡，占位弹"即将开放"。</summary>
    public void OnClick()
    {
        if (info == null) return;

        if (!info.isPlayable)
        {
            comingSoonPanel.Show(info);
        }
        else
        {
            if (info.loadAsync)
                SceneLoader.LoadAsync(info.sceneName);
            else
                SceneLoader.Load(info.sceneName);
        }
    }
}
