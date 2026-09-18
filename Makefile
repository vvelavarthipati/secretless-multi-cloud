.PHONY: model fmt validate

model:
	python3 simulation/exposure_model.py

fmt:
	terraform fmt -recursive infra/aws

validate:
	python3 -m json.tool infra/aws/trust-policy.template.json >/dev/null
	python3 simulation/exposure_model.py