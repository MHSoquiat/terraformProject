resource "aws_vpc" "soki-vpc" {
  cidr_block           = var.vpc_cidr
  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-vpc"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}

resource "aws_subnet" "subnet" {
  for_each                = var.subnet
  vpc_id                  = aws_vpc.soki-vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.pub ? true : false
  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-${each.key}"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.soki-vpc.id
  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-igw"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}

resource "aws_eip" "eip" {
  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-eip"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}

resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.subnet["pub_sub-2"].id
  allocation_id = aws_eip.eip.id
  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-ngw"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.soki-vpc.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-pubrt"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}

resource "aws_route_table" "priv_rt" {
  vpc_id = aws_vpc.soki-vpc.id
  tags = merge(
    var.tags,
    {
      Name        = "${var.tags["Name"]}-privrt"
      Engineer    = var.tags["Engineer"]
      ProjectCode = var.tags["ProjectCode"]
    }
  )
}

resource "aws_route" "pub-route" {
  route_table_id         = aws_route_table.pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "priv-route" {
  route_table_id         = aws_route_table.priv_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.ngw.id
}

resource "aws_route_table_association" "pub_subnet_association" {
  for_each       = var.pub_subnet_keys
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "priv_subnet_association" {
  for_each       = var.priv_subnet_keys
  subnet_id      = aws_subnet.subnet[each.value].id
  route_table_id = aws_route_table.priv_rt.id
}
