advertise {
  http = "internal-ip:4646"
}

client {
  enabled = true

  # Switch this to volume mounts with multi-node-read-only so that we don't have to disable the sandbox.
  template {
    # Allow nomad to access arbitrary files on disk, instead of just in the task working directory.
    disable_file_sandbox = true
  }
}

bind_addr = "0.0.0.0"

plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
