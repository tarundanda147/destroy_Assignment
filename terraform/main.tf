resource "aws_vpc" "new_vpc" {
  cidr_block = "172.16.0.0/20"
  
  tags = {
    Name = "new_vpc"
  }
}

resource "aws_internet_gateway" "tarun_igw" {
  vpc_id = aws_vpc.new_vpc.id

  tags = {
    Name = "tarun_igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.new_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tarun_igw.id
  }
}

resource "aws_subnet" "example_subnet" {
  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = "172.16.0.0/22"  
  availability_zone = "ap-south-1a"

  tags = {
    Name = "example_subnet"
  }
}

resource "aws_route_table_association" "example_subnet_association" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "all_traffic" {
  name        = "all_traffic"
  description = "Allow all inbound and all outbound traffic"
  vpc_id      = aws_vpc.new_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test_first" {
  ami                          = "ami-03bb6d83c60fc5f7c"
  instance_type                = "t2.medium"
  key_name                     = "test1"
  vpc_security_group_ids       = [aws_security_group.all_traffic.id]
  subnet_id                    = aws_subnet.example_subnet.id
  associate_public_ip_address  = true
  user_data                    = data.template_file.web_userdata.rendered
  tags = {
    Name     = "HelloWorld"
    Stage    = "testing"
    Location = "India"
  }
}

data "template_file" "web_userdata" {
   template = file("dockerinstall.sh")
}
