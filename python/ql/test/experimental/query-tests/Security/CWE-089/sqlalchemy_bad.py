import sqlalchemy
from sqlalchemy import Column, Integer, String, ForeignKey, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, backref, sessionmaker, joinedload
from sqlalchemy.sql import text
from sqlescapy import sqlescape


engine = create_engine('sqlite:///:memory:', echo=True)
Base = declarative_base()

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    name = Column(String)

Base.metadata.create_all(engine)

Session = sessionmaker(bind=engine)
session = Session()

ed_user = User(name='ed')
ed_user2 = User(name='george')

session.add(ed_user)
session.add(ed_user2)

session.commit()

malicious_user_input = sys.argv[1]
malicious_user_input = text("name='{}'".format(malicious_user_input))
session.query(User).filter(malicious_user_input).count()
