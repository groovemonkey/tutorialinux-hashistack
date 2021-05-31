job "etherpad" {
  type        = "service"
  datacenters = ["dc1"]

  group "redis" {
    count = 1

    network {
      port "redis" {
        to = 6379
      }
    }

    service {
      name = "etherpad-redis"
      port = "redis"
      check {
        name     = "alive"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    restart {
      # The number of attempts to run the job within the specified interval.
      attempts = 10
      interval = "3m"

      # The "delay" parameter specifies the duration to wait before restarting
      # a task after it has failed.
      delay = "15s"

      # The "mode" parameter controls what happens when a task has restarted
      # "attempts" times within the interval. "delay" mode delays the next
      # restart until the next interval. "fail" mode does not restart the task
      # if "attempts" has been hit within the interval.
      mode = "delay"
    }

    # The "ephemeral_disk" stanza instructs Nomad to utilize an ephemeral disk
    # instead of a hard disk requirement. Clients using this stanza should
    # not specify disk requirements in the resources stanza of the task. All
    # tasks in this group will share the same ephemeral disk.
    #
    # For more information and rediss on the "ephemeral_disk" stanza, please
    # see the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/ephemeral_disk.html
    #
    ephemeral_disk {
      # When sticky is true and the task group is updated, the scheduler
      # will prefer to place the updated allocation on the same node and
      # will migrate the data. This is useful for tasks that store data
      # that should persist across allocation updates.
      # sticky = true
      # 
      # Setting migrate to true results in the allocation directory of a
      # sticky allocation directory to be migrated.
      migrate = true

      # The "size" parameter specifies the size in MB of shared ephemeral disk
      # between tasks in the group.
      size = 200
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:5.0"
        ports = ["redis"]
      }

      resources {
        cpu    = 200
        memory = 100
      }
    }
  }

  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "web" {
    # Specify the number of these tasks we want.
    count = 2

    network {
      # This requests a dynamic port, mapped to a static port on the container
      port "http" {
        to = 9001
      }
    }

    # The service block tells Nomad how to register this service
    # with Consul for service discovery and monitoring.
    service {
      name = "etherpad"

      # give this service a Consul tag so that traefik knows about it
      tags = [
        "traefik.enable=true",
        "traefik.connect=true",
        "traefik.http.routers.etherpad.rule=Host(`etherpad.tutorialinux.com`)"
      ]

      # This tells Consul to monitor the service on the port
      # labelled "http". Since Nomad allocates high dynamic port
      # numbers, we use labels to refer to them.
      port = "http"

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    # Create an individual task (unit of work). This particular
    # task utilizes a Docker container to front a web application.
    task "etherpad" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      driver = "docker"

      # Configuration is specific to each driver.
      config {
        image = "etherpad/etherpad"
        ports = ["http"]
      }

      # Config template (uses consul-template, updates automagically when things change)
      template {
        source      = "/etc/nomad.d/etherpad-settings.json.tpl"
        destination = "/opt/etherpad-lite/settings.json"
        change_mode = "restart"
      }

      # Specify the maximum resources required to run the task,
      # include CPU and memory.
      resources {
        cpu    = 300 # MHz
        memory = 128 # MB
      }
    }
  }
}
