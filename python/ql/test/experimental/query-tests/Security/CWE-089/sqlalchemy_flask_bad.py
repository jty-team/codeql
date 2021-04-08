from flask import Flask, request
from flask_sqlalchemy import SQLAlchemy
import json
from sqlalchemy.sql import text


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
app.config['SQLALCHEMY_ECHO'] = True
db = SQLAlchemy(app)

class User(db.Model):
    uid = db.Column(db.Integer, primary_key=True, autoincrement=True)
    email = db.Column(db.String(50))

    def __init__(self, email):
        self.email = email

db.create_all()

user1 = User(email='admin@example.com')
user2 = User(email='admin2@example.com')
db.session.add(user1)
db.session.add(user2)
db.session.commit()

@app.route('/')
def user_count():
    user_info = json.loads(request.args['user_info'])
    sql_query = "email='{}'".format(user_info['email'])
    user_count = db.session.query(User).filter(sql_query).count()

    return "Users found: {}".format(user_count)

# if __name__ == '__main__':
#     app.run(debug=True)
