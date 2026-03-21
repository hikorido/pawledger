# PawLedger — Product Requirements Document

> Version 2.0 · 2026-03-21

---

## 项目背景 · Background

爪爪筹 (PawLedger) 是部署在 Avalanche C-Chain 上的动物救助众筹 DApp。通过智能合约里程碑锁仓 + 捐助者投票机制，解决传统救助筹款中信息不透明、资金去向不可追溯的问题。

PawLedger is an animal rescue crowdfunding DApp on Avalanche C-Chain. Milestone-locked escrow + donor voting eliminates the trust problem in traditional rescue fundraising.

**HerSolidity Mini Hackathon 2025** — 赛道1 生命与共存 + 赛道3 Avalanche 生态

---

## 核心改动 · Key Changes from v1

| v1 (原始 PRD) | v2 (本文档) |
|---|---|
| 固定 3-of-5 多签审核委员会 | 捐助者可晋升为审核者，动态审核池 |
| 无激励机制 | 审核者获得 $PAW 治理代币奖励 |
| 单一用户视角 | 三角色分离 UI（救助者/捐助者/审核者） |
| ReviewerMultisig.sol 独立合约 | 审核逻辑内化至 PawLedger.sol |

---

## 用户角色 · User Roles

### 救助者 (Rescuer)

动物救助工作者或志愿者，需要资金支持救助行动。

**流程：**
1. 连接钱包
2. 提交救助案例申请（标题、描述、图片 IPFS、目标金额、期限、里程碑数量）
3. 等待审核者批准（案例状态：PENDING → ACTIVE）
4. 案例上线，开始接受捐款
5. 每完成一个阶段，提交里程碑证明（证明图片 IPFS + 描述 + 申请金额）
6. 捐助者投票通过后，提取该里程碑资金
7. 所有里程碑完成 → 案例关闭（CLOSED）

---

### 捐助者 (Donor)

浏览并支持已激活的救助案例，持续参与资金监督。

**流程：**
1. 浏览已激活案例
2. 连接钱包，捐款 AVAX（体验 Avalanche ~0.8s 确认速度）
3. 对案例的里程碑申请进行投票（投票权重 ∝ 捐款比例）
4. 在个人 Dashboard 查看捐款记录和待投票里程碑
5. 累计捐款达到阈值（≥0.1 AVAX）后，可申请成为审核者

---

### 审核者 (Reviewer)

由捐助者自愿晋升，负责审核新案例申请，维护平台质量。

**成为审核者：**
- 前提：累计捐款 ≥ 0.1 AVAX（`totalDonated >= reviewerThreshold`）
- 调用 `becomeReviewer()` 自我激活
- 初始状态：产品 Owner 是第一个审核者（部署时自动设置）

**流程：**
1. 进入审核者 Dashboard，查看待审核案例队列
2. 审阅案例信息（IPFS 元数据、救助故事、目标金额）
3. 点击批准或拒绝，提交链上交易
4. 每次审核自动获得 10 $PAW 代币奖励
5. 当批准数达到 `requiredApprovals`，案例自动激活

---

## 智能合约架构 · Smart Contract Architecture

### 合约清单

| 合约 | 用途 |
|---|---|
| `PawToken.sol` | ERC-20 治理代币，由 PawLedger 合约铸造 |
| `PawLedger.sol` | 核心托管合约：案例管理、捐款、里程碑、审核逻辑 |

`ReviewerMultisig.sol` 已废弃，审核逻辑内化。

---

### PawToken.sol

```
继承：OpenZeppelin ERC20
名称：PawToken | 符号：$PAW | 精度：18

状态：
  address minter          // 铸币权地址（= PawLedger 合约地址）

函数：
  constructor(address _owner)
  setMinter(address)      // onlyOwner，一次性转让铸币权
  mint(address, uint256)  // onlyMinter
```

---

### PawLedger.sol

#### 数据结构

