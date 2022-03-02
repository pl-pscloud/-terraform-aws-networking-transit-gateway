resource "aws_ec2_transit_gateway" "pscloud-transit-gateway" {
  amazon_side_asn                 = var.pscloud_asn
  auto_accept_shared_attachments  = var.pscloud_auto_accept_shared_attachments
  default_route_table_association = var.pscloud_default_route_table_association
  default_route_table_propagation = var.pscloud_default_route_table_propagation
  dns_support                     = var.pscloud_dns_support
  vpn_ecmp_support                = var.pscloud_vpn_ecmp_support

  tags = {
    Name = "${var.pscloud_company}_vpc_transit_gateway_${var.pscloud_project}_${var.pscloud_env}"
  }
}


######################## ATTACHMENTS
resource "aws_ec2_transit_gateway_vpc_attachment" "pscloud-tgw-attachment" {
  for_each            = var.pscloud_vpc_attachments

  subnet_ids          = each.value.subnets_ids
  transit_gateway_id  = aws_ec2_transit_gateway.pscloud-transit-gateway.id
  vpc_id              = each.value.vpc_id

  transit_gateway_default_route_table_association = var.pscloud_default_route_table_association == "enable" ? true : false 
  transit_gateway_default_route_table_propagation = var.pscloud_default_route_table_propagation == "enable" ? true : false

  tags = {
    Name = "${var.pscloud_company}_tgw_attachment_${each.value.name}_${var.pscloud_env}"
  }

  depends_on = [ aws_ec2_transit_gateway.pscloud-transit-gateway ]
}

resource "aws_ec2_transit_gateway_peering_attachment" "pscloud-tgw-peering-attachment" {
  for_each = {
    for key, val in var.pscloud_peer_attachments : key => val
    if val.name != ""
  }

  peer_account_id         = each.value.peer_account_id
  peer_region             = each.value.peer_region
  peer_transit_gateway_id = each.value.peer_tgw_id
  transit_gateway_id      = aws_ec2_transit_gateway.pscloud-transit-gateway.id

  tags = {
    Name = "${var.pscloud_company}_tgw_peer_attachment_${each.value.name}_${var.pscloud_env}"
  }
}

#######################
resource "aws_ec2_transit_gateway_route_table" "pscloud-tgw-route-tables" {
  for_each            = var.pscloud_route_tables

  transit_gateway_id = aws_ec2_transit_gateway.pscloud-transit-gateway.id
  
  tags = {
    Name = "${var.pscloud_company}_tgw_rt_${each.value.name}_${var.pscloud_env}"
  }

  depends_on = [ aws_ec2_transit_gateway.pscloud-transit-gateway ]
}


resource "aws_ec2_transit_gateway_route_table_association" "pscloud-tgw-rt-association" {
  for_each            = var.pscloud_route_table_associations

  transit_gateway_attachment_id  = each.value.attachment_type == "vpn" || (each.value.attachment_type == "vpc" && each.value.attachment_id != "") ? each.value.attachment_id : (each.value.attachment_type == "vpc" ? aws_ec2_transit_gateway_vpc_attachment.pscloud-tgw-attachment[each.value.attachment_name].id : aws_ec2_transit_gateway_peering_attachment.pscloud-tgw-peering-attachment[each.value.attachment_name].id)
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.pscloud-tgw-route-tables[each.value.route_table_name].id 

  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.pscloud-tgw-attachment, aws_ec2_transit_gateway_route_table.pscloud-tgw-route-tables ]
}


resource "aws_ec2_transit_gateway_route_table_propagation" "pscloud-tgw-rt-propagation" {
  for_each            = var.pscloud_route_table_propagations


  transit_gateway_attachment_id  = each.value.attachment_type == "vpn" || (each.value.attachment_type == "vpc" && each.value.attachment_id != "") ? each.value.attachment_id : (each.value.attachment_type == "vpc" ? aws_ec2_transit_gateway_vpc_attachment.pscloud-tgw-attachment[each.value.attachment_name].id : aws_ec2_transit_gateway_peering_attachment.pscloud-tgw-peering-attachment[each.value.attachment_name].id)
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.pscloud-tgw-route-tables[each.value.route_table_name].id 

  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.pscloud-tgw-attachment, aws_ec2_transit_gateway_route_table.pscloud-tgw-route-tables ]
}

resource "aws_ec2_transit_gateway_route" "pscloud-tgw-route" {
  for_each            = var.pscloud_route_table_routes

  destination_cidr_block         = each.value.cidr
  transit_gateway_attachment_id  = each.value.attachment_type == "vpn" ? each.value.attachment_id : (each.value.attachment_type == "vpc" ? aws_ec2_transit_gateway_vpc_attachment.pscloud-tgw-attachment[each.value.attachment_name].id : aws_ec2_transit_gateway_peering_attachment.pscloud-tgw-peering-attachment[each.value.attachment_name].id)
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.pscloud-tgw-route-tables[each.value.route_table_name].id 
  blackhole                      = each.value.blackhole

  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.pscloud-tgw-attachment, aws_ec2_transit_gateway_route_table.pscloud-tgw-route-tables ]
}


