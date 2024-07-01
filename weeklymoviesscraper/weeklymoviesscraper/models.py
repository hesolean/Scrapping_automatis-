from sqlalchemy import TEXT, Date, Table, Column, ForeignKey, Integer, String, Float
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

# table de jointure M2M entre Media et Person
media_person_association = Table('media_person_association', Base.metadata,
                                 Column('media_id', Integer, ForeignKey('medias.id')),
                                 Column('person_id', Integer, ForeignKey('persons.id')))

# table de jointure M2M entre Media et Gender
media_gender_association = Table('media_gender_association', Base.metadata,
                                 Column('media_id', Integer, ForeignKey('medias.id')),
                                 Column('gender_id', Integer, ForeignKey('genders.id')))

class Media(Base):
    __tablename__ = 'medias'

    id = Column(Integer, primary_key=True)
    title = Column(String(255), nullable=False)
    original_title = Column(String(255))
    presse_score = Column(Float)
    viewer_score = Column(Float)
    sessions = Column(Integer)
<<<<<<< HEAD
    exit_date = Column(String(255))
=======
    exit_date = Column(Date)
>>>>>>> b245534bfed11dc88b4ebfe0ff5d54e4d4c8ae58
    duration = Column(Integer)
    synopsis = Column(TEXT)
    public = Column(String(255))
    country = Column(String(255))
    language = Column(String(255))
    distributor = Column(String(255))
    product_year = Column(Integer)
    media_type = Column(String(255))
    visa = Column(Integer)

    # relation M2M avec persons
    persons = relationship('Person', secondary=media_person_association, back_populates='medias')
    # relation M2M avec genders
    genders = relationship('Gender', secondary=media_gender_association, back_populates='medias')

class Person(Base):
    __tablename__ = "persons"

    id = Column(Integer, primary_key=True)
    first_name = Column(String(255))
    last_name = Column(String(255))
    role = Column(String(255), nullable=False)

    # relation M2M avec medias
    medias = relationship('Media', secondary=media_person_association, back_populates='persons')

class Gender(Base):
    __tablename__ = "genders"

    id = Column(Integer, primary_key=True)
    gender = Column(String(255), nullable=True)

    # relation M2M avec medias
    medias = relationship('Media', secondary=media_gender_association, back_populates='genders')