```
enum CaseStatus  { PENDING, ACTIVE, CLOSED, REFUNDED }
enum MilestoneStatus { PENDING, APPROVED, REJECTED }

struct Case {
    address rescuer
    string  ipfsMetadata       // JSON: title, description, images
    uint256 goalAmount
    uint256 raisedAmount
    uint256 deadline
    CaseStatus status
    uint256 milestoneCount
    uint256 approvalCount      // 已获审核者批准数
}

struct Milestone {
    string  evidenceIPFS
    string  description
    uint256 requestAmount
    uint256 approveWeight      // 批准方捐款权重之和
    uint256 rejectWeight       // 拒绝方捐款权重之和
    uint256 submittedAt        // block.timestamp
    MilestoneStatus status
    bool    fundsReleased
}
```

#### 关键映射

```
isReviewer[address]                               // 是否为审核者
totalDonated[address]                             // 累计捐款额（全平台）
donations[caseId][donor]                          // 对某案例的捐款额（计算投票权重）
hasVoted[caseId][milestoneId][donor]              // 防止重复投票
hasReviewed[caseId][reviewer]                     // 防止重复审核
```

#### 函数列表

| 函数 | 调用方 | 说明 |
|---|---|---|
| `submitCase(ipfs, goal, durationDays, milestoneCount)` | 救助者 | 创建 PENDING 案例 |
| `reviewCase(caseId, approve)` | 审核者 | 审核案例；铸造 10 PAW；达到阈值后激活 |
| `donate(caseId)` | 任何人 | Payable；记录捐款 + totalDonated |
| `becomeReviewer()` | 捐助者 | 满足阈值后自我晋升为审核者 |
| `submitMilestone(caseId, idx, ipfs, desc, amount)` | 救助者 | 提交里程碑证明 |
| `voteMilestone(caseId, idx, approve)` | 捐助者 | 按捐款比例投票；>50% 批准释放，>30% 拒绝（48h内）锁定 |
| `withdrawMilestone(caseId, idx)` | 救助者 | 提取已批准里程碑资金 |
| `claimRefund(caseId)` | 捐助者 | 截止日期后案例未完成，按比例退款 |
| `updateRequiredApprovals(n)` | Owner | 调整案例激活所需批准数 |
| `updateReviewerThreshold(n)` | Owner | 调整成为审核者的捐款门槛 |

#### 审核机制

- 部署时：Owner 自动成为第一个审核者，`requiredApprovals = 1`
- Owner 可随时增加 `requiredApprovals`（审核池扩大后建议设为 2-3）
- 每个审核者每个案例只能审核一次

#### 投票机制

- 投票权重 = `donations[caseId][voter] / cases[caseId].raisedAmount`
- 批准阈值：`approveWeight > raisedAmount / 2`（>50%）
- 拒绝阈值：`rejectWeight > raisedAmount * 30 / 100` 且在提交后 48h 内
- 被拒绝的里程碑状态变为 REJECTED，救助者需重新提交

#### 部署顺序

```
1. 部署 PawToken(deployer)       // deployer 为临时铸币方
2. 部署 PawLedger(pawTokenAddr, 0.1 ether, 1)
3. pawToken.setMinter(pawLedgerAddr)   // 转让铸币权
// PawLedger 构造函数自动注册 deployer 为第一个审核者
```

---

## 前端架构 · Frontend Architecture

### 技术栈

| 层 | 技术 |
|---|---|
| 框架 | React + Vite |
| 样式 | Tailwind CSS |
| Web3 | Ethers.js v6 |
| 钱包 | MetaMask / Core Wallet |
| 存储 | IPFS（MVP 使用 mock CID） |
| 国际化 | 自研 i18n hook（中文默认，支持英文切换） |

### 页面结构（角色分离）

