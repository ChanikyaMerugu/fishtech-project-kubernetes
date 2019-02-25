#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "chanu" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
      "Name", "terraform-eks-fishtech-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "chanu" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.chanu.id}"

  tags = "${
    map(
      "Name", "terraform-eks-chanu-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "chanu" {
  vpc_id = "${aws_vpc.chanu.id}"

  tags = {
    Name = "terraform-eks-chanu"
  }
}

resource "aws_route_table" "chanu" {
  vpc_id = "${aws_vpc.chanu.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.chanu.id}"
  }
}

resource "aws_route_table_association" "chanu" {
  count = 2

  subnet_id      = "${aws_subnet.chanu.*.id[count.index]}"
  route_table_id = "${aws_route_table.chanu.id}"
}
