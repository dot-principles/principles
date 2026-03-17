# 📋 TODO — Principle gaps to fill

## 🚢 Continuous delivery practices
New namespace: `cd`

- [ ] Trunk-based development — commit to the main branch frequently; avoid long-lived feature branches
- [ ] Keep the build green — a failing build is the team's highest priority; nothing else ships until it passes
- [ ] Deploy on every commit — the pipeline should be capable of releasing any green commit to production
- [ ] Feature flags for continuous delivery — decouple deployment from release; hide incomplete work behind flags rather than branches
- [ ] Fast feedback loops — optimise the pipeline so engineers know within minutes whether a change is safe
- [ ] GitOps — infrastructure and application state is declared in git; an operator continuously reconciles actual state to match

## 🌐 API design
Extend `code/api`

- [ ] API versioning strategy — version APIs explicitly; define a policy for introducing breaking changes and supporting deprecated versions
- [ ] gRPC / Protobuf design — define service contracts in `.proto` files; use field numbers for backward compatibility; prefer streaming for high-throughput flows

## ⚙️ Configuration file principles
New namespace: `config-principles` (to populate the `config` group more fully)

- [ ] Schema-first configuration — every config file has a declared schema; invalid configuration is rejected at load time, not discovered at runtime
- [ ] Explicit over conventional — prefer named, explicit configuration keys over magic conventions that require knowing the framework defaults

## 📝 Documentation principles
New namespace: `docs-principles` (to populate the `docs` group more fully)

- [ ] Docs as code — documentation lives in version control, is reviewed like code, and is built/validated in CI
- [ ] Write for a specific audience — every document has a named reader; structure and vocabulary serve that reader, not the author
- [ ] Progressive disclosure — lead with the summary; let readers drill into detail on demand; never bury the conclusion
- [ ] Docs close to code — documentation lives alongside what it describes; distance between docs and code invites drift
