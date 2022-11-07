#!/usr/bin/env python
# -*- coding: utf-8 -*-

from prometheus_client import start_http_server, Gauge
import json
import os
import signal
import subprocess
import threading
import time
import schedule

g = Gauge('kubent_deprecated_objects', 'Objects which have been detected by kubent as being pinned to deprecated APIs', ['name', 'namespace', 'kind', 'apiversion', 'ruleset', 'replacewith', 'since'])

def run_continuously(interval=1):
    cease_continuous_run = threading.Event()

    class ScheduleThread(threading.Thread):
        @classmethod
        def run(cls):
            while not cease_continuous_run.is_set():
                schedule.run_pending()
                time.sleep(interval)

    continuous_thread = ScheduleThread()
    continuous_thread.start()
    return cease_continuous_run

def update_metrics():
    result = subprocess.run(['/kubent', '-o', 'json'], capture_output=True, text=True)
    try:
        result.check_returncode()
    except subprocess.CalledProcessError as e:
        print(f"{e} raised")
        return

    data = json.loads(result.stdout)

    g.clear()

    for i in data:
        tmp = {}
        for k, v in i.items():
            tmp[k.lower()] = v
        g.labels(**tmp).set(1)
    print("Successfully ran and updated metrics.")

class GracefulKiller:
    kill_now = False
    def __init__(self):
        signal.signal(signal.SIGINT, self.exit_gracefully)
        signal.signal(signal.SIGTERM, self.exit_gracefully)

    def exit_gracefully(self, *args):
        self.kill_now = True

if __name__ == '__main__':
    schedule.every(os.environ.get('KUBENT_EXPORTER_FREQUENCY_MINUTES', 5)).minutes.do(update_metrics)
    
    schedule.run_all()
    stop_run_continuously = run_continuously()

    killer = GracefulKiller()
    start_http_server(os.environ.get('KUBENT_EXPORTER_PORT', 8000))
    while not killer.kill_now:
        time.sleep(1)

    stop_run_continuously.set()
