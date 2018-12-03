.PHONY: decrypt

config_bucket := serviceNSW-dev-config
base_ami_id := $(shell aws s3 cp s3://$(config_bucket)/trusty-ubuntu-base-ami -)
version := $(shell xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' pom.xml)
image_id := $(shell cat ./manifest.json | jq -r '.builds| sort_by(-.build_time)[0].artifact_id | split(":") | .[1]')

db_user := AQICAHgjp8JqMhZ5vNctS3BExPMBqLTQzAZDjF0ZIhGwFC/zBwEMcZI5AmoM7RthJT74+ECPAAAAZTBjBgkqhkiG9w0BBwagVjBUAgEAME8GCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMr7xb/uRXUgskTuq7AgEQgCKrcUI5NmP/QbW0heolRfjQdKchoQjhE0O6rENu9PpZiT08
db_pass := AQICAHgjp8JqMhZ5vNctS3BExPMBqLTQzAZDjF0ZIhGwFC/zBwGTDStzxbeEvOUNwvW/3N2xAAAAaTBnBgkqhkiG9w0BBwagWjBYAgEAMFMGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMgHY0L52+GPmda3yOAgEQgCahuPyporI/IIG7YdGSJWu1MHsQ+FIsacyGPgUyYduKeI4Q/3x7WA==
token := AQICAHgjp8JqMhZ5vNctS3BExPMBqLTQzAZDjF0ZIhGwFC/zBwGMrYqNnezdjjERw+1CE7Q4AAAAgzCBgAYJKoZIhvcNAQcGoHMwcQIBADBsBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDMu5WXMVbnLoEG/YPQIBEIA/9T9TV2sXQw1F1yLPKbX5ljBSGpy+wScd/NZHDMte4wtkS3hkWU5yWyA9mITKA6LYQR44J7+/z8M9V4r8lrfv
secret := AQICAHgjp8JqMhZ5vNctS3BExPMBqLTQzAZDjF0ZIhGwFC/zBwHXhQOXSPYHCePFmAz4x9ZpAAAAbjBsBgkqhkiG9w0BBwagXzBdAgEAMFgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM/7JOPOtWnytmvIMCAgEQgCtr3xLmcd81M6xP64mmv9QXxgvncoII7m1A2WXT9rLZ4Ub7/69Tsi8So/ej
export APP_NAME ?= az-a-pci-amaysim-channel-web

deps:
	@docker-compose build shush_decrypt > /dev/null

build:
	@echo "----------------- Build Jar"
	@echo "----- USE DEV ACCOUNT -----"
	@docker-compose run maven mvn -U clean install

package:
	@echo "----------------- Using Packer"
	@BASE_AMI_ID=$(base_ami_id) VERSION=$(version) docker-compose run --rm packer_build build /build/packer.json

deploy-test: deps
	@echo "----------------- Deploy AMI to cloudformation for test"
	@docker-compose run --rm stackup $(APP_NAME) up -t /build/cfn/app.yml -p /build/cfn/params.yml \
	    -o BaseAMI=$(packer-ami-id) \
	    -o DatabaseUser=$$(docker-compose run shush_decrypt $(db_user)) \
        -o DatabasePassword=$$(docker-compose run shush_decrypt $(db_pass)) \
	    -o AuthToken=$$(docker-compose run shush_decrypt $(token)) \
	    -o HMACSecret=$$(docker-compose run shush_decrypt $(secret))

deploy: deps
	@echo "----------------- Deploy AMI to cloudformation for prod"
	@docker-compose run --rm stackup $(APP_NAME) up -t /build/cfn/app.yml -p /build/cfn/params.yml \
			-o BaseAMI=$(packer-ami-id) \
			-o DatabaseUser=$$(docker-compose run shush_decrypt $(db_user)) \
			  -o DatabasePassword=$$(docker-compose run shush_decrypt $(db_pass)) \
			-o AuthToken=$$(docker-compose run shush_decrypt $(token)) \
			-o HMACSecret=$$(docker-compose run shush_decrypt $(secret))

clean:
	@echo "------------------ Clean Old AMIs"
	@docker-compose run --rm ami_clean --mapping-key tags --mapping-values $(APP_NAME) --keep-previous 3 -f


destroy:
	@echo "----------------- destroy cloudformation stack!!"
	@docker-compose run --rm stackup $(APP_NAME) delete
