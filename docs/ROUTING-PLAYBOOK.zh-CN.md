# 5 池算力分流手册

[English](ROUTING-PLAYBOOK.md) | 简体中文

本手册定义「什么任务该去哪个算力池」以及「跨端交接的硬规矩」，确保本地编码 Agent 额度留在高杠杆改代码上，云端算力不空转扣费。

---

## 一、 派活决策树

```text
收到新需求 / 任务
  ├── 需要连续读大量资料（>50k tokens）、查长文档、写长文、审音视频？
  │     └── 派给 池 3 (AI Studio Web UI) 或 池 2 (网页端深度研究)
  │           产出写入 .ai/specs/<task>/ + .ai/INBOX.md + HANDOFF-FOR-AGENT.md
  │
  ├── 需要大显存 GPU（推理/转码/语音）、无头浏览器并发渲染、大带宽拉取？
  │     └── 派给 池 4 (Colab L4 via google-colab-cli)
  │           遵循 /content/scratch/ + <=50 行 stdout + Zero-Leak 停机
  │
  ├── 需要突发高并发 API 调用或轻量云端测试容器？
  │     └── 派给 池 5 (Cloud Credits / 弹性 API)
  │           开启 Billing Budget Alert，API Key 仅存本机环境变量，严禁入库
  │
  └── 明确要改本地代码、跑单测 / Typecheck / 构建 / Git 提交？
        └── 派给 池 1 (本地 Coding Agent)
              先读 .ai/CONTEXT.md + STATUS.md + INBOX.md，收工回写 STATUS.md
```

---

## 二、 跨端 `.ai/` 交接五条铁律

1. **只写纯文本（`.md` / `.json`）**：严禁在 `AI-Projects/` 里创建在线文档快捷方式（如 `.gdoc` / `.gsheet`），确保手机端、浏览器与本地 CLI 都能用纯文件工具直接读写。
2. **Git 零污染**：`.ai` 软链接只写进 `.git/info/exclude`，绝不改动团队共用的 `.gitignore`，也不会把私人草稿/笔记误提交进业务仓库。
3. **云端只出规格与素材，本地负责集成验收**：AI Studio 可以直接产 JSON 数据、架构方案、`HANDOFF-FOR-AGENT.md`、甚至脚本草稿，但**所有对本地仓库的最终修改必须经过本地类型检查与单元测试**。
4. **消化即清空 `INBOX.md`**：本地 Agent 处理完 `.ai/INBOX.md` 里的任务后，必须把完成摘要与验证命令结果写进 `.ai/STATUS.md`，并清空或归档已消化的 Inbox 条目，防止下次会话重复执行。
5. **上下文防爆**：无论是 `.ai/specs/` 里的参考输出，还是 Colab 回传的统计结果，大文件落盘后再读切片，不把上千行日志或 Base64 贴回对话窗口。

---

## 三、 Colab L4 零漏电（Zero-Leak）自检清单

- **单脚本任务**：一律用 `colab run --gpu L4 --timeout 0 job.py`（进程结束自动销毁 VM，绝不加 `--keep`）。
- **多步会话**：
  1. `colab new -s <name> --gpu L4`
  2. `colab drivemount -s <name>`（按需挂载云盘）
  3. **高频临时文件只写 `/content/scratch/`**（避免 Google Drive FUSE 随机小文件 I/O 拖慢 GPU）
  4. 算完打包回传后，立即 `colab stop -s <name> && colab sessions`
- **硬性验收**：任何任务收工时，`colab sessions` 输出必须明确显示 **无活跃会话（No active sessions）**。
