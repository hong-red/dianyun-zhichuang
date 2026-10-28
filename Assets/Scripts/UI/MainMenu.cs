using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 主菜单：开始游戏进入大地图，退出关闭程序。
/// </summary>
public class MainMenu : MonoBehaviour
{
    public Button startButton;   // 开始游戏按钮
    public Button quitButton;    // 退出按钮

    void Start()
    {
        startButton.onClick.AddListener(() => SceneLoader.Load("WorldMap"));
        quitButton.onClick.AddListener(() => Application.Quit());
    }
}
