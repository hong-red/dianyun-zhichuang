using System.IO;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

/// <summary>
/// 打包后自动把项目根目录的 server 文件夹（Open-LLM-VTuber 前后端）
/// 复制到构建输出目录，让比赛提交的构建自带本地服务。
/// </summary>
public class BuildPostProcessor : IPostprocessBuildWithReport
{
    public int callbackOrder => 0;

    public void OnPostprocessBuild(BuildReport report)
    {
        string projectDir = Path.GetDirectoryName(Application.dataPath);
        string serverSrc = Path.Combine(projectDir, "server");
        if (!Directory.Exists(serverSrc))
        {
            Debug.LogWarning("[BuildPostProcessor] 未找到 " + serverSrc + "，跳过复制。");
            return;
        }

        string buildDir = Path.GetDirectoryName(report.summary.outputPath);
        string serverDst = Path.Combine(buildDir, "server");

        if (Directory.Exists(serverDst))
            Directory.Delete(serverDst, true);

        FileUtil.CopyFileOrDirectory(serverSrc, serverDst);
        Debug.Log("[BuildPostProcessor] 已把 server 复制到构建目录：" + serverDst);
    }
}
