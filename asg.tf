resource "aws_launch_template" "spot_instance" {
  name = "jenkins_agent"
  image_id = "ami-0c9fe0dec6325a30c"
  instance_type = "t1.micro" # Could replace by a spot pools of multiple types which help to optimize capacity
  network_interfaces {
    associate_public_ip_address = false
    # security_groups = [aws_security_group.app-sg.id]
  } 
}

resource "aws_autoscaling_group" "jenkins" {
  name                      = "jenkins_agent_controller"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  availability_zones        = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.spot_instance.id
        version = "$Latest"
      }
      override {
        instance_type     = "t2.micro"
        weighted_capacity = "2"
      }
    }
  }
}