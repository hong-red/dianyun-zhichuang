using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

/// <summary>
/// 为缺少背景的关卡补上背景图（Background + DimOverlay）。
/// 只做「补充」，不覆盖场景里已有的任何东西；用于别人给的场景里没图的情况。
/// 菜单：Tools/十三经/Add Missing Backgrounds
/// </summary>
public static class AddMissingBackgrounds
{
    [MenuItem("Tools/十三经/Add Missing Backgrounds")]
    public static void Run()
    {
        string[] names = {
            "ZhouyiLevel", "ShangshuLevel", "ZhouliLevel", "YiliLevel",
            "LijiLevel", "ZuozhuanLevel", "XiaojingLevel", "EryaLevel", "MengziLevel"
        };
        string[] bgs = {
            "zhouyi_bg", "shangshu_bg", "zhouli_bg", "yili_bg",
            "liji_bg", "zuozhuan_bg", "xiaojing_bg", "erya_bg", "mengzi_bg"
        };

        // 有未保存改动先让用户决定，避免丢东西
        if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
        {
            Debug.LogWarning("[AddMissingBackgrounds] 已取消。");
            return;
        }

        int added = 0;
        for (int i = 0; i < names.Length; i++)
        {
            string scenePath = "Assets/Scenes/" + names[i] + ".unity";
            if (!File.Exists(scenePath))
            {
                Debug.LogWarning("[AddMissingBackgrounds] 场景不存在：" + scenePath);
                continue;
            }

            Scene scene = EditorSceneManager.OpenScene(scenePath, OpenSceneMode.Single);
            Canvas canvas = Object.FindObjectOfType<Canvas>();
            if (canvas == null)
            {
                Debug.LogWarning("[AddMissingBackgrounds] " + names[i] + " 没有 Canvas，跳过。");
                continue;
            }
            if (canvas.transform.Find("Background") != null)
            {
                Debug.Log("[AddMissingBackgrounds] " + names[i] + " 已有背景，跳过。");
                continue;
            }

            Texture2D tex = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Backgrounds/" + bgs[i] + ".png");
            if (tex == null)
            {
                Debug.LogWarning("[AddMissingBackgrounds] 找不到背景图 " + bgs[i] + ".png，跳过。");
                continue;
            }

            AddBackground(canvas.transform, tex);
            EditorSceneManager.SaveScene(scene);
            added++;
        }

        Debug.Log("[AddMissingBackgrounds] 完成，共补充 " + added + " 个场景的背景。");
    }

    static void AddBackground(Transform canvasRoot, Texture2D tex)
    {
        // 背景图（最底层，不挡点击）
        GameObject bg = new GameObject("Background", typeof(RectTransform), typeof(RawImage));
        bg.transform.SetParent(canvasRoot, false);
        bg.transform.SetSiblingIndex(0);
        RectTransform rt = (RectTransform)bg.transform;
        rt.anchorMin = Vector2.zero;
        rt.anchorMax = Vector2.one;
        rt.offsetMin = Vector2.zero;
        rt.offsetMax = Vector2.zero;
        RawImage img = bg.GetComponent<RawImage>();
        img.texture = tex;
        img.color = Color.white;
        img.raycastTarget = false;

        // 半透明暗色遮罩，保证白字在背景上可读
        GameObject overlay = new GameObject("DimOverlay", typeof(RectTransform), typeof(Image));
        overlay.transform.SetParent(canvasRoot, false);
        overlay.transform.SetSiblingIndex(1);
        RectTransform ort = (RectTransform)overlay.transform;
        ort.anchorMin = Vector2.zero;
        ort.anchorMax = Vector2.one;
        ort.offsetMin = Vector2.zero;
        ort.offsetMax = Vector2.zero;
        Image ov = overlay.GetComponent<Image>();
        ov.color = new Color(0f, 0f, 0f, 0.45f);
        ov.raycastTarget = false;
    }
}
