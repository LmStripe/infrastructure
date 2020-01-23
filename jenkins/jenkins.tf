resource "aws_instance" "jenkins" {
  depends_on                  = ["aws_key_pair.jenkins"]
  instance_type               = "${var.instance_type}"
  ami                         = "${var.ami}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = "true"
  security_groups             = ["allow_ssh_and_jenkins"]


  provisioner "remote-exec" {
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file(var.ssh_key_location)}"
    }

    inline = [
	"sudo yum install java-1.8.0-openjdk-devel curl -y",
        "curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo",
        "sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key",
        "sudo yum install jenkins -y",
        "sudo systemctl start jenkins",
        "sudo curl -fsSL https://get.docker.com/ | sh",
	"sudo systemctl enable docker", 
	"sudo systemctl start docker",
	"echo usermod",
        "sudo usermod -aG docker  -s /bin/bash jenkins", 
	"sudo cp -r /etc/skel/.*	/var/lib/jenkins",
        "sudo usermod -aG docker jenkins", 
	"ssh-keygen -b 2048 -t rsa -f /tmp/id_rsa  -q -N ''",
	"sudo mkdir /var/lib/jenkins/.ssh",
	"sudo chmod 600 /var/lib/jenkins/.ssh",
	"sudo cp /tmp/id_rsa*	/var/lib/jenkins/.ssh",
	"sudo cat /var/lib/jenkins/.ssh/id_rsa.pub",
	"sudo yum install git -y",
	
	
    ]
  }

  tags = {
    Name = "Jenkins Don't delete please"
  }
}
