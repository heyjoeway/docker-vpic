# docker-vpic
Instantly host the NHTSA vPIC MS SQL backup

# Quick Start

```
docker run --name vpic --platform linux/amd64 --env MSSQL_SA_PASSWORD=VpicTest1 -p 1433:1433 heyjoeway/docker-vpic
```

# Building Locally
```
git clone https://github.com/heyjoeway/docker-vpic.git
cd docker-vpic
docker build -t docker-vpic .
docker run --name vpic --env MSSQL_SA_PASSWORD=VpicTest1 docker-vpic
```