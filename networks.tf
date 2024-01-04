resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"
  tags = {
    Name = "master-vpc-jenkins"
  }
}

resource "aws_vpc" "vpc_master_oregon" {
  provider             = aws.region-worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"
  tags = {
    Name = "worker-vpc-jenkins"
  }
}

resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
}

resource "aws_internet_gateway" "igw-oregon" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_master_oregon.id
}

data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.vpc_master.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = element(data.aws_availability_zones.azs.names, 0)
  map_public_ip_on_launch = true
  provider                = aws.region-master
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.vpc_master.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = element(data.aws_availability_zones.azs.names, 1)
  map_public_ip_on_launch = true
  provider                = aws.region-master
}

resource "aws_subnet" "subnet_1_oregon" {
  vpc_id                  = aws_vpc.vpc_master_oregon.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = true
  provider                = aws.region-worker
}

# Peering Connection Request
resource "aws_vpc_peering_connection" "useast1-uswest2" {
  provider    = aws.region-master
  peer_vpc_id = aws_vpc.vpc_master_oregon.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.region-worker

  tags = {
    Name = "vpc_pcon_useast1-uswest2"
  }
}
# Accept VPC peering request in us-west-2 from us-east-1
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  auto_accept               = true
}

# Routing table
resource "aws_route_table" "internet_route" {
  vpc_id   = aws_vpc.vpc_master.id
  provider = aws.region-master
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Master-Region-RT"
  }
}

#Override default route table of VPC(Master) with our route table entries
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  route_table_id = aws_route_table.internet_route.id
  vpc_id         = aws_vpc.vpc_master.id
  provider       = aws.region-master
}

#create route table is us-west-2
resource "aws_route_table" "internet_route_oregon" {
  vpc_id   = aws_vpc.vpc_master_oregon.id
  provider = aws.region-worker

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-oregon.id
  }
  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Worker-Region-RT"
  }
}

#Override default route table of VPC(Worker) with our route table entries
resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  route_table_id = aws_route_table.internet_route_oregon.id
  vpc_id         = aws_vpc.vpc_master_oregon.id
  provider       = aws.region-worker
}

















