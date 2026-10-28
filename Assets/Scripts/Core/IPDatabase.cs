using System.Collections.Generic;

/// <summary>
/// 十三部经典的静态数据库（13 个 IP，全部可玩）。
/// 2 个 Live2D 关卡（公羊传 / 谷梁传）保留原有体验页玩法，
/// 其余 11 部经典各对应一个独立的剧情关卡。
/// 框架按 13 个 IP 设计；WorldMap、结局计数等全部自动适配。
/// </summary>
public static class IPDatabase
{
    // 13 个 IP 的数据（按《十三经》通行顺序排列）
    private static readonly IPInfo[] allIPs = new IPInfo[]
    {
        new IPInfo { pinyin = "zhouyi", displayName = "周易", isPlayable = true, sceneName = "ZhouyiLevel", backgroundImage = "zhouyi_bg", description = "典籍大陆的引路人，理性通透的智者，被历代注本撕裂为八个碎片。" },
        new IPInfo { pinyin = "shangshu", displayName = "尚书", isPlayable = true, sceneName = "ShangshuLevel", backgroundImage = "shangshu_bg", description = "上古政令与史事的汇编，孤傲的治国诤臣。" },
        new IPInfo { pinyin = "shijing", displayName = "诗经", isPlayable = true, sceneName = "ShijingLevel", backgroundImage = "shijing_bg", description = "记忆歌者，以诗歌守护众生的情感记忆。" },
        new IPInfo { pinyin = "zhouli", displayName = "周礼", isPlayable = true, sceneName = "ZhouliLevel", backgroundImage = "zhouli_bg", description = "礼之家族族长，周公致太平之书，详述六官之制。" },
        new IPInfo { pinyin = "yili", displayName = "仪礼", isPlayable = true, sceneName = "YiliLevel", backgroundImage = "yili_bg", description = "详载士人礼仪程序，重形式与仪节。" },
        new IPInfo { pinyin = "liji", displayName = "礼记", isPlayable = true, sceneName = "LijiLevel", backgroundImage = "liji_bg", description = "阐发礼之义理，「礼者，理也」的礼学著作。" },
        new IPInfo { pinyin = "zuozhuan", displayName = "左传", isPlayable = true, sceneName = "ZuozhuanLevel", backgroundImage = "zuozhuan_bg", description = "以史实解《春秋》，求真务实的长兄。" },
        new IPInfo { pinyin = "gongyangzhuan", displayName = "公羊传", isPlayable = true, sceneName = "GongyangLevel", loadAsync = true, backgroundImage = "gongyangzhuan_bg", description = "以微言大义释《春秋》，明尊王攘夷、正名分之旨。" },
        new IPInfo { pinyin = "guliangzhuan", displayName = "谷梁传", isPlayable = true, sceneName = "GuliangLevel", loadAsync = true, backgroundImage = "guliangzhuan_bg", description = "以礼义释《春秋》，重正名、辨尊卑之传。" },
        new IPInfo { pinyin = "lunyu", displayName = "论语", isPlayable = true, sceneName = "LunyuLevel", backgroundImage = "lunyu_bg", description = "孔子及其弟子的言行录，一位温厚而仍会发问的师者。" },
        new IPInfo { pinyin = "xiaojing", displayName = "孝经", isPlayable = true, sceneName = "XiaojingLevel", backgroundImage = "xiaojing_bg", description = "论孝道之本，最年轻却承载最多阐释的经典。" },
        new IPInfo { pinyin = "erya", displayName = "尔雅", isPlayable = true, sceneName = "EryaLevel", backgroundImage = "erya_bg", description = "训诂之祖，为万物正名、守护秩序的辞书。" },
        new IPInfo { pinyin = "mengzi", displayName = "孟子", isPlayable = true, sceneName = "MengziLevel", backgroundImage = "mengzi_bg", description = "雄辩善思，倡性善、民贵的亚圣之书。" },
    };

    /// <summary>获取全部 13 个 IP。</summary>
    public static IPInfo[] GetAllIPs()
    {
        return allIPs;
    }

    /// <summary>按拼音查找某个 IP，找不到返回 null。</summary>
    public static IPInfo GetByPinyin(string pinyin)
    {
        foreach (IPInfo ip in allIPs)
        {
            if (ip.pinyin == pinyin)
                return ip;
        }
        return null;
    }

    /// <summary>获取所有可玩的 IP。</summary>
    public static List<IPInfo> GetPlayableIPs()
    {
        List<IPInfo> list = new List<IPInfo>();
        foreach (IPInfo ip in allIPs)
        {
            if (ip.isPlayable)
                list.Add(ip);
        }
        return list;
    }
}
