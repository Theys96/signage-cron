# signage-cron

A minimal digital signage script that cycles through a user-defined URL schedule in full-screen Chromium kiosk mode.

This implementation uses cron to check every minute whether the correct URL is being displayed. 
If not, Chromium is killed (if necessary) and (re)started based on the scheduled defined in a file.
This results in a relatively robust signage program that will work indefinitely.

Depends on:
- `bash`  
- `chromium-browser`  
- `cron` (`crontab`)  
- `procps` (`pgrep`, `pkill`)

## How to use

The schedule is defined in `signage_cron_schedule.txt`, e.g.:

```
https://www.google.com/ 2
https://old.reddit.com/ 1
```

This shows one URL for two minutes, then another for 1 minute, then repeats.

It is assumed that this project is installed in `$HOME/signage-cron/`.

Make sure to add this to the user crontab. 

```
* * * * * DISPLAY=:0 $HOME/signage-cron/signage_cron.sh >> $HOME/signage-cron/signage_cron.log 2>&1
```

I think `DISPLAY=:0` should _usually_ work here.

## Future improvements

Many. It would be nice not to see the browser closing and opening again.
It may also be worth it to experiment with other, more lightweight browsers.
Chromium can possibly be used with `--disable-gpu` as a performance improvement.
