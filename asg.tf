resource "aws_launch_template" "spot_instance" {
  name = "jenkins_agent"
  image_id = "ami-0c9fe0dec6325a30c"
  key_name = "jo-fox-test"
  instance_type = "t1.micro" # Could replace by a spot pools of multiple types which help to optimize capacity
  user_data = base64encode(file("user_data.sh"))
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.asg.id]
  } 
}

resource "aws_autoscaling_group" "jenkins" {
  name                      = "jenkins_agent_controller"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
      spot_max_price                           = 0.0044
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