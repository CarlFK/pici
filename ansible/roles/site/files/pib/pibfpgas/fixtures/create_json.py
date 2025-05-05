#!/usr/bin/env python3

import csv
import json
import requests
from io import StringIO

def fetch_csv_data(url):
    response = requests.get(url)
    response.raise_for_status()  # Raise an error for bad responses
    return response.text

def convert_csv_to_json(csv_data):
    reader = csv.DictReader(StringIO(csv_data))
    site_data = {"k207": [], "ps1": []}

    for idx, row in enumerate(reader, start=1):
        try:
            # Skip rows with empty essential fields
            if not row["Port"].strip() or not row["Uplink MAC"].strip() or not row["Serial No"].strip():
                print(f"Skipping empty row {idx}")
                continue

            site = row.get("Site", "").strip().lower()
            if site not in site_data:
                continue

            entry = {
                "model": "pibfpgas.pi",
                "pk": idx,
                "fields": {
                    "cable_color": row.get("Cable Color", "").strip(),
                    "location": row.get("Location", "").strip(),
                    "mac": row.get("Uplink MAC", "").strip(),
                    "model": row.get("RPi Model", "").strip(),
                    "port": int(row["Port"]) if row["Port"].isdigit() else None,
                    "serial_no": row.get("Serial No", "").strip()
                }
            }
            site_data[site].append(entry)
        except (KeyError, ValueError) as e:
            print(f"Skipping row {idx} due to error: {e}")

    return site_data

def main():
    url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vT1MjjK6cAl3wShj8LWfeaXNPjynvm4OP6fI3JV8IteAAxmOPu6TBC8Yl6w1eV5kezQ-XZXIbnSWS4r/pub?gid=0&single=true&output=csv"
    csv_data = fetch_csv_data(url)
    site_json_results = convert_csv_to_json(csv_data)

    for site, data in site_json_results.items():
        filename = f"{site.replace('.', '_')}.fpgas.online.json"
        with open(filename, "w") as json_file:
            json.dump(data, json_file, indent=3, sort_keys=True)
        print(f"JSON data has been written to {filename}")

if __name__ == "__main__":
    main()
