# 📋 TODO — Principle gaps to fill

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
