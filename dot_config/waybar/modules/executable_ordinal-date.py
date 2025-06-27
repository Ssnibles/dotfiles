#!/usr/bin/env python3

import datetime
import json


def get_ordinal_suffix(n):
    if 10 <= n % 100 <= 20:
        return "th"
    else:
        return {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")


now = datetime.datetime.now()

# For the tooltip
day = now.day
ordinal_day = str(day) + get_ordinal_suffix(day)
tooltip_date = now.strftime(f"{ordinal_day} of %B %Y")

# For the main display (e.g., just time)
main_display_time = now.strftime("%H:%M")

output = {"text": main_display_time, "tooltip": tooltip_date}
print(json.dumps(output))
