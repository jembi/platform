# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# This file is included in the final Docker image and SHOULD be overridden when
# deploying the image to prod. Settings configured here are intended for use in local
# development environments. Also note that superset_config_docker.py is imported
# as a final step as a means to override "defaults" configured here
#

# A list of available feature flags is available at https://github.com/apache/superset/blob/master/RESOURCES/FEATURE_FLAGS.md
# FEATURE_FLAGS = {
# }

# Variables for use in Superset with Jinja templating 
# JINJA_CONTEXT_ADDONS = {
# }


# ---------------------------KEYCLOACK ----------------------------
import os

KC_SUPERSET_SSO_ENABLED = os.getenv('KC_SUPERSET_SSO_ENABLED')

WTF_CSRF_ENABLED = False

if KC_SUPERSET_SSO_ENABLED == "true":
    SECRET_KEY = os.getenv('SUPERSET_SECRET_KEY')
    OIDC_OPENID_REALM = os.getenv('KC_REALM_NAME')
    AUTH_USER_REGISTRATION_ROLE = os.getenv('AUTH_USER_REGISTRATION_ROLE')
    KC_REALM_NAME = os.getenv('KC_REALM_NAME')
    KC_FRONTEND_URL = os.getenv('KC_FRONTEND_URL')

    from keycloack_security_manager  import  OIDCSecurityManager
    from flask_appbuilder.security.manager import AUTH_OID, AUTH_REMOTE_USER, AUTH_DB, AUTH_LDAP, AUTH_OAUTH

    AUTH_TYPE = AUTH_OID
    SECRET_KEY: SECRET_KEY
    OIDC_CLIENT_SECRETS = '/app/pythonpath/client_secret.json'
    OIDC_ID_TOKEN_COOKIE_SECURE = False
    OIDC_REQUIRE_VERIFIED_EMAIL = False
    OIDC_OPENID_REALM: OIDC_OPENID_REALM
    OIDC_INTROSPECTION_AUTH_METHOD: 'client_secret_post'
    CUSTOM_SECURITY_MANAGER = OIDCSecurityManager
    AUTH_USER_REGISTRATION = True
    AUTH_USER_REGISTRATION_ROLE = AUTH_USER_REGISTRATION_ROLE
    OIDC_VALID_ISSUERS = [KC_FRONTEND_URL + '/realms/' + KC_REALM_NAME]
    ENABLE_PROXY_FIX = True

