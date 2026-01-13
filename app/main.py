from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel, Field
import jwt
import time
from fastapi.responses import PlainTextResponse
import os


API_KEY = os.getenv("API_KEY", "")
JWT_SECRET = os.getenv("JWT_SECRET", "")


app = FastAPI()

class DevOpsRequest(BaseModel):
    message: str
    to: str
    from_: str = Field(alias="from")
    timeToLifeSec: int

def validate_jwt(token: str):
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        if payload.get("exp", 0) < time.time():
            raise Exception()
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid JWT")

@app.post("/DevOps")
def devops_endpoint(
    body: DevOpsRequest,
    x_parse_rest_api_key: str = Header(..., alias="X-Parse-REST-API-Key"),
    x_jwt_kwy: str = Header(..., alias="X-JWT-KWY"),
):
    if x_parse_rest_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")

    validate_jwt(x_jwt_kwy)

    return {"message": f"Hello {body.to} your message will be send"}

@app.api_route("/DevOps", methods=["GET", "PUT", "DELETE", "PATCH"])
def devops_other_methods():
    return "ERROR"

@app.get("/token", response_class=PlainTextResponse)
def generate_token():
    payload = {
        "iat": int(time.time()),
        "exp": int(time.time()) + 120  
    }
    token = jwt.encode(payload, JWT_SECRET, algorithm="HS256")
    return token