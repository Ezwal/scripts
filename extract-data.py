#!/usr/bin/env python3
import sys

low_bytes = []
bytes_array = []

with open(sys.argv[1], 'rb') as gunm:
    data = gunm.read()
    for byte in data:
        c = byte & 1
        low_bytes.append(c)
        # print(c)

for i in range(0, len(low_bytes) // 8, 8):
    single_byte = 0
    for shift in range(0, 8):
        single_byte += low_bytes[i+shift] << shift

    bytes_array.append(single_byte)

for el in bytes_array:
    print(chr(el))
