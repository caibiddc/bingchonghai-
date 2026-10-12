"""Lightweight regression tests; no model weights or GPU required."""
import unittest
from flask import Flask, jsonify, g
from common.utils.jwt_utils import JWTUtils, apply_auth_decorators
from config.app_config import Config


class AuthContextTests(unittest.TestCase):
    def setUp(self):
        self.saved_secret = Config.JWT_SECRET
        Config.JWT_SECRET = "regression-test-secret-not-for-production"
        self.app = Flask(__name__)

        @self.app.get("/admin")
        @apply_auth_decorators("admin")
        def admin():
            return jsonify({"userId": g.user_info["userId"]})

        self.client = self.app.test_client()

    def tearDown(self):
        Config.JWT_SECRET = self.saved_secret

    def test_user_context_not_stored_on_global_application(self):
        token = JWTUtils.generate_token("123", "admin", ["admin"])
        result = self.client.get("/admin", headers={"Authorization": "Bearer " + token})
        self.assertEqual(result.status_code, 200)
        self.assertEqual(result.get_json()["userId"], "123")
        self.assertFalse(hasattr(self.app, "user_info"))

    def test_unauthorized_role_and_missing_bearer(self):
        token = JWTUtils.generate_token("456", "viewer", ["user"])
        result = self.client.get("/admin", headers={"Authorization": "Bearer " + token})
        self.assertEqual(result.status_code, 403)
        result = self.client.get("/admin")
        self.assertEqual(result.status_code, 401)


if __name__ == "__main__":
    unittest.main()
