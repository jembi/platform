from flask import redirect, request
from flask_appbuilder.security.manager import AUTH_OID
from superset.security import SupersetSecurityManager
from flask_oidc import OpenIDConnect
from flask_appbuilder.security.views import AuthOIDView
from flask_login import login_user
from urllib.parse import quote
from flask_appbuilder.views import ModelView, SimpleFormView, expose
import logging
import urllib.parse

class OIDCSecurityManager(SupersetSecurityManager):

    def __init__(self, appbuilder):
        super(OIDCSecurityManager, self).__init__(appbuilder)
        if self.auth_type == AUTH_OID:
            self.oid = OpenIDConnect(self.appbuilder.get_app)
        self.authoidview = AuthOIDCView

class AuthOIDCView(AuthOIDView):

    @expose('/login/', methods=['GET', 'POST'])
    def login(self, flag=True):
        sm = self.appbuilder.sm
        oidc = sm.oid

        @self.appbuilder.sm.oid.require_login
        def handle_login():
            user = sm.auth_user_oid(oidc.user_getfield('email'))

            if user is None:
                info = oidc.user_getinfo(['preferred_username', 'given_name', 'family_name', 'email'])
                firstname = ""
                lastname = ""
                if not info.get('given_name'):
                    firstname = info.get('preferred_username')
                else:
                    firstname = info.get('given_name')
                if not info.get('family_name'):
                    lastname = info.get('preferred_username')
                else:
                    lastname = info.get('family_name')
                user = sm.add_user(info.get('preferred_username'), firstname, lastname,
                                   info.get('email'), sm.find_role('Admin'))

            login_user(user, remember=False)
            return redirect(self.appbuilder.get_url_for_index)

        return handle_login()

    @expose('/logout/', methods=['GET', 'POST'])
    def logout(self):
        oidc = self.appbuilder.sm.oid

        oidc.logout()
        super(AuthOIDCView, self).logout()
        redirect_url = urllib.parse.quote_plus(request.url_root.strip('/') + self.appbuilder.get_url_for_login)

        return redirect(
            oidc.client_secrets.get('issuer') + '/protocol/openid-connect/logout?client_id=' + oidc.client_secrets.get('client_id') + '&post_logout_redirect_uri=' + quote(redirect_url))


    @expose('/backchannel-logout/', methods=['GET', 'POST'])
    def backchannel_logout(self):
        oidc = self.appbuilder.sm.oid

        oidc.logout()
        super(AuthOIDCView, self).logout()        
        redirect_url = request.url_root.strip('/') + self.appbuilder.get_url_for_login
        
        return redirect(oidc.client_secrets.get('issuer') + '/protocol/openid-connect/logout')
