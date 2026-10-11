"""Builds assets/data/cities.json from GeoNames (https://www.geonames.org, CC BY 4.0).

Usage: python tool/build_cities.py <dir with cities15000.txt and countryInfo.txt>
Both files: https://download.geonames.org/export/dump/
"""
import csv
import json
import sys
from pathlib import Path

MIN_POPULATION = 50_000

src = Path(sys.argv[1])
countries = {}
for line in (src / 'countryInfo.txt').read_text(encoding='utf-8').splitlines():
    if line and not line.startswith('#'):
        cols = line.split('\t')
        countries[cols[0]] = cols[4]

best = {}
with open(src / 'cities15000.txt', encoding='utf-8') as f:
    for r in csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE):
        name, ascii_name, cc, pop = r[1], r[2], r[8], int(r[14] or 0)
        if cc not in countries or (pop < MIN_POPULATION and r[7] != 'PPLC'):
            continue
        key = (name, cc)
        if key not in best or pop > best[key][0]:
            best[key] = (pop, [name, cc, round(float(r[4]), 4),
                               round(float(r[5]), 4)]
                         + ([ascii_name] if ascii_name != name else []))

cities = sorted((v[1] for v in best.values()),
                key=lambda c: (countries[c[1]], c[0]))
used = {c[1] for c in cities}
out = {'countries': {cc: n for cc, n in sorted(countries.items()) if cc in used},
       'cities': cities}
dest = Path(__file__).resolve().parent.parent / 'assets' / 'data' / 'cities.json'
dest.write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')),
                encoding='utf-8')
print(f'{len(cities)} cities, {len(used)} countries -> {dest}')
