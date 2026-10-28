#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
《十三经》IP 游戏 —— 完整单机包打包脚本

把「Unity 构建产物 + PyInstaller 打包的服务器 + 模型资源」组装成一个
可直接发给别人的文件夹（对方解压后双击 exe 即可，不用装 Python/uv）。

用法：
    python 打包发布.py --build <Unity构建输出目录>

可选参数：
    --server-src       服务器源码目录（取外部数据，默认 Open-LLM-VTuber）
    --pyinstaller-dist PyInstaller 产物目录（默认 dist/run_server）
    --out              最终输出目录（默认「发布」）
"""
import os
import shutil
import sys
import argparse

DEFAULT_SERVER_SRC = r"F:\数字人\Open-LLM-VTuber"
DEFAULT_PYINSTALLER_DIST = r"F:\数字人\Open-LLM-VTuber\dist\run_server"

# 服务器需要一起分发的「外部」文件/目录（相对 server_src）
SERVER_EXTERNAL = [
    "models",
    "live2d-models",
    "frontend",
    "characters",
    "backgrounds",
    "avatars",
    "web_tool",
    "conf.yaml",
    "model_dict.json",
    "config_templates",
    "pyproject.toml",
    "LICENSE-Live2D.md",
]


def main():
    ap = argparse.ArgumentParser(description="打包《十三经》完整单机包")
    ap.add_argument("--build", required=True, help="Unity 构建输出目录（含 exe 和 _Data）")
    ap.add_argument("--server-src", default=DEFAULT_SERVER_SRC, help="服务器源码目录")
    ap.add_argument("--pyinstaller-dist", default=DEFAULT_PYINSTALLER_DIST, help="PyInstaller 产物目录")
    ap.add_argument("--out", default="发布", help="最终输出目录")
    args = ap.parse_args()

    build = os.path.abspath(args.build)
    server_src = os.path.abspath(args.server_src)
    pydist = os.path.abspath(args.pyinstaller_dist)
    out = os.path.abspath(args.out)

    # 1) 校验输入
    if not os.path.isdir(build):
        print("[错误] Unity 构建目录不存在：", build)
        sys.exit(1)
    exe = os.path.join(pydist, "run_server.exe")
    if not os.path.isfile(exe):
        print("[错误] 找不到打包好的服务器：", exe)
        print("       请先在服务器目录执行：")
        print("         build_python\\python.exe -m PyInstaller --noconfirm guliang_server.spec")
        sys.exit(1)

    # 2) 组装
    game_dir = os.path.join(out, "十三经IP游戏")
    server_dir = os.path.join(game_dir, "server")
    os.makedirs(server_dir, exist_ok=True)

    print("[1/4] 复制 Unity 游戏 …")
    # 跳过构建目录里由 BuildPostProcessor 拷入的旧版 server（老方案，我们下面放新的）
    def _ignore_old_server(d, names):
        if os.path.abspath(d) == build:
            return [n for n in names if n == "server"]
        return []
    shutil.copytree(build, game_dir, dirs_exist_ok=True, ignore=_ignore_old_server)

    os.makedirs(server_dir, exist_ok=True)

    print("[2/4] 复制打包后的服务器程序 …")
    shutil.copytree(pydist, os.path.join(server_dir, "run_server"), dirs_exist_ok=True)

    print("[3/4] 复制服务器外部资源（模型 / Live2D / 前端 / 角色配置）…")
    for item in SERVER_EXTERNAL:
        src = os.path.join(server_src, item)
        dst = os.path.join(server_dir, item)
        if os.path.isdir(src):
            shutil.copytree(src, dst, dirs_exist_ok=True)
        elif os.path.isfile(src):
            shutil.copy2(src, dst)
        else:
            print("      [警告] 找不到：", src)

    print("[4/4] 写使用说明 …")
    write_readme(game_dir)

    # 3) 统计
    total = sum(
        os.path.getsize(os.path.join(r, f))
        for r, _, fs in os.walk(game_dir)
        for f in fs
    )
    print("\n打包完成！")
    print("  目录：", game_dir)
    print("  体积：%.2f GB" % (total / 1024 / 1024 / 1024))
    print("  分发：把整个「十三经IP游戏」文件夹压缩成 zip 发给对方即可。")


def write_readme(game_dir):
    txt = """《十三经》IP 游戏 · 使用说明
================================

一、怎么运行
  1. 把整个「十三经IP游戏」文件夹解压到任意位置（注意：不要只拷 exe，
     必须连「十三经IP游戏_Data」和「server」文件夹一起）。
  2. 双击「十三经IP游戏.exe」即可。
  3. 首次启动会自动拉起内置的 AI 服务器，稍等十几秒（首次要加载语音/对话模型），
     出现主菜单后就能玩。

二、需要联网
  「公羊传」「谷梁传」两个关卡用 AI 对话 + 语音，需要联网（调用大模型接口）。

三、目录结构（不要改名/移动）
  十三经IP游戏.exe      游戏主程序
  十三经IP游戏_Data/    游戏数据
  server/               内置 AI 服务器（含模型），由游戏自动启动

四、常见问题
  1. 双击没反应 / 报错：确认整个文件夹都解压完整了，不要只拷 exe。
  2. 杀毒软件 / SmartScreen 可能拦截 server 里的程序，遇到请「允许」。
  3. 两个 Live2D 关卡白屏：说明内置服务器没起来，退出游戏重开一次。
  4. 游戏里点了「退出游戏」后，服务器可能还在后台；再开游戏会自动复用。
"""
    with open(os.path.join(game_dir, "启动说明.txt"), "w", encoding="utf-8") as f:
        f.write(txt)


if __name__ == "__main__":
    main()
