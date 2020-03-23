resource "aws_instance" "glueSparkJupyterHub" {
  ami = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "m5.large"
  key_name = "${var.aws_key_name}"
  iam_instance_profile = "${var.iam_instance_profile}"
  user_data = "${file("userdata_install_app.sh")}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  associate_public_ip_address = true
  root_block_device {
    volume_size = "50"
  }
  tags {
    Name = "glueSparkJupyterHub"
    auto-delete = "no"
  }
}
