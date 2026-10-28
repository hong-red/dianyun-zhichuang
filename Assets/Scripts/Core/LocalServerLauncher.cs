using System.Diagnostics;
using System.IO;
using System.Net.NetworkInformation;
using UnityEngine;
using Debug = UnityEngine.Debug;

/// <summary>
/// 游戏启动时自动拉起 Open-LLM-VTuber 服务，让游戏直接连 localhost，无需手动开服务器。
/// 服务目录查找顺序：Inspector 手动指定的 serverProjectPath → externalServerPath（外部项目）
/// → 「游戏目录/server」（打包部署时的内置副本）。
/// 挂在 MainMenu 的 GameManager 物体上，跨场景保留。
/// </summary>
public class LocalServerLauncher : MonoBehaviour
{
    [Tooltip("Open-LLM-VTuber 项目目录。留空则按「外部目录 → 游戏目录/server」顺序自动查找")]
    public string serverProjectPath = "";

    [Tooltip("外部 Open-LLM-VTuber 项目目录（开发时优先使用这里）")]
    public string externalServerPath = @"F:\数字人\Open-LLM-VTuber";

    [Tooltip("启动命令，默认用 uv（需在系统 PATH 中）")]
    public string launcherCommand = "uv";

    [Tooltip("启动参数")]
    public string launcherArgs = "run run_server.py";

    private const int ServerPort = 12393;

    private Process serverProcess;
    private bool startedByGame;

    void Awake()
    {
        DontDestroyOnLoad(gameObject);
        ResolveServerPath();
        StartServer();
    }

    /// <summary>
    /// 保证从任意关卡场景直接 Play（不经过 MainMenu）时也会自动拉起本地服务。
    /// 若场景里已有 LocalServerLauncher（如 MainMenu 的 GameManager），则复用、不重复创建。
    /// </summary>
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    static void EnsureServerLauncherExists()
    {
        if (FindObjectOfType<LocalServerLauncher>() == null)
        {
            GameObject go = new GameObject("LocalServerLauncher");
            go.AddComponent<LocalServerLauncher>();
        }
    }

    void ResolveServerPath()
    {
        if (!string.IsNullOrEmpty(serverProjectPath))
            return; // 已在 Inspector 手动指定（最优先）

        // 1) 优先用外部 Open-LLM-VTuber 项目（开发时直接连这里，不改游戏内置副本）
        if (!string.IsNullOrEmpty(externalServerPath) && Directory.Exists(externalServerPath))
        {
            serverProjectPath = externalServerPath;
            Debug.Log("[LocalServerLauncher] 使用外部服务目录：" + externalServerPath);
            return;
        }

        // 2) 回退：游戏目录下的 server 副本（打包部署时用）
        string gameDir = Path.GetDirectoryName(Application.dataPath);
        string serverDir = Path.Combine(gameDir, "server");

        if (Directory.Exists(serverDir))
        {
            serverProjectPath = serverDir;
            Debug.Log("[LocalServerLauncher] 使用内置服务目录：" + serverDir);
        }
        else
        {
            Debug.LogError("[LocalServerLauncher] 未找到服务目录（外部 " + externalServerPath
                + " 和内置 " + serverDir + " 都不存在），请在 Inspector 手动设置 serverProjectPath。");
        }
    }

    void StartServer()
    {
        if (string.IsNullOrEmpty(serverProjectPath) || !Directory.Exists(serverProjectPath))
        {
            Debug.LogError("[LocalServerLauncher] 服务目录不存在，无法启动：" + serverProjectPath);
            return;
        }

        if (IsReady())
        {
            Debug.Log("[LocalServerLauncher] 本地服务已在运行（端口 " + ServerPort + "），跳过启动。");
            return;
        }

        try
        {
            // 启动方式：优先用打包好的独立服务器 exe（完整单机包），
            // 找不到时回退到 uv run run_server.py（开发模式）。
            string bundledExe = Path.Combine(serverProjectPath, "run_server", "run_server.exe");
            string command;
            string args;
            if (File.Exists(bundledExe))
            {
                command = bundledExe;
                args = "";
            }
            else
            {
                command = launcherCommand; // 默认 "uv"
                args = launcherArgs;       // 默认 "run run_server.py"
            }

            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = command,
                Arguments = args,
                WorkingDirectory = serverProjectPath,
                UseShellExecute = false,
                CreateNoWindow = true,
            };

            // 绕过 Windows 系统代理直连 DeepSeek（国内服务），否则 httpx 会走系统代理导致 LLM 连不上
            psi.EnvironmentVariables["NO_PROXY"] = "api.deepseek.com,localhost,127.0.0.1";
            psi.EnvironmentVariables["no_proxy"] = "api.deepseek.com,localhost,127.0.0.1";

            serverProcess = Process.Start(psi);
            startedByGame = true;
            Debug.Log("[LocalServerLauncher] 已启动本地服务：" + command + " " + args);
        }
        catch (System.Exception e)
        {
            Debug.LogError("[LocalServerLauncher] 启动本地服务失败：" + e.Message);
        }
    }

    /// <summary>本地服务是否已就绪（端口被监听）。</summary>
    public static bool IsReady()
    {
        try
        {
            IPGlobalProperties props = IPGlobalProperties.GetIPGlobalProperties();
            foreach (var ep in props.GetActiveTcpListeners())
                if (ep.Port == ServerPort)
                    return true;
        }
        catch
        {
            // 忽略，视为未就绪
        }
        return false;
    }

    void OnApplicationQuit()
    {
        if (!startedByGame || serverProcess == null) return;

        // 退出时关闭由游戏拉起的服务，避免残留。
        // uv 会派生 python 子进程，直接 Kill() 只杀 uv 父进程、子进程会变孤儿（占着 12393 端口），
        // 所以用 taskkill /T 杀掉整棵进程树。
        try
        {
            if (!serverProcess.HasExited)
            {
                ProcessStartInfo psi = new ProcessStartInfo
                {
                    FileName = "taskkill",
                    Arguments = "/T /F /PID " + serverProcess.Id,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                };
                using (Process killer = Process.Start(psi))
                {
                    killer.WaitForExit(5000);
                }
            }
        }
        catch
        {
            // 兜底：taskkill 失败时仍尝试直接杀父进程
            try { if (!serverProcess.HasExited) serverProcess.Kill(); } catch { }
        }
    }
}
