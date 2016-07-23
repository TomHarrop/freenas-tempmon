#!/usr/bin/env python2

import requests
import argparse
import os

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
    time = weather.json()['current_observation']['local_epoch']
    sensor = weather.json()['current_observation']['display_location']['full']
    serial = weather.json()['current_observation']['station_id']
    temperature = weather.json()['current_observation']['temp_c']
    weather_line = [time, sensor, serial, temperature]
    print weather_line

    # # print output to data file
    # weather_file = 'dat/weather.csv'
    # if not os.path.isdir('dat'):
    #     os.mkdir('dat')
    # if not os.path.exists(weather_file):
    #     open(weather_file, 'w').close()

    # with open(weather_file, 'a') as weather_append:
    #     weather_append.write(','.join([time, sensor, serial, temperature]) +
    #                        '\n')

if __name__ == "__main__":
    main()
