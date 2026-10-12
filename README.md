# 农作物病虫害诊断平台（Web / Backend / AI）

- `apps/web`: React / Vite 前端
- `apps/backend`: NestJS API 网关与微服务
- `services/ai`: Flask / Celery / PyTorch 诊断推理

移动应用维护在独立仓库： https://github.com/caibiddc/AgriculturalDiagnosticApp

原仓库所有提交历史均以未压缩的 git subtree 方式保留。

尚未完成学校正式漏洞扫描、GPU 模型与全链路验收，禁止在公网直接暴露数据库/Redis/微服务端口。
