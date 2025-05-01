from pydantic_settings import BaseSettings
class Settings(BaseSettings):
    email:str
    password:str
    class Config:
        env_file=".env"
        env_file_encoding='utf-8'
        case_sensitive=False
        