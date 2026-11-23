# 四象限清单 · 小米应用商店上架指南（2026 年 11 月现行要求）

> **信息查询日期：2026-11-22。政策、审核口径与后台字段随时可能调整，一切以小米开放平台（dev.mi.com）、工信部及中国版权保护中心官方最新要求为准。**
>
> 适用对象：「四象限清单」Android 应用（applicationId `cn.sifen.quadrant`，v1.0.0 / versionCode 1，Flutter，无广告、零权限、纯本地、GPL-3.0 开源）。
>
> 本文基于官方公开文档整理，**不编造备案号、软著号、商店链接或审核时效**；所有时效数字均来自官方页面并附链接，未标注“官方”的耗时为经验估算，仅供参考。本文不构成法律意见。

---

## 目录

- [0. 结论先行（TL;DR）](#0-结论先行tldr)
- [1. 开发者账号与主体资格](#1-开发者账号与主体资格)
- [2. 软件著作权（版权证明）](#2-软件著作权版权证明)
- [3. 工信部 APP 备案](#3-工信部-app-备案)
- [4. 隐私政策与隐私合规](#4-隐私政策与隐私合规)
- [5. 商店素材与信息填写](#5-商店素材与信息填写)
- [6. 常见驳回原因与规避](#6-常见驳回原因与规避)
- [7. 签名、构建与版本更新](#7-签名构建与版本更新)
- [8. 时间线、费用与硬性门槛](#8-时间线费用与硬性门槛)
- [9. 针对「四象限清单」的具体操作建议](#9-针对四象限清单的具体操作建议)
- [10. 官方来源清单](#10-官方来源清单)
- [11. 待确认事项（必须问客服/看后台）](#11-待确认事项必须问客服看后台)

---

## 0. 结论先行（TL;DR）

### 0.1 六个硬性门槛

| # | 门槛 | 官方依据 | 本项目现状 | 结论 |
| --- | --- | --- | --- | --- |
| 1 | **开发者主体必须是企业/组织，个人开发者账号不能上架** | [个人开发者升级公告](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1259)、[开发者账号注册标准](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1731) | 代码与素材已就绪；开发者主体待确定 | **最大卡点，必须先解决** |
| 2 | **软著（或电子版权认证）必须已下证，且名称与开发者主体一致/有授权** | [应用资质 FAQ](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2251)、[应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322) | 尚未申请（需以最终主体申请） | 需 1～3 个月（官方审查期 60 日内） |
| 3 | **隐私政策必须有公网 URL + 应用内独立政策 + 首次启动弹窗（同意/拒绝）** | [应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)、[隐私政策不合规指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1792) | 已实现应用内政策页、首次启动同意弹窗与政策文案；公网 URL 待启用 GitHub Pages | 部署 Pages 后即可满足 |
| 4 | **APP 备案：单机应用可“无需备案”，但必须在后台选择并上传《单机承诺函》** | [APP 备案指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1739)、[备案信息补充指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1775) | 无联网、无服务器、无域名 | 走单机豁免路径，无需买服务器/域名 |
| 5 | **商店素材规格（图标 512×512、截图 1080×1920、简介字数等）** | [应用创建操作指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072) | 已生成 512×512 图标与 6 张 1080×1920 截图（`docs/screenshots/`） | 上传时选 5 张，确认后台尺寸提示 |
| 6 | **更新必须使用同一签名证书** | [应用的签名](https://dev.mi.com/docs/appsmarket/operation_docs/app_signature/)、[开发者生态政策](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1321) | 已配置 release 签名（keystore 与密码不入库，需自行备份） | 首次提审前备份签名 |

### 0.2 现实时间与费用（概览）

| 项目 | 官方口径/费用 | 现实估算 | 是否硬性 |
| --- | --- | --- | --- |
| 开发者账号（企业/组织） | 发布平台服务免费（[发布协议](https://dev.mi.com/docs/appsmarket/distribution/agreements/) 3.1）；账号审核 **1～3 个工作日**（[注册指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1145)） | 已有公司 1～3 天；新办主体 1～4 周（工商+开户） | 硬性 |
| 软著（自行申请） | **官费 0 元**（2017 年起停征，[官方通告](https://www.ccopyright.com.cn/index.php?optionid=1571)）；**自受理日起 60 日内审查完成**（[办理时限](https://www.ccopyright.com.cn/index.php?optionid=1084)） | 材料准备 1～3 天 + 1～3 个月下证 | 硬性 |
| APP 备案 | 官方不收费；管局 **20 个工作日内**备案（[工信部通知](https://www.miit.gov.cn/zwgk/zcwj/wjfb/tz/art/2023/art_920db564162e4312916a01bed6540ad8.html)） | 单机免备案：0 天；若需备案：1～2 个月 | 单机可豁免 |
| 商店审核 | **1～3 个工作日**（[应用创建指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072)） | 1～3 天，驳回重提另计 | 硬性 |
| 隐私政策托管 | GitHub Pages 免费 | 0～1 天（含公网可访问性测试） | 硬性 |
| 可选：软著代理 / 电子版权认证 | 第三方收费，**价格与时效以其页面为准** | 数百至数千元不等（市场区间，非官方） | 可选 |

**一句话结论：本项目当前 100% 卡在“个人开发者不能上架小米应用商店”这一条；代码、图标、截图、签名和隐私弹窗已经就绪。解决主体后，第二道门槛是软著；备案可以走单机豁免，不需要服务器和域名。**

---

## 1. 开发者账号与主体资格

### 1.1 官方现状：小米已暂停个人开发者上架

- 小米应用商店自 2024 年起**暂停收录个人开发者账号发布的 APP**，存量个人开发者需转为**企业开发者**（[应用商店个人开发者升级公告](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1259)，更新于 2024-10-18）。
- 开发者账号注册标准明确写明：**“小米应用商店暂不接受个人开发者账号申请”**，可注册的组织类型为 **企业、政府/事业单位、其他组织**（[开发者账号注册标准](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1731)，更新于 2024-09-24）。
- 2025 年的注册认证操作指南同样只介绍企业认证路径，组织类型列表中没有“个人”（[开发者账号注册认证操作指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1145)，更新于 2025-05-12）。
- 已有的个人开发者账号只能“升级为企业开发者”，不支持反向转换（[开发者账号资料修改指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1068)，更新于 2025-04-29）。

> **注意口径差异**：旧的《开发者账号注册流程》（`dev.mi.com/docs/appsmarket/...`）仍写着“个人开发者”材料（真实姓名、身份证、手持身份证照，1～3 个工作日审核），但该文档是历史遗留页面，与 2024 年后的注册标准冲突。**以 1731/1145 与 1259 公告为准**；首次注册前建议再用客服确认一次。

### 1.2 个人开发者的四条可行路径

| 路径 | 做法 | 优点 | 风险/成本 | 建议 |
| --- | --- | --- | --- | --- |
| A. 个体工商户 | 办个体工商户营业执照，按“企业”类型尝试注册（法大大企业实名 + 营业执照） | 成本低于公司，可开对公户 | **官方未明确个体工商户是否按“企业”受理，需先问客服**；部分字段（对公打款）可能不适用 | 先咨询客服，确认可行再办 |
| B. 注册有限责任公司 | 正常注册公司，走企业认证（法人认证或对公打款） | 最稳，符合所有官方要求；以后可开票、接合作 | 注册+记账+银行开户，周期 1～4 周，有持续成本 | 计划长期做就选这条 |
| C. 合作/借用企业主体 | 找已有公司作为开发者主体，个人以“软著授权/委托开发”方式提供 App | 快，不用自己办公司 | 需真实授权关系与协议；软著/备案主体要一致；收益与权利归属要写清 | 有可信合作方时可行 |
| D. 放弃小米商店 | 仅 GitHub Releases / F-Droid 分发，或改用其他接受个人的商店 | 0 门槛 | 无法获得小米商店流量；**侧载也要做“开发者验证（ADV）”**（见 7.6） | 只作为兜底 |

> 官方“企业”认证材料：多合一营业执照原件照片（自动 OCR 企业名称、统一社会信用代码、法人姓名）、法人身份认证或对公打款认证；人工审核 1～3 个工作日（[注册认证操作指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1145)）。

### 1.3 账号与主体一致性（很容易被驳回）

以下五处名称必须能互相对上，否则会被判“资质主体不一致”：

1. 开发者账号的**企业名称** = 营业执照名称；
2. 应用信息里的**开发者名称** = 账号主体名称（[应用创建指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072)）；
3. **软著著作权人** = 开发者主体；若软著属于个人，需要提供授权证明（[应用资质 FAQ](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2251)）；
4. **APP 备案主体** = 开发者主体（若走备案路径；主体不一致需说明函/协议，[备案信息补充指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1775)）；
5. **隐私政策里的开发者信息、联系方式** = 账号注册信息，且真实有效（[应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)）。

> 本项目现有 `PRIVACY.md` 的开发者字段为“四象限清单开发者（上架主体以应用商店公示为准）”。一旦确定企业主体，**必须同步改成营业执照上的企业全称**，否则会因“隐私政策开发者信息与注册信息不一致”被驳回。

### 1.4 费用

- 小米发布平台本身**免费**：“小米公司免费为发布者提供本协议下约定的发布平台与服务，但并不排除今后……收取费用”（[小米开发者站应用发布协议](https://dev.mi.com/docs/appsmarket/distribution/agreements/) 3.1）。
- 账号注册、应用上架、审核在官方文档中**均未标注收费项**；联运、推广、广告等增值服务另计。
- 企业主体本身的工商注册、代理记账、银行开户费用由当地与服务商决定，**不在小米收费范围内**，本文不给具体金额，避免误导。

---

## 2. 软件著作权（版权证明）

### 2.1 是否硬性：是，且未下证不能先上架

- 所有应用上架均需提供 **《计算机软件著作权登记证书》《APP 电子版权认证证书》《软件著作权认证证书》三选一**，另外还需 APP 备案（[应用资质 FAQ](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2251)，更新于 2026-01-30）。
- 明确问答：“软著还未办理或办理中，可以先上架吗？”——**不可以**，软著是上架必备资质之一，需提交资质后提审（同上 FAQ Q5）。
- 上架要求中再次强调：需提供软著（或 APP 电子版权认证证书），且需与应用信息、企业信息一致，**不接受非安卓版本的资质材料**（[应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)、[开发者生态政策](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1321)）。
- **一个软著只能给一个应用使用**；软著著作权人需与开发者名称一致，授权使用需提供授权证明（含授权人信息、被授权人信息、软著登记号、软件名称、生效日期、授权方盖章）（[应用资质 FAQ](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2251)）。

### 2.2 名称规则：应用主标题必须落在软著全称或简称上

- 应用名称需与软著中**软件全称或简称**保持一致；软著名称变更需提供《计算机软件著作权登记事项变更或补充证明》（[应用资质 FAQ](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2251)）。
- 应用主标题须与软著名称一致；更新时改名需提供新名称的软著或软著变更证明（[应用创建操作指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072)）。
- 应用名称、软著名称、APP 备案名称三者原则上要一致；不一致时有专门的改名处理指南（[名称不一致处理指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1798)）。
- 应用名称**每年（自然年）只能修改 2 次**，且改名需同步软著与备案（[应用名称基本原则](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1796)）。

> **本项目的关键动作**：软著申请时，软件全称建议填「**四象限清单**」或「**四象限清单软件**」，简称填「**四象限清单**」，让应用主标题「四象限清单」能对上；不要申请成「四象限待办清单」「Quadrant List」等不一致的名称。

### 2.3 个人申请 vs 企业申请（本项目怎么选）

| 情形 | 软著著作权人 | 小米侧要求 | 建议 |
| --- | --- | --- | --- |
| 个人已持有软著，但用企业主体上架 | 个人 | 需提供软著授权证明（个人签字/盖章，具体形式先问客服） | 可行但多一道材料，**不推荐** |
| 直接以企业主体申请软著 | 企业 | 著作权人=开发者名称，最顺 | **推荐**：先定主体，再以主体名义申请 |
| 企业委托个人开发 | 企业（合同约定归委托方） | 申请时提交委托开发合同作为权属证明 | 适合“个人写代码、公司持证” |

> 现实约束：软著登记只做形式审查，但 2026 年起中国版权保护中心在治理“非正常软件版权登记申请”，强调材料真实性与诚信（[中国版权保护中心要闻](https://www.ccopyright.com.cn/index.php?optionid=999&method=view&optionid=999&auto_id=1524)）。**不要买“包过”软著、不要用 AI 批量生成材料去申请**，保留真实开发记录。

### 2.4 官方申请流程（自办，官费 0）

官方入口：[中国版权保护中心 · 软件登记](https://register.ccopyright.com.cn/registration.html#/registerSoft)（全程在线办理，电子证书）。

| 步骤 | 动作 | 官方依据 |
| --- | --- | --- |
| 1 | 注册账号并完成**实名认证** | [申请须知](https://www.ccopyright.com.cn/index.php?optionid=1057) |
| 2 | 在线填写申请表（软件全称、简称、版本号、开发完成日期、发表状态、开发方式、著作权人、权利范围、软硬件环境、编程语言、源程序量、主要功能与技术特点） | [填表说明](https://www.ccopyright.com.cn/index.php?optionid=1081) |
| 3 | 准备鉴别材料：源程序**前 30 页 + 后 30 页**（每页不少于 50 行）、任一文档**前 30 页 + 后 30 页**（每页不少于 30 行）；不足 60 页则提交全部 | [所需文件](https://www.ccopyright.com.cn/index.php?optionid=1080) |
| 4 | 准备身份证明：个人为身份证；企业为加载统一社会信用代码的营业执照副本 | [所需文件](https://www.ccopyright.com.cn/index.php?optionid=1080) |
| 5 | 在线打印申请确认签章页 → 签字/盖章 → 扫描成 PDF 上传；提交 | [申请须知](https://www.ccopyright.com.cn/index.php?optionid=1057) |
| 6 | 等待受理与审查；通过后在用户中心下载 **PDF 电子证书**（带电子签章，可验签） | [申请须知](https://www.ccopyright.com.cn/index.php?optionid=1057) |

**周期与费用（官方）**：

- 审查时限：**自受理日起 60 日内**审查完成（[办理时限](https://www.ccopyright.com.cn/index.php?optionid=1084)）。
- 补正：自补正通知发出之日起 **30 日内**补正，逾期视为撤回（[申请须知](https://www.ccopyright.com.cn/index.php?optionid=1057)）。
- 官费：**0 元**。财政部 2017 年清理行政事业性收费后，软件著作权登记费（申请费、证书费、合同登记费、变更补充登记费、源程序封存保管费、查询费）停征（[停征通告](https://www.ccopyright.com.cn/index.php?optionid=1571)）。
- 现实中从提交到拿证常见 1～3 个月（经验值，非官方承诺；以登记系统进度为准）。

**本项目材料准备清单**：

- [ ] 源代码：`lib/` 下所有 `.dart` 文件按顺序导出，页眉统一写「四象限清单 V1.0」，每页 ≥50 行，取前 30 页 + 后 30 页；
- [ ] 文档：用户手册或设计说明（功能、界面、操作流程），页眉同样写软件名称与版本号，每页 ≥30 行，前后各 30 页；
- [ ] 软件功能描述：写清四象限模型、拖动换象限、深色模式、JSON 导出/导入、隐私设计（不联网、零权限）；
- [ ] 开发完成日期、首次发表日期（若已在 GitHub 公开仓库发布，可填已发表，并填首次发表地点/方式）；
- [ ] 著作权人 = 最终开发者主体（个人或公司）。

### 2.5 电子版权认证能否替代？

**能替代“软著”作为小米的资质三选一，但要注意边界**：

- 小米明确接受三种形式：《计算机软件著作权登记证书》《APP 电子版权认证证书》《软件著作权认证证书》（[应用资质 FAQ](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2251)）。
- 小米官方文档也给出了“电子软著申请入口”（第三方平台易版权）：<https://www.yibanquan.com.cn/product/app.at>（[应用名称/软著名称基本原则](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1796)）。
- 该入口是**第三方付费服务**，价格、时效、材料要求**以其页面为准**，本文不写金额。
- 风险：① 它是“认证证书”，法律效力与官方登记证书不同，后续改名、转让、维权时可能更麻烦；② 小米审核仍可能核对名称/主体一致性；③ 政策变化时替代性可能收紧。

> **建议**：时间够就办官方软著（0 官费，60 日内）；非常急着上线且愿意付费，才考虑电子版权认证，并先向小米客服确认“当前是否仍认可该证书 + 你的主体类型”。

### 2.6 开源 / GPL-3.0 与软著的关系

- 上架小米**不要求**开源，也不因为开源就免除软著要求；软著是资质，开源是授权方式，两者不冲突。
- 发布协议要求：如果作品包含开源软件，发布者保证遵守所有适用的开源许可条款（[小米开发者站应用发布协议](https://dev.mi.com/docs/appsmarket/distribution/agreements/) 1.2）。
- GPL-3.0 允许商业分发与商店上架；但**著作权归属**要写清：若以公司名义申请软著，需有个人→公司的转让/委托开发协议，确保权属真实。

---

## 3. 工信部 APP 备案

### 3.1 法规与时间线

- 依据《反电信网络诈骗法》《互联网信息服务管理办法》，工信部 2023 年发布《关于开展移动互联网应用程序备案工作的通知》（**工信部信管〔2023〕105 号**）：在境内从事互联网信息服务的 APP 主办者应履行备案手续，**未备案不得从事 APP 互联网信息服务**；分发平台不得为未备案 APP 提供分发服务（[工信部通知](https://www.miit.gov.cn/zwgk/zcwj/wjfb/tz/art/2023/art_920db564162e4312916a01bed6540ad8.html)）。
- 小米侧时间节点：新应用 **2023-09-01 起**须完成备案才可上架；存量应用 2023-12-12 起限制更新、2024-01-04 起清理（[APP 备案指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1739)，更新于 2026-10-25）。
- **关键例外（对本项目最重要）**：备案指引 FAQ 明确——“**若 APP 本身内容是单机，仅使用了其他供应商的广告服务、推广服务，且域名等不属于 APP 主办者，则主办者不用为不联网的单机 APP 进行备案**”；若被驳回且确认为单机，可通过单机应用客服系统反馈（同上指引 FAQ 1）。

### 3.2 需要备案时的一般流程

| 步骤 | 动作 | 说明 |
| --- | --- | --- |
| 1 | 通过**网络接入服务提供者**（华为云/阿里云/腾讯云等）的备案系统提交 | 常见接入商见 [名称基本原则](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1796) |
| 2 | 接入商初审材料 | 主体信息、APP 基础信息、APP 特征信息、接入信息 |
| 3 | 主办者短信核验，登录 [beian.miit.gov.cn](https://beian.miit.gov.cn/) 确认 | [备案指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1739) |
| 4 | 省级通信管理局审核 | **20 个工作日内**予以备案（[工信部通知](https://www.miit.gov.cn/zwgk/zcwj/wjfb/tz/art/2023/art_920db564162e4312916a01bed6540ad8.html)） |
| 5 | 短信/邮件下发备案编号，beian.miit.gov.cn 公示 | 备案号需在 APP 显著位置展示并链接备案系统（[工信部通知](https://www.miit.gov.cn/zwgk/zcwj/wjfb/tz/art/2023/art_920db564162e4312916a01bed6540ad8.html)） |

**备案要填的内容**（安卓）：主体信息（单位名称/证件/负责人等）、APP 基础信息（名称、图标、服务类目、语种）、APP 特征信息（**包名、公钥+MD5、域名**）、接入信息（[备案指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1739)）。

### 3.3 个人无服务器、无域名怎么办？

**结论：本项目（纯单机、无联网、无服务器、无域名）不需要也不应该去买服务器/域名，走“无需备案（单机应用）+ 单机承诺函”路径。**

小米后台的备案信息模块提供三个选项（[备案信息补充指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1775)，更新于 2025-09-18）：

1. **应用已备案**（自动查询监管侧 + 工信部核验）；
2. **应用未备案**（仅更新场景可选；新增应用不提供此选项）；
3. **无需备案（单机应用）**：需同时满足“单机应用条件”，并上传**免责承诺函**（官方提供模板）。

官方对“单机应用”的定义：**在没有联网的情况下，用户可以在本地设备上使用的应用，通常不需要与服务器或其他设备通信**（同上）。

> 现实做法：在后台选择“应用无需备案”，下载并填写《单机承诺函》，连同“应用不联网、无服务器、无域名、无第三方广告/统计 SDK”的情况说明一起上传。若审核仍要求备案，走小米**单机应用客服系统**申诉（[备案指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1739) 中给出入口）。

### 3.4 备案与商店上架的先后关系、小米是否强制校验

- **需备案的 App：先备案、后上架**。新应用 2023-09-01 起必须完成备案才可上架（[备案指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1739)）。
- 小米会校验：对“应用已备案”的，平台会通过监管查询方式和工信部备案查询官网判断，**能查到备案记录且信息一致才视为通过**（[备案信息补充指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1775)）。
- 备案名称必须与应用名称、APPLICATION 包名一致；APP 备案名称与应用名称、软著名称原则上要一致（[名称基本原则](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1796)）。
- 已备案应用需在**应用内显著位置展示备案编号**（设置-关于、证照信息页等），并支持点击跳转工信部备案网站（[备案编号展示指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1832)）。**单机免备案应用不适用这一条**（因为没有备案号），但建议在关于页写“本应用为单机应用，无需 APP 备案”并附说明，避免审核疑问。

> **口径提醒**：`应用资质 FAQ`（2026-01-30）写的是“APP 备案：所有应用上架均需要提供”，而 `备案信息补充指引`（2025-09-18）给出了“无需备案（单机应用）”的明确通道。两者不矛盾，后者是前者的操作细则。**提交时以“无需备案（单机应用）”+ 承诺函为准；若被拒，再按客服要求补。**

### 3.5 本项目备案操作清单

- [ ] 后台“备案信息”模块选择：**应用无需备案（单机应用）**；
- [ ] 下载并填写官方《单机承诺函》，负责人签字/盖章；
- [ ] 附一页情况说明：App 不声明 INTERNET 权限、无服务器、无域名、无第三方 SDK（除 Flutter 引擎与 shared_preferences）、无广告/统计/推送；
- [ ] 不购买云服务器、不注册域名、不做接入商备案；
- [ ] 若审核驳回“未备案”，先走单机应用客服申诉，不要直接去买备案；
- [ ] 未来若新增联网功能（云同步、账号、统计），**必须重新做 APP 备案**，且备案主体需与开发者主体一致。

---

## 4. 隐私政策与隐私合规

### 4.1 硬性要求（逐条照做）

依据小米《应用商店上架要求》与《应用隐私合规标准》：

1. **必须有公网可访问的隐私政策 URL**（http/https 开头），填写在后台“隐私政策”字段；链接必须能正常打开，不得内网/内链（[应用添加隐私政策声明通知](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1170)、[隐私政策不合规指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1792)）。
2. **应用首次运行必须有隐私政策弹窗**，明显提示用户阅读，并提供**明确的“同意”和“拒绝”按钮**；不得用“好的”“我知道了”，不得默认勾选（[应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322) 二、[隐私政策不合规指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1792) 3/4）。
3. **应用内必须有独立的隐私政策**，进入主界面后**不多于 4 次点击**即可访问（[应用隐私合规标准](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1325)）。本项目路径“设置 → 关于 → 隐私政策”为 3 步，达标。
4. 隐私政策必须明示：**应用信息、开发者信息、开发者联系方式**，且与开发者注册信息一致、真实有效（[应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)）。
5. 必须明示（包括第三方 SDK/插件）收集个人信息的**目的、方式、范围**；不收集的也要明确写“不收集”（[应用隐私合规标准](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1325)）。
6. **同意隐私政策前不得读取任何个人信息**（[应用隐私合规标准](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1325)）。
7. 弹窗、应用内独立政策、网页版政策**三处内容必须一致**（[应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)）。
8. 政策要易于阅读：简体中文、字号不过小过密、颜色不过淡、可保存/查阅（[应用隐私合规标准](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1325)）。

### 4.2 零权限、无联网 App 的隐私政策内容建议

本项目口径（与 `PRIVACY.md`、`docs/STORE_LISTING.md` 一致）应逐条写入：

| 章节 | 必须写的内容 |
| --- | --- |
| 开发者信息 | 企业全称（与账号一致）、联系邮箱 1304857605@qq.com、生效日期、版本 |
| 一句话概括 | 不收集、不上传、不共享任何个人信息 |
| 收集清单 | **无**：不收集身份信息、设备标识符（IMEI/Android ID/OAID/MAC）、位置、通讯录、相册、麦克风、摄像头、剪贴板、使用行为、崩溃日志 |
| 权限说明 | AndroidManifest **不声明任何权限**（含 INTERNET），系统权限页为空 |
| 第三方组件 | Flutter 引擎（仅本地渲染，未集成 Firebase 等）、`shared_preferences`（仅本地键值存储）；均不联网、不收集、不用于广告/统计 |
| 数据存储 | 仅存于应用私有目录 SharedPreferences；卸载/清除数据即删除 |
| 导出/导入 | 用户主动触发；导出只写入系统剪贴板，不上传；提示剪贴板可能被其他应用读取 |
| 用户权利 | 查看、修改、删除单条待办；清除应用数据；卸载；行使权利的渠道与时限 |
| 未成年人 | 不收集、无广告、无内购；未满 14 周岁建议监护人指导 |
| 政策更新 | 变更时更新生效日期并在应用/仓库提示 |
| 联系方式 | 邮箱；建议同时给 GitHub Issues |

> **不要写**“我们可能收集……”“为了改进服务……”这类兜底句——零收集 App 写了反而会被认为“收集范围不明确”，也与你实际行为不符。

### 4.3 无权限、无联网 App 如何填后台的“收集信息/权限”相关表单

- 上传 APK 后，小米会自动解析**权限信息**；本项目解析结果应为空。后台只做核对，不需要你逐项申请（[应用创建操作指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072)）。
- 若后台出现“第三方 SDK/收集信息清单”类字段（不同时期字段不同），逐项填“无”，并在隐私政策中同步写“无第三方 SDK 收集个人信息”。
- 在“测试账号/备注”里写清：**应用无账号体系、无需登录、无需测试账号；零权限、无联网、纯本地**。这能显著降低审核沟通成本。
- 隐私政策 URL 填公网地址；不要填 GitHub 仓库文件页、不要填 `raw.githubusercontent.com`（国内访问不稳定），用 Pages 静态页。

### 4.4 隐私合规检测常见驳回点

| 驳回点 | 官方依据 | 本项目规避 |
| --- | --- | --- |
| 隐私政策打不开/空白/超时 | [隐私政策不合规指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1792) 场景 1 | 用 4G/5G + 无痕窗口实测；准备第二个托管地址备用 |
| 首次启动无隐私弹窗 | 同上 场景 1 | 已完成：`PrivacyConsentGate` 首帧弹窗，提供“同意并继续 / 不同意” |
| 无独立隐私政策 | 同上 场景 2 | 已有 `PrivacyScreen`，保持 |
| 无“拒绝”按钮/用“好的” | 同上 场景 3 | 按钮文案用“同意并继续”“暂不同意” |
| 默认勾选 | 同上 场景 4 | 复选框默认不勾选；或不用复选框，直接双按钮 |
| 拒绝后应用直接退出/不可用 | [应用隐私合规标准](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1325) 三.1.5 | 本项目不收集信息，拒绝后应允许继续本地使用 |
| 隐私政策未写明开发者信息/联系方式 | [应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322) | 填企业全称 + 邮箱 |
| 弹窗/应用内/网页三处内容不一致 | 同上 | 三处同步更新，版本号一致 |
| 隐私政策未列第三方 SDK | [应用隐私合规标准](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1325) 五.5 | 列 Flutter 引擎 + shared_preferences，说明不收集 |

### 4.5 隐私政策 URL 托管建议

- 仓库已有 `docs/privacy.html`，计划用 GitHub Pages 托管，地址形如 `https://<用户名>.github.io/quadrant-todo/privacy.html`（**占位，提交前必须实测可访问**）。
- 建议同时准备一个备用托管（如 Cloudflare Pages、Gitee Pages、对象存储静态页），审核期间保持可用；URL 一旦提交，**不要在上架期间失效**。
- 自测方法：手机关 Wi-Fi 用移动网络、无痕模式打开；确认 HTTPS、无登录、无跳转、中文正常、可滚动到底部。
- 页面里应有：政策正文、生效日期、开发者信息、联系方式；不要只放一个 PDF 下载链接（小米要求“可直接阅读，不可下载后才能阅读”，[应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)）。

---

## 5. 商店素材与信息填写

### 5.1 官方字段规格（以 2026 年现行创建指南为准）

| 字段 | 官方要求 | 本项目建议值 | 依据 |
| --- | --- | --- | --- |
| 应用主标题 | 须与软著名称一致 | 四象限清单 | [应用创建指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072) |
| 主标题+副标题 | 总计 **≤30 个英文字符**（1 个中文字符算 2 个） | 主标题 5 字 + 副标题 6 字 = 22 字符 | 同上 |
| 副标题 | 运营宣传/进一步说明 | 零权限纯本地 | 同上 |
| 应用图标 | **512×512 px、PNG**，须与安装后桌面图标一致 | 用 `design/icon-512.png`，核对与 mipmap 一致 | 同上 |
| 一句话简介 | **≤34 个字符**；陈述句；无极限词；句末不加标点 | 无广告的四象限待办清单，零权限、纯本地（19 字） | 同上 |
| 应用介绍 | **20～4000 字** | 见 9.4 草稿（约 250 字） | 同上 |
| 关键词 | **≤8 个**，每个 **≤10 字符**，不与功能无关 | 四象限 待办 清单 时间管理 效率 极简 本地 无广告 | 同上 |
| 截图方向 | 横向或竖向二选一 | 竖向 | 同上 |
| 手机截图 | **至少 4 张、至多 5 张**；竖屏 **1080×1920 px、PNG、≤5MB**；不得重复 | 5 张：首页/新建/拖动/深色/设置关于 | 同上 |
| 平板截图 | 若兼容设备包含平板，需**另上传平板截图** | **兼容设备只选“手机”**，避免额外素材 | 同上 |
| 应用介绍视频 | 非必填；720p 或 1080p，`.mp4` | 建议录 15～30 秒功能演示 | 同上；[审核规范](https://dev.mi.com/docs/appsmarket/auditing&evaluation/auditing_criterion/) 第 10 节 |
| 品牌展示图 | 非必填；1080×480 px、PNG、≤5MB | 可不做 | [应用创建指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072) |
| 分类 | 一级分类含“实用工具”“效率办公”等；二级分类按实际 | 一级：实用工具；二级：以后台可选项为准 | 同上 |
| 年龄分级 | 3+/8+/12+/16+/18+ | **3+**（无不良内容） | [应用年龄分级标准](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1855) |
| 兼容设备 | 手机 / 平板 / 手机和平板 | 手机 | [应用创建指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072) |
| 测试账号 | 需登录时必须提供 | 无账号体系，填“无需登录/无测试账号” | 同上 |
| 隐私政策 | http/https 完整 URL | 见 4.5 | 同上 |
| 更新日志 | 如实填写本次更新 | 1.0.0 首次发布：四象限待办、拖动换象限、深色模式、JSON 导出导入 | 同上 |
| 发布范围 | 中国大陆（默认） | 中国大陆 | 同上 |

> **规格提醒**：本项目已按官方要求导出 **6 张 1080×1920 PNG**（`docs/screenshots/`），上传时选 5 张。若后台实际页面显示其他尺寸，以页面提示为准，并在提交前截图留证。

### 5.2 图标制作规范

- 商店图标 512×512 PNG；安装图标用 Android 自适应图标：前景/背景各 432×432，安全区 72dp（`design/` 已有 `adaptive-foreground-432.png`、`adaptive-background-432.png`、`monochrome-432.png`，Android 工程已接入）。
- 图标必须清晰完整，不得模糊、拉伸、压缩、黑边、白边、比例失调；不得带非官方网址/二维码/文字；不得用真人形象；不得与已上架应用图标相同或近似（[应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)、[审核规范](https://dev.mi.com/docs/appsmarket/auditing&evaluation/auditing_criterion/) 3.3、9）。
- 完美图标（选填）：需上传 90×90、136×136、192×192（手机）与 168×168（平板），内容填满内容区、不留透明圆角（[审核规范](https://dev.mi.com/docs/appsmarket/auditing&evaluation/auditing_criterion/) 9.1.1）；旧提交流程还提到 224×224（[应用提交流程](https://dev.mi.com/docs/appsmarket/distribution/app_submit/)）。不做完美图标不影响上架，但做了能提升桌面显示效果。
- 商店图标、桌面图标、截图里的图标**三处必须一致**，这是高频驳回点（[审核规范](https://dev.mi.com/docs/appsmarket/auditing&evaluation/auditing_criterion/) 3.3.18）。

### 5.3 截图制作

- 5 张竖屏 1080×1920 PNG，每张 ≤5MB，内容必须是**真机/模拟器实际界面**，不得用设计稿冒充。
- 建议内容与顺序：
  1. 首页四象限矩阵（展示四色卡片与任务）；
  2. 新建/编辑待办（展示标题、备注、象限、截止日期）；
  3. 拖动换象限（可用箭头/手指提示，但不得出现“用手指点击屏幕”的人机交互视频；截图可加极简说明文字）；
  4. 深色模式；
  5. 设置/关于（体现隐私政策、开源协议、版本）。
- 禁止：iOS 界面、iPhone 外观、其他应用市场图标/水印/首发字样、其他品牌标识、重复图、黑边、拉伸、模糊、通知栏出现与本应用无关的图标（[审核规范](https://dev.mi.com/docs/appsmarket/auditing&evaluation/auditing_criterion/) 3.1、3.3）。
- 截图里的文案不得含极限词、不得与功能不符。

### 5.4 名称与重名检查

- 上架前先在小米应用商店搜索“四象限清单”“四象限”“待办清单”，确认无同名/高度近似应用；主标题一致即视为同名（不区分大小写）（[应用名称基本原则](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1796)）。
- “清单”属于类别词，名称不得“仅包含普遍、不具辨识性的词汇”；“四象限清单”有一定辨识度，但仍有被判“类别词”的风险（[审核规范](https://dev.mi.com/docs/appsmarket/auditing&evaluation/auditing_criterion/) 3.2.9、[名称基本原则](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1796)）。
- 若被驳回，备选方向：更具品牌性的名称（如“象限清单”“轻象限”等），但**改名要同步软著与备案**，且每年只能改 2 次——所以最好一次定好。
- 名称不得含 #、*、& 等特殊符号；应用名称+副标题都不得含（[应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)）。

### 5.5 版权证明上传

- 上传软著证书（或电子版权认证证书）到“行业资质/基础资质”入口；证书需真实有效、无马赛克、在有效期内、**不接受非安卓版本资质**（[应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)）。
- 若软著著作权人与开发者主体不一致：上传授权证明（授权人/被授权人信息、软著登记号、软件名称、生效日期、授权方盖章）（[应用资质 FAQ](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2251)）。
- 若应用名称变更：需同步提交软著变更证明与新名称，且保证三者一致（[名称不一致处理指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1798)）。

---

## 6. 常见驳回原因与规避

> 依据：[应用审核规范](https://dev.mi.com/docs/appsmarket/auditing&evaluation/auditing_criterion/)、[应用审核常见问题](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1252)、[应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)、[应用和开发者分级管理制度](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1501)。

| 驳回原因 | 官方条款 | 本项目风险 | 规避建议 |
| --- | --- | --- | --- |
| **功能过于简单/单一功能/设计粗糙** | 审核规范 3.5.2、3.5.3、3.5.4、3.5.5；生态政策“基本要求” | **高**：四象限清单功能偏轻，商店已有很多待办/清单类应用 | 提交前确保功能完整闭环：新建/编辑/删除/勾选/拖动换象限/详情页/深色/导入导出/关于/首次提示；介绍与截图突出“四象限 + 拖拽 + 纯本地”差异化；不要只放一个空界面 |
| 应用是简单网页打包/套用模板/内容聚合 | 审核规范 3.5.3；[审核常见问题](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1252) 一 | 中：Flutter 自绘界面不会被判网页打包，但“模板感”可能被质疑 | 保持自定义视觉（石墨蓝、四色象限、圆角卡片），避免通用模板 UI |
| 与已上架应用功能/界面非常类似或雷同 | 审核规范 3.5.4、3.5.5 | 中高：待办类竞品多 | 强调四象限矩阵 + 长按拖拽 + 零权限；图标/名称/截图不要蹭知名应用 |
| 应用名称仅类别词/与已上架同名/含非法字符 | 审核规范 3.2.4、3.2.5、3.2.9；[名称基本原则](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1796) | 中：“清单”是类别词 | 先搜重名；名称保留“四象限”辨识度；准备备选名 |
| 一句话简介含极限词/疑问句/句末标点 | 审核规范 3.2.21、3.2.22；[应用创建指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072) | 低：现文案合规 | “无广告”“零权限”是事实描述，不是极限词；勿用“最”“第一”“必备”“100%” |
| 图标/截图与安装后不一致、含 iOS/其他市场/黑边/重复 | 审核规范 3.1、3.3 | 中：SPEC 截图尺寸不符 | 真机截图、1080×1920、5 张不重复；商店图标=桌面图标 |
| 应用内广告违规（关闭障碍、频繁弹出、伪装系统） | 审核规范 3.4；上架要求“应用内广告” | 无：本项目无广告 | 保持无广告；介绍里可写“无广告”，但不要在截图里放“广告”字样 |
| 权限与功能不符/过度索权 | 审核规范 2.3.1；上架要求“权限” | 无：零权限是优势 | 保持 manifest 无权限；后台权限解析为空 |
| 隐私政策缺失/打不开/无弹窗/无拒绝按钮/默认勾选 | [隐私政策不合规指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1792) | **高：当前缺首次启动弹窗** | 提审前补弹窗；URL 实测可访问；三处内容一致 |
| 应用内提示更新/版本不是最新 | 审核规范 3.5.1 | 无：不做检查更新 | 不要加“检查更新”弹窗 |
| 启动/运行崩溃、按钮无响应、功能不可用 | 审核规范 2.1 | 低：需真机测试 | 在小米/Redmi 两年内机型或小米云测上跑主流程；冷启动 >1 秒要有反馈（生态政策 4.1） |
| 需要登录但未提供测试账号 | 审核规范 2.1.12；[审核常见问题](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1252) 十 | 无：无账号 | 测试账号栏写“无需登录” |
| 资质缺失/软著未下证/备案信息不一致 | [应用资质 FAQ](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2251)、[备案信息补充指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1775) | **高** | 先办软著；单机承诺函；名称三者一致 |
| 未提交有效测试视频 | [分级管理制度](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1501) L2-1 #20 | 低 | 备一段 15～30 秒录屏，审核要时能提供 |
| 应用界面模糊/拉伸/黑边/分辨率不适配 | 审核规范 2.1.15～2.1.27；生态政策“兼容” | 低：Flutter 自适应 | 至少测 1080×2400、1080×1920、720×1280 三种分辨率；平板若不适配就别勾“平板” |
| 马甲包/重复提交相似应用 | [审核常见问题](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1252) 六；生态政策 4.7 | 低 | 一个应用一个包；不要换皮重复提 |
| 签名与应用商店检测记录不一致 | 生态政策 3.6 | 中：首次上架后每次更新必须同签名 | 见第 7 节 |

**驳回后的正确做法**：按驳回理由逐条改，不要“不改就重提”（分级制度会对重复被驳升级信用等级）；涉及资质/备案争议，联系客服或 developer@xiaomi.com，附包名、应用名、版本号、驳回原因、说明与证明材料（[应用隐私合规标准](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1325) 七）。

---

## 7. 签名、构建与版本更新

### 7.1 为什么签名是硬要求

- Android 用签名识别“作者是谁、更新是否同一作者、文件是否被篡改”（[应用的签名](https://dev.mi.com/docs/appsmarket/operation_docs/app_signature/)）。
- 小米在**应用认领、每次更新、防止冒充、签名黑名单**等场景依赖签名（同上）。
- 生态政策明确：应用签名、应用文件与商店检测过的同包名应用不一致，属安全不达标（[开发者生态政策](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1321) 3.6）。

### 7.2 首次提审前必须配好 release 签名

> 仓库已包含完整的 `android/` 工程、应用图标、启动图与 release 签名配置（`android/app/build.gradle.kts` 读取 `android/key.properties`）。提审前请按 [SIGNING.md](SIGNING.md) 备份 keystore；**不要用 debug 签名提审**——debug 签名无法作为长期更新凭证。

```bash
# 1) 生成 upload keystore（有效期建议 25 年以上；密码自己保管好）
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`android/key.properties`（不要提交到 Git）：

```properties
storePassword=<你的密码>
keyPassword=<你的密码>
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

`android/app/build.gradle`（Groovy；若为新版 Kotlin DSL，写等价 `signingConfigs` 配置）：

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

```bash
flutter build apk --release          # 产物：build/app/outputs/flutter-apk/app-release.apk
# 或分 ABI：flutter build apk --release --split-per-abi
```

### 7.3 备份与校验

- **必须备份**：keystore 文件至少 2 份异地备份（离线介质 + 密码管理器），记录 alias、密码、有效期；丢失后**无法更新已上架应用，也无法认领**。
- 校验签名证书：

```bash
keytool -list -v -keystore upload-keystore.jks -alias upload
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

- 记录 **SHA-256 / MD5** 指纹：若将来做 APP 备案，备案要填“公钥+MD5”（[APP 备案指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1739)）；做 ADV 侧载验证也要“包名+签名”（[开发者身份验证规范](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2366)）。

### 7.4 64 位与 ABI

- 单包上传需为 **64 位包或 32/64 位兼容包**；Flutter 默认产物包含 `arm64-v8a`（兼容包还含 `armeabi-v7a`），满足要求（[应用创建指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072)、[64 位适配](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1715)）。
- 上传后后台会解析 CPU 适配、版本号、targetSdk；`versionCode` 必须大于等于在架版本（同上）。

### 7.5 更新流程与规则

1. 修改代码 → `pubspec.yaml` 的 `version` 与 `AppInfo` 同步（如 `1.0.1+2`）；
2. 用**同一 keystore** 构建 release APK；
3. 后台“发布新版本”→ 上传 APK → 核对解析信息（权限、版本、targetSdk）→ 填更新日志 → 提交；
4. 审核 **1～3 个工作日**（[应用更新指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1248)）；
5. 重要规则：更新日志不能与旧版本相同、不能写“无”、不能含其他市场名称；新版本主体内容不得与旧版相差过大；运行后不得提示更新（[审核规范](https://dev.mi.com/docs/appsmarket/auditing&evaluation/auditing_criterion/) 3.2.13～3.2.15、[上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322)）；
6. 改名限制：应用名称每年（自然年）只能改 **2 次**，改名需新软著/变更证明并保持备案名称一致（[名称基本原则](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1796)）；
7. 修改资料不支持直接改应用名称，需在“提交审核/版本更新”状态下改（[应用更新指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1248)）。

### 7.6 侧载与 ADV（2026 年新增，影响 GitHub 分发）

- 小米自 **2026-10-21** 上线“开发者身份验证（ADV）”，**2026-10-31** 起在侧载安装环节校验；未验证应用安装时会显示“ADV 未验证”提示（[开发者身份验证申请规范](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2366)，更新于 2026-10-21）。
- **商店在架应用默认已认证，无需单独申请**；侧载分发的应用需要做“应用验证”（上传含签名的 APK 空包，绑定包名）（同上）。
- 影响：如果你同时从 GitHub Releases 直接分发 APK 给用户侧载，建议也完成 ADV；只上架商店则不受影响。

---

## 8. 时间线、费用与硬性门槛

### 8.1 硬性门槛（Must have）

| 门槛 | 是否硬性 | 不满足的后果 |
| --- | --- | --- |
| 企业/组织开发者主体 | **是** | 个人账号无法上架，直接被挡在门外 |
| 软著或电子版权认证（已下证） | **是** | 无资质不能提审 |
| 软著/应用/备案名称一致（或授权证明） | **是** | 资质驳回 |
| 隐私政策公网 URL + 应用内弹窗 + 独立政策 | **是** | 隐私合规驳回 |
| 图标 512×512、截图 1080×1920×4～5 张、简介字数 | **是**（形式） | 素材驳回 |
| 应用可正常安装/启动/使用、功能与介绍一致 | **是** | 审核驳回 |
| 更新使用同一签名 | **是**（更新时） | 无法覆盖更新/认领失败 |
| APP 备案 | **单机可豁免**（需承诺函）；联网则硬性 | 单机被误判时需申诉 |

### 8.2 现实时间线（从零开始）

| 阶段 | 乐观 | 现实 | 说明 |
| --- | --- | --- | --- |
| 定主体（已有公司） | 1～3 个工作日 | 1 周 | 账号审核 1～3 工作日（官方） |
| 定主体（新办个体户/公司） | 1～2 周 | 2～4 周 | 工商 + 银行开户 + 认证；地区差异大 |
| 软著申请 | 60 日内（官方审查期） | 1～3 个月 | 材料一次过则快；补正则更久 |
| 隐私弹窗开发 + 政策部署 | 1～2 天 | 3～5 天 | 含公网访问测试 |
| 素材制作（图标/截图/文案） | 1～2 天 | 3～7 天 | 需真机截图 |
| 商店审核 | 1～3 个工作日（官方） | 1～5 个工作日 | 驳回重提另计 |
| **合计（已有企业+软著在手）** | **约 1～2 周** | **约 2～4 周** | 主要花在素材与审核沟通 |
| **合计（从零开始）** | **约 2 个月** | **约 2～4 个月** | 大头是软著 |

### 8.3 费用估算

| 项目 | 金额 | 性质 |
| --- | --- | --- |
| 小米开发者账号/上架/审核 | **0 元**（官方未设收费项；发布协议称平台服务免费） | 官方 |
| 软著自行申请 | **0 元官费** | 官方 |
| 软著代理（可选） | 数百至数千元不等 | 市场价，非官方，以服务商页面为准 |
| 电子版权认证（可选替代） | 以第三方平台页面为准 | 第三方 |
| 隐私政策托管 | 0 元（GitHub Pages 等） | 免费 |
| 企业主体（如需新办） | 工商/记账/开户费用，地区差异大 | 非小米收费 |
| 域名/服务器（本项目不需要） | 0 元 | 单机免备案，不需要 |
| 设计/截图外包（可选） | 以服务商为准 | 可选 |

> **别花冤枉钱**：软著官费本来就是 0，不要被“必须找代理”的信息差收割；备案也不需要买服务器（单机豁免）。真正要花钱的是“企业主体”本身。

### 8.4 风险与不确定性

- **个人主体政策**：2024 年起暂停个人上架；未来是否重新开放未知，以注册页面实际可选类型为准。
- **软著审查趋严**：2026 年起治理非正常申请，材料真实性要求提高（[中国版权保护中心要闻](https://www.ccopyright.com.cn/index.php?optionid=999&method=view&optionid=999&auto_id=1524)）。
- **单机免备案口径**：官方文档给了通道，但审核执行可能有个体差异，需保留承诺函与申诉路径。
- **截图尺寸/字段**：后台可能随版本调整，提审前以页面实际提示为准。

---

## 9. 针对「四象限清单」的具体操作建议

### 9.1 主体路径决策树

```
是否已有可用的企业/组织主体？
├─ 是 → 直接用该主体注册开发者账号（1～3 工作日审核）
└─ 否 → 是否愿意为这个 App 办一个主体？
        ├─ 愿意且长期做 → 注册有限责任公司（最稳）
        ├─ 愿意但想省钱 → 先问小米客服：个体工商户能否按“企业”受理
        │                 ├─ 能 → 办个体工商户
        │                 └─ 不能 → 回公司方案 / 合作主体
        └─ 不愿意 → 只做 GitHub/F-Droid 分发（注意 ADV），或找合作企业代上架
```

### 9.2 推荐执行顺序（已有企业主体版）

1. 用企业主体注册小米开发者账号，完成企业认证（1～3 工作日）；
2. **同时**以企业名义申请软著（软件全称/简称含“四象限清单”，60 日内）；
3. 确认首次启动**隐私政策弹窗**已启用（`PrivacyConsentGate`），保持“设置→关于→隐私政策”3 步可达；
4. 把 `PRIVACY.md` / `docs/privacy.html` 的开发者信息改成企业全称，部署到公网并实测；
5. 确认 `docs/screenshots/` 中 5 张 **1080×1920** 截图与 512×512 图标已就绪；
6. 配置 release keystore，备份，构建 64 位/兼容包，记录证书指纹；
7. 软著下证后，在后台创建应用（包名 `cn.sifen.quadrant`）、填资料、上传软著；
8. 备案信息选择“**无需备案（单机应用）**”+ 单机承诺函；
9. 提交审核，1～3 个工作日跟进；驳回按理由逐条改；
10. 上架后保留 keystore、软著、承诺函、隐私政策归档，准备后续更新。

### 9.3 只有个人身份时的现实选择

| 选择 | 可行性 | 说明 |
| --- | --- | --- |
| 办个体工商户后尝试注册 | 待确认 | 官方“企业”要求三证合一营业执照 + 法大大企业实名；个体户是否受理需问客服 |
| 注册公司 | 可行 | 成本换合规，适合长期 |
| 找企业合作方代上架 | 可行 | 需软著授权/转让、协议、收益归属；隐私政策开发者信息写合作方 |
| 只在 GitHub 分发 | 可行但无商店流量 | 侧载需 ADV 验证；用户安装会看到未验证提示 |
| 用他人软著/伪造资质 | **绝对不可** | 会被下架、冻结账号、纳入信用管理，严重者法律责任 |

### 9.4 可直接使用的上架文案

**应用名称（主标题）**：四象限清单

**副标题（如后台要求）**：零权限纯本地

> 主标题 5 汉字 + 副标题 6 汉字 = 22 个英文字符，符合“主标题+副标题 ≤30 英文字符”；若审核按旧口径要求“名称+描述语 ≤8 汉字”，则去掉副标题只保留“四象限清单”。

**一句话简介**（19 字，≤34 字符，陈述句，无句末标点）：

> 无广告的四象限待办清单，零权限、纯本地

**应用介绍**（约 250 字，20～4000 字区间）：

> 「四象限清单」把待办按“重要 / 紧急”两个维度分成四格：重要且紧急、重要不紧急、紧急不重要、不重要不紧急。打开首页就能一屏看清所有任务，点卡片进入对应象限；长按任务卡片拖到别的象限，就能快速重新分类。支持新建、编辑、删除、勾选完成，可设置截止日期与备注，可显示或隐藏已完成任务并一键清除已完成。深色模式可跟随系统或手动切换。数据只保存在手机本地，设置页支持 JSON 导出到剪贴板与粘贴导入，方便换机备份。应用无广告、无账号、无内购、无统计，AndroidManifest 不声明任何权限（含网络权限），不需要登录，打开就能用。

**关键词（8 个，每个 ≤10 字符）**：

> 四象限 待办 清单 时间管理 效率 极简 本地 无广告

**更新日志（1.0.0）**：

> 首个版本：四象限待办管理、长按拖动换象限、深色模式、JSON 导出与导入、零权限纯本地。

**测试账号栏**：

> 本应用无账号体系，无需登录，无需测试账号。应用零权限、不联网、纯本地。

**截图文案建议**（不放也可以，放了必须与界面一致）：

1. 一屏看清四象限
2. 新建一条待办
3. 长按拖到别的象限
4. 深色模式
5. 数据只在本机

### 9.5 隐私口径必须与 SPEC 一致

写商店介绍、隐私政策、README、关于页时，统一用这 7 条，不要扩写：

1. 不收集、不上传、不共享任何个人信息；
2. 无网络权限，系统层面无法联网；
3. 无账号体系、无第三方 SDK（除 Flutter 引擎与 `shared_preferences` 本地存储）；
4. 数据只存应用私有目录，卸载即删除；
5. 导出由用户主动触发，只进系统剪贴板，不离开设备；
6. 无广告、无统计、无崩溃上报、无内购；
7. 联系方式：1304857605@qq.com。

### 9.6 提审前检查项（代码侧已基本就绪）

> 代码与素材已实现的部分标注为“已完成”，剩余项主要是主体、软著、备案和公网部署。

| 检查项 | 官方要求 | 当前状态 |
| --- | --- | --- |
| 首次启动隐私弹窗 | [应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322) 二 | **已完成**：首帧弹窗，摘要 + “查看政策” + “同意并继续/不同意” |
| 隐私政策开发者信息 | [应用商店上架要求](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322) | 当前为中性表述；确定主体后改成企业全称，同步 `docs/privacy.html` |
| 隐私政策公网 URL | [应用添加隐私政策声明通知](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1170) | 启用 GitHub Pages 后生效；准备备用地址 |
| 截图尺寸 | [应用创建指南](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072) | **已完成**：6 张 1080×1920 截图 |
| release 签名 | [生态政策](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1321) 3.6 | **已完成**：已配置签名，keystore 与密码不入库，需备份 |
| Android 工程 | 上架需要 APK | **已完成**：`android/` 工程、图标、启动图齐全 |

### 9.7 不要做的事

- 不要伪造、购买软著/备案号，不要 P 图改证书；
- 不要用他人软著“借用”上架（授权必须真实、可核验）；
- 不要把隐私政策放到国内打不开的地址（如 `raw.githubusercontent.com`）；
- 不要在应用名/图标/截图里蹭知名应用或含其他市场元素；
- 不要在介绍里写“已上架”“下载量”“排名”等未发生的事实；
- 不要用 debug 签名提审；
- 不要在上架后更换签名（会导致无法更新）。

### 9.8 被驳回时怎么沟通

- 先看后台驳回理由，逐条修改后重提；不要“原样重提”。
- 资质/备案争议：准备包名、应用名、版本号、驳回截图、软著/承诺函/单机说明，联系小米应用商店客服；邮件 developer@xiaomi.com（[开发者生态政策](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1321)）。
- 单机应用被误判为“需备案”：走单机应用客服系统（[APP 备案指引](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1739) FAQ 1）。
- 隐私/权限申诉格式：包名 + 应用名称 + 版本号 + APK 链接、驳回原因、说明、证明材料（[应用隐私合规标准](https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1325) 七）。

---

## 10. 官方来源清单

> 全部为本次查询（2026-11-22）实际访问的官方页面；标注“更新时间”为页面显示时间，可能晚于本文。

### 小米开放平台（dev.mi.com）

| 文档 | 链接 | 页面更新时间 |
| --- | --- | --- |
| 应用商店个人开发者升级公告 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1259 | 2024-10-18 |
| 开发者账号注册标准 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1731 | 2024-09-24 |
| 开发者账号注册认证操作指南 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1145 | 2025-05-12 |
| 开发者账号资料修改操作指南 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1068 | 2025-04-29 |
| 应用创建操作指南 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1072 | 2025-02-27 |
| 应用更新、修改操作指南 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1248 | 2025-05-12 |
| 应用资质 FAQ | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2251 | 2026-01-30 |
| 应用商店上架要求 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1322 | 2025-09-02 |
| 应用审核规范 | https://dev.mi.com/docs/appsmarket/auditing&evaluation/auditing_criterion/ | 旧版页面（部分条款仍引用） |
| 应用审核常见问题 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1252 | 2026-03-10 |
| 开发者生态政策 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1321 | 2025-06-23 |
| 应用和开发者分级管理制度 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1501 | 2026-09-11 |
| APP 备案名称、应用名称、软著名称基本原则 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1796 | 2025-10-27 |
| APP 备案、应用、软著名称不一致处理指南 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1798 | 2024-12-16 |
| 移动应用程序（APP）备案指引 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1739 | 2026-10-25 |
| 移动应用程序（APP）备案信息补充指引 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1775 | 2025-09-18 |
| APP 备案编号的应用内展示指南 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1832 | 2024-09-29 |
| 应用添加隐私政策声明的重要通知 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1170 | 2024-10-23 |
| 隐私政策不合规的问题解析和修改指引 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1792 | 2024-10-24 |
| 应用隐私合规标准 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1325 | 2024-10-08 |
| 应用年龄分级标准 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1855 | 2024-09-24 |
| 应用商店支持 64 位架构适配 | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=1715 | 2024-10-17 |
| 开发者身份验证申请规范（ADV） | https://dev.mi.com/xiaomihyperos/documentation/detail?pId=2366 | 2026-10-21 |
| 应用运营知识：应用的签名 | https://dev.mi.com/docs/appsmarket/operation_docs/app_signature/ | 旧版 |
| 教程：应用提交流程 | https://dev.mi.com/docs/appsmarket/distribution/app_submit/ | 旧版 |
| 开发者账号注册流程（旧版） | https://dev.mi.com/docs/appsmarket/distribution/account_register/ | 旧版（与 1731 冲突，以新规为准） |
| 小米开发者站应用发布协议 | https://dev.mi.com/docs/appsmarket/distribution/agreements/ | — |

### 工信部 / 中国版权保护中心

| 文档 | 链接 |
| --- | --- |
| 工信部《关于开展移动互联网应用程序备案工作的通知》（工信部信管〔2023〕105 号） | https://www.miit.gov.cn/zwgk/zcwj/wjfb/tz/art/2023/art_920db564162e4312916a01bed6540ad8.html |
| 工信部《一图读懂 APP 备案》 | https://www.miit.gov.cn/zwgk/zcjd/art/2023/art_9f3a1277fdcb42d68e1eacd37787ae04.html |
| 工信部备案系统 | https://beian.miit.gov.cn/ |
| 中国版权保护中心 · 软件登记入口 | https://register.ccopyright.com.cn/registration.html#/registerSoft |
| 计算机软件著作权登记指南（申请须知） | https://www.ccopyright.com.cn/index.php?optionid=1057 |
| 所需文件 | https://www.ccopyright.com.cn/index.php?optionid=1080 |
| 填表说明 | https://www.ccopyright.com.cn/index.php?optionid=1081 |
| 办理时限（60 日） | https://www.ccopyright.com.cn/index.php?optionid=1084 |
| 关于停征软件著作权登记缴费的通告 | https://www.ccopyright.com.cn/index.php?optionid=1571 |
| 共同维护计算机软件版权登记良好生态（2026 治理） | https://www.ccopyright.com.cn/index.php?optionid=999&method=view&optionid=999&auto_id=1524 |

---

## 11. 待确认事项（必须问客服/看后台）

以下是公开文档无法 100% 确定、且会直接影响本项目的问题。**不要凭猜测提交，先问小米客服（https://dev.mi.com/platform/contact）或 developer@xiaomi.com。**

1. **个体工商户营业执照能否作为“企业开发者”注册**？官方只写“企业/政府事业单位/其他组织”，个体户未明确。
2. **单机应用“无需备案（单机应用）”+ 承诺函在 2026 年 11 月是否仍被接受**？后台字段与审核口径是否有变化？
3. **个人软著授权给企业主体**时，授权证明是否接受个人签字（无公章）？是否需要公证？
4. **应用主标题“四象限清单”是否会被判“仅类别词”**？建议提交前先在商店搜索并咨询审核标准。
5. **截图是否严格要求 1080×1920**，还是支持 1080×2400？以后台上传页提示为准。
6. **是否对 targetSdk 有最低要求**？当前 targetSdk 36 远高于多数在架应用，理论无障碍，但以平台解析/公告为准。
7. **电子版权认证（易版权）当前的价格、时效、小米认可度**。
8. **应用内是否必须展示“无需备案”说明**（单机应用），还是仅在后台提交承诺函即可。

> 上述问题的答案以官方回复为准；本文档中的“建议做法”是当前官方文档下的最优路径，不替代官方答复。
