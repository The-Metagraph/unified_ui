.PHONY: conformance conformance-report conformance-ci rfc-governance rfc-governance-debt-scan rfc-specs-dry-run rfc-specs-generate release-readiness release-readiness-report assets-setup assets-build assets-css-watch

conformance:
	./scripts/run_conformance.sh

conformance-report:
	./scripts/run_conformance.sh --report-only

conformance-ci:
	./scripts/run_conformance.sh

rfc-governance:
	./scripts/validate_rfc_governance.sh

rfc-governance-debt-scan:
	./scripts/scan_rfc_governance_debt.sh

rfc-specs-dry-run:
	@test -n "$(RFC)" || (echo "Usage: make rfc-specs-dry-run RFC=rfcs/RFC-XXXX-title.md" && exit 1)
	./scripts/gen_specs_from_rfc.sh --rfc "$(RFC)" --dry-run

rfc-specs-generate:
	@test -n "$(RFC)" || (echo "Usage: make rfc-specs-generate RFC=rfcs/RFC-XXXX-title.md [OVERWRITE=1]" && exit 1)
	@if [ "$(OVERWRITE)" = "1" ]; then \
		./scripts/gen_specs_from_rfc.sh --rfc "$(RFC)" --overwrite; \
	else \
		./scripts/gen_specs_from_rfc.sh --rfc "$(RFC)"; \
	fi

release-readiness:
	./scripts/run_release_readiness.sh

release-readiness-report:
	./scripts/run_release_readiness.sh --report-only

assets-setup:
	mix assets.setup

assets-build:
	mix assets.build

assets-css-watch:
	mix assets.css.watch
