#! /bin/sh
cd /tmp && find . -xdev -mindepth 1 ! -name lost+found -delete
