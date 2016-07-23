#!/usr/bin/env python2

import requests
import argparse

def main():
    # get api key from CLI
    parser = argparse.ArgumentParser()
    parser.add_argument("api_key", help="Wunderground API key")
    args = parser.parse_args()
    print args.api_key

    # download weather info from wunderground
    weather_url = ('http://api.wunderground.com/api/' + args.api_key +
                   '/conditions/q/zmw:00000.17.07643.json')
    print weather_url
    weather = requests.get(weather_url)

    # format output
    print weather.json()['current_observation']['local_epoch']
    print weather.json()['current_observation']['display_location']['full']
    print weather.json()['current_observation']['station_id']
    print weather.json()['current_observation']['temp_c']

if __name__ == "__main__":
    main()
