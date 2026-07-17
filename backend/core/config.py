import os

class Settings:
    PROJECT_NAME: str = "CERAGEM SOMALIA Management System"
    SECRET_KEY: str = os.getenv("SECRET_KEY", "a_very_secret_key_for_jwt_token")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7 # 7 days

settings = Settings()
