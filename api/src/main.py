from fastapi import FastAPI
from pydantic import BaseModel

import repository
import config

class Feedback(BaseModel):
    username: str
    text: str

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/feedback")
def get_feedback():
    response = repository.get_feedback()
    return response['Items']

@app.post('/feedback')
def post_feedback(feedback: Feedback):
    return repository.put_feedback(feedback.username, feedback.text)

@app.get("/info")
def get_info():
    app_version = config.VERSION
    replica_id = repository.get_replica_id()
    return {'version': app_version, 'replica': replica_id}