using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// 场景加载器：Load 同步、LoadAsync 异步，均无进度条、无后台预加载。
/// 保留 MonoBehaviour 形态（场景里可能挂有该组件），实际调用走静态方法。
/// </summary>
public class SceneLoader : MonoBehaviour
{
    /// <summary>同步加载场景。</summary>
    public static void Load(string sceneName)
    {
        if (!Check(sceneName)) return;
        SceneManager.LoadScene(sceneName);
    }

    /// <summary>异步加载场景（无进度条，加载完成后自动切换）。用于较重的 Live2D 关卡。</summary>
    public static void LoadAsync(string sceneName)
    {
        if (!Check(sceneName)) return;
        SceneManager.LoadSceneAsync(sceneName, LoadSceneMode.Single);
    }

    static bool Check(string sceneName)
    {
        if (string.IsNullOrEmpty(sceneName))
        {
            Debug.LogError("[SceneLoader] 场景名为空，无法加载。");
            return false;
        }
        if (!Application.CanStreamedLevelBeLoaded(sceneName))
        {
            Debug.LogError("[SceneLoader] 场景「" + sceneName + "」未加入 Build Settings，请到 File → Build Settings 添加。");
            return false;
        }
        return true;
    }
}
