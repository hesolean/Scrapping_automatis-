import os

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from weeklymoviesscraper.models import Base

DATABASE_URL = os.getenv("DATABASE_URL","mysql://myuser:mypassword@localhost/mydatabase")
TEST_DATABASE_URL = os.getenv("TEST_DATABASE_URL","mysql://testuser:testpassword@localhost/testdb")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.create_all(bind=engine)