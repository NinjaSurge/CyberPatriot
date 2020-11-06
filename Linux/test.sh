#!/bin/bash

for i in {1..4}; do
  touch this$i.mp4
  touch this$i.jpg
done

for i in {1..4}; do
  sudo useradd name$i
done