| 路径 | 页面 | 可见角色 | 说明 |
|---|---|---|---|
| `/` | Home | 全部 | 统计看板、精选案例、操作入口 |
| `/cases` | CaseBrowser | 全部 | 浏览所有 ACTIVE 案例 |
| `/case/:id` | CaseDetail | 全部 | 案例详情：捐款、里程碑时间线、投票面板 |
| `/submit` | SubmitCase | 救助者 | 提交新救助申请 |
| `/dashboard/rescuer` | RescuerDashboard | 救助者 | 我的案例、提交里程碑、提取资金 |
| `/dashboard/donor` | DonorDashboard | 捐助者 | 我的捐款、待投票里程碑、晋升审核者 |
| `/dashboard/reviewer` | ReviewerDashboard | 审核者 | 待审核队列、审核历史、$PAW 余额 |

### 组件结构

```
components/
  layout/     Navbar（角色感知导航）, Footer, RoleIndicator, LanguageToggle
  case/       CaseCard, FundingProgress, StatusBadge
  milestone/  MilestoneTimeline, VotePanel, ExpenseLedger
  modals/     DonateModal（含 Avalanche 确认速度展示）, TxConfirmation
  review/     ReviewCard
  wallet/     WalletConnect
  common/     Button, Card, Input, Modal, Loading
```

### Hooks

```
useWallet       钱包连接状态、Fuji 网络切换
useContract     ethers.js Contract 实例（PawLedger + PawToken）
useCases        案例列表、详情查询
useMilestones   里程碑读写、投票
useReviewer     审核状态、待审核案例、审核操作
useDonor        捐款、退款
useUserRole     综合判断当前钱包的角色（救助者/捐助者/审核者）
useLocale       i18n：当前语言、切换、t('key') 翻译函数
```

### 关键 UX 要求

1. **Avalanche 速度展示** — `TxConfirmation` 组件计时并显示"已在 X.Xs 内确认"
2. **ExpenseLedger** — 链上事件的时间线视图，而非表格
3. **实时投票比例** — `VotePanel` 随每票更新显示百分比
4. **移动端适配** — 所有页面响应式布局
5. **双语界面** — 默认中文，右上角切换英文

---

## 国际化 · i18n

- `locales/zh.json` — 中文（默认）
- `locales/en.json` — 英文
- `LocaleContext` 包裹整个 App
- `useLocale()` hook 暴露 `t(key)` 函数

---

## 网络配置 · Network Config

- **测试网**: Avalanche Fuji（chainId `43113`）
- **RPC**: `https://api.avax-test.network/ext/bc/C/rpc`
- **水龙头**: `faucet.avax.network`
- **原生代币**: AVAX

环境变量：在 `src/contracts/.env` 中填写 `PRIVATE_KEY=<部署钱包私钥>`。
部署后将合约地址写入 `src/ui/src/config.js`。

---

## 构建顺序 · Build Order

1. `PawToken.sol` + 测试
2. `PawLedger.sol` + 测试
3. 部署脚本
4. 前端脚手架（Vite + Tailwind + 路由 + 钱包 + i18n 骨架）
5. Hooks（useContract, useWallet）
6. Home + CaseBrowser + CaseDetail（公开流程）
7. SubmitCase + RescuerDashboard（救助者流程）
8. DonateModal + DonorDashboard（捐助者流程）
9. ReviewerDashboard（审核者流程）
10. MilestoneTimeline + VotePanel（里程碑投票 UX）
11. 打磨：交易确认计时、双语字符串、移动端响应式、演示准备

---

## 验收标准 · Acceptance Criteria

- [ ] `npx hardhat test` — 所有合约测试通过
- [ ] `npm run dev` — 前端启动，钱包连接 Fuji 测试网
- [ ] 端到端流程：提交案例 → 审核激活 → 捐款 → 提交里程碑 → 投票 → 提取资金
- [ ] 双语切换在所有页面正常工作
- [ ] 移动端布局正常
- [ ] Avalanche 确认速度在 UI 中有明显展示
