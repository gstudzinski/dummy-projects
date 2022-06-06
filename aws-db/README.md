# DB App - devops upskill

### Environment vars

`DB_HOST`  
`DB_PASS`


### MySQL as docker
`docker run --name app-db-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root-secret-pw -e MYSQL_DATABASE=db -e MYSQL_USER=user -e MYSQL_PASSWORD=user-secret-pw -d mysql:8.0`

