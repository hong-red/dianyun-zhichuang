# =========================================================
#  一键推送《典韵智创 · 十三经 IP 数字游戏》到 GitHub
#  目标仓库：https://github.com/hong-red/dianyun-zhichuang
#
#  用法：
#    1) 在下方 $TOKEN 填入你的 GitHub Personal Access Token
#       （需勾选 repo 权限）。留空则推送到远程会提示输入。
#    2) 在本目录执行：  powershell -ExecutionPolicy Bypass -File push-github.ps1
# =========================================================

# ⚠️ 安全占位：请勿把真实 Token 提交到仓库。
#    真实 Token 请只在这里本地填写，提交前保持为空字符串。
$TOKEN = ""

$Repo   = "hong-red/dianyun-zhichuang"
$Branch = "main"

if ([string]::IsNullOrWhiteSpace($TOKEN)) {
    Write-Host "[!] 未填写 Token，将使用 https 方式推送（可能提示登录）。" -ForegroundColor Yellow
    $RemoteUrl = "https://github.com/$Repo.git"
} else {
    $RemoteUrl = "https://x-access-token:$TOKEN@github.com/$Repo.git"
}

Write-Host "[1/3] 设置远程地址 …" -ForegroundColor Cyan
git remote remove origin 2>$null
git remote add origin $RemoteUrl

Write-Host "[2/3] 暂存全部改动 …" -ForegroundColor Cyan
git add -A

Write-Host "[3/3] 推送到 $Branch …" -ForegroundColor Cyan
git push -u origin $Branch

Write-Host "完成。" -ForegroundColor Green
