#!/bin/bash

$1

for i in {1..4}; do
  touch this$i.mp4
  touch this$i.jpg
done
