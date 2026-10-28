using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// "即将开放"提示面板：点击占位 IP 时弹出，显示"此经典正在唤醒中"。
/// </summary>
public class ComingSoonPanel : MonoBehaviour
{
    public GameObject panel;       // 面板根物体（默认隐藏）
    public Text titleText;         // 标题文字
    public Button closeButton;     // 关闭按钮

    void Awake()
    {
        panel.SetActive(false);
    }

    void Start()
    {
        closeButton.onClick.AddListener(Hide);
    }

    /// <summary>显示面板。</summary>
    public void Show(IPInfo info)
    {
        titleText.text = info.displayName + "：此经典正在唤醒中";
        panel.SetActive(true);
    }

    /// <summary>隐藏面板。</summary>
    public void Hide()
    {
        panel.SetActive(false);
    }
}
