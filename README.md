# DNS Latency Test

![License](https://img.shields.io/badge/License-MIT-blue.svg)

A simple Bash script to measure the latency and response time of multiple DNS servers.

## Features

- Measures ping latency to DNS servers
- Checks DNS query response times
- Supports parallel execution for faster results
- Sorts results based on response time
- Highlights fastest and slowest DNS servers

## Prerequisites

- `bash` shell
- `ping` command
- `dig` command (available in `dnsutils` package on Debian-based systems)

## Installation

Clone the repository:

```sh
 git clone https://github.com/BaseMax/DNS-Latency-Test.git
 cd DNS-Latency-Test
```

## Usage

Run the script:

```sh
 ./dns-latency-test.sh
```

## Configuration

- Edit `dns-servers.txt` to add or remove DNS servers.
- Modify the `PING_TIMEOUT` variable in the script to change the timeout duration.

## Example Output

```
Testing DNS latency (Max: 10s)...
------------------------------------------------------
DNS Server          Ping (ms)   Query Time (ms)
------------------------------------------------------
8.8.8.8            12 ms       30 ms
1.1.1.1            8 ms        15 ms
9.9.9.9            20 ms       50 ms
------------------------------------------------------
🚀 Fastest DNS: 1.1.1.1 (15 ms)
🐢 Slowest DNS: 9.9.9.9 (50 ms)
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

The idea for this project is originally inspired by [DNS-Test-Speed](https://github.com/netamirbabaei/DNS-Test-Speed).

## Author

Copyright (c) 2025 Max Base
