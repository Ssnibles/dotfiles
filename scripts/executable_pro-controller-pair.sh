#!/usr/bin/expect -f

# Set timeout for commands
set timeout 60

# MAC address of your Nintendo Switch Pro Controller
set controller_mac "80:D2:E5:9A:4D:21"

puts "Attempting to connect Nintendo Switch Pro Controller (MAC: $controller_mac)..."

# Start bluetoothctl
spawn bluetoothctl

# Wait for Agent registration (bluetoothctl ready)
expect {
    "Agent registered" { }
    timeout { puts "Error: bluetoothctl did not start properly."; exit 1 }
}

# Remove device if already paired
send -- "remove $controller_mac\r"
expect {
    "Device has been removed" {}
    "not available" {}
    timeout {}
}

# Start scanning
send -- "scan on\r"
# Wait for device to appear in scan results
expect {
    -re "Device $controller_mac" {
        puts "Controller discovered! Proceeding with pairing."
    }
    timeout {
        puts "Error: Controller not discovered within timeout ($timeout seconds). Ensure it's in pairing mode."
        send -- "exit\r"
        expect eof
        exit 1
    }
}

# Stop scanning
send -- "scan off\r"
expect {
    "Discovery stopped" {}
    timeout {}
}

# Pair the device
send -- "pair $controller_mac\r"
expect {
    "Pairing successful" { puts "Pairing successful." }
    "Failed to pair" { puts "Pairing failed."; send -- "exit\r"; expect eof; exit 1 }
    "AlreadyExists" { puts "Already paired." }
    timeout { puts "Pairing timed out."; send -- "exit\r"; expect eof; exit 1 }
}

# Connect the device
send -- "connect $controller_mac\r"
expect {
    "Connection successful" { puts "Connection successful!" }
    "Failed to connect" { puts "Failed to connect to controller."; send -- "exit\r"; expect eof; exit 1 }
    timeout { puts "Connection attempt timed out."; send -- "exit\r"; expect eof; exit 1 }
}

# Trust the device
send -- "trust $controller_mac\r"
expect {
    "trust succeeded" { puts "Device trusted." }
    timeout {}
}

# Exit bluetoothctl
send -- "exit\r"
expect eof

puts "Script finished. Check controller status."
