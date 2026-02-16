#!/usr/bin/env bash

systemctl --user daemon-reload
systemctl --user enable vs-bkp.timer
systemctl --user start vs-bkp.timer
