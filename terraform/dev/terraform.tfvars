region = "eu-west-1"
environment = "dev"
prefix = "gst"
owner = "gstudzinski"

vpc_cidr = "10.0.0.0/16"
db_user = "user"
db_password = "user_secret_pw"
db_name = "db"
db_port = 3306

app_db_port = 8080
app_db_health = "/db/api/health"
app_db_root_path = "/db**"
app_db_image = "890769921003.dkr.ecr.eu-west-1.amazonaws.com/aws-db:latest"

app_s3_port = 8081
app_s3_health = "/s3/api/health"
app_s3_root_path = "/s3**"
app_s3_image = "890769921003.dkr.ecr.eu-west-1.amazonaws.com/aws-s3:latest"
