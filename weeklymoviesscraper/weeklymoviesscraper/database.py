import os

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from weeklymoviesscraper.models import Base
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.create_all(bind=engine)