import json
import os
import ssl

import boto3
import pymysql
from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates


app = FastAPI()

templates = Jinja2Templates(directory="templates")


# ##############################################################################
# Environment Variables
# ##############################################################################

AWS_REGION = os.getenv("AWS_REGION", "ap-northeast-1")
DB_SECRET_ARN = os.getenv("DB_SECRET_ARN")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME", "company")
DB_PORT = int(os.getenv("DB_PORT", "3306"))


# ##############################################################################
# Secrets Manager
# ##############################################################################

def get_db_secret():
    if not DB_SECRET_ARN:
        raise RuntimeError("DB_SECRET_ARN 환경변수가 설정되지 않았습니다.")

    client = boto3.client(
        "secretsmanager",
        region_name=AWS_REGION
    )

    response = client.get_secret_value(
        SecretId=DB_SECRET_ARN
    )

    return json.loads(response["SecretString"])


# ##############################################################################
# RDS Proxy Connection
# ##############################################################################

def get_db_connection():
    if not DB_HOST:
        raise RuntimeError("DB_HOST 환경변수가 설정되지 않았습니다.")

    secret = get_db_secret()

    ssl_context = ssl.create_default_context()
    ssl_context.check_hostname = False
    ssl_context.verify_mode = ssl.CERT_NONE

    return pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=secret["username"],
        password=secret["password"],
        database=DB_NAME,
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        ssl=ssl_context
    )


# ##############################################################################
# Database Initialization
# ##############################################################################

def initialize_database():
    connection = get_db_connection()

    try:
        with connection.cursor() as cursor:

            # 회사 정보 테이블
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS company_info (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    company_name VARCHAR(100) NOT NULL,
                    message VARCHAR(255) NOT NULL
                )
                """
            )

            cursor.execute(
                """
                SELECT COUNT(*) AS count
                FROM company_info
                """
            )

            result = cursor.fetchone()

            if result["count"] == 0:
                cursor.execute(
                    """
                    INSERT INTO company_info (
                        company_name,
                        message
                    )
                    VALUES (%s, %s)
                    """,
                    (
                        "Megazone Bootcamp",
                        "FastAPI + RDS Proxy + MySQL 정상 연결"
                    )
                )

            # RDS 연결 확인용 테이블
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS connection_status (
                    id INT PRIMARY KEY,
                    status VARCHAR(50) NOT NULL
                )
                """
            )

            cursor.execute(
                """
                INSERT INTO connection_status (
                    id,
                    status
                )
                VALUES (1, 'success')
                ON DUPLICATE KEY UPDATE
                    status = 'success'
                """
            )

        connection.commit()

    finally:
        connection.close()


# ##############################################################################
# Company Page
# ##############################################################################

@app.get("/api/company")
def company(request: Request):
    initialize_database()

    connection = get_db_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    company_name,
                    message
                FROM company_info
                ORDER BY id
                LIMIT 1
                """
            )

            company_data = cursor.fetchone()

    finally:
        connection.close()

    return templates.TemplateResponse(
        request=request,
        name="company.html",
        context={
            "company_name": company_data["company_name"],
            "message": company_data["message"],
            "db_name": DB_NAME
        }
    )


# ##############################################################################
# RDS Connection Test
#
# 실제 RDS MySQL 테이블에서 status 값을 조회
# ##############################################################################

@app.get("/api/rds-test")
def rds_test():
    initialize_database()

    connection = get_db_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT status
                FROM connection_status
                WHERE id = 1
                """
            )

            result = cursor.fetchone()

    finally:
        connection.close()

    return {
        "database": "RDS MySQL",
        "connection": "RDS Proxy",
        "status": result["status"]
    }


# ##############################################################################
# Health Check
# ##############################################################################

@app.get("/api/health")
def health():
    return {
        "status": "ok"
    }