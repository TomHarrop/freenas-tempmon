#!/usr/bin/env python2

import requests
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("api_key", help="Wunderground API key")
    args = parser.parse_args()
    print args.api_key
