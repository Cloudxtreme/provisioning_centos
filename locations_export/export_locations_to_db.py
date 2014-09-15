#!/usr/bin/env python
# vim: ai ts=4 sts=4 et sw=4 encoding=utf-8
import sys
import ureport_env, os
import csv_reader
from rapidsms.contrib.locations.nested.models import Location
from rapidsms.contrib.locations.models import LocationType, Point

if len(sys.argv) < 2:
    print("You must pass the 0-based index of the column holding the reporting level as an argument")
    exit(-1)

reporting_level = int(sys.argv[1])

sheet = csv_reader.get_locations_file_as_spreadsheet('locations.csv')

root_node_name = "country"  # Can be replaced by script argument
Location.objects.create(name=root_node_name)


def insert_location_types():
    for i in range(len(sheet.title_row)):
        location_type_name = sheet.title_row[i]
        if i == reporting_level:
            LocationType.objects.create(name=location_type_name, slug='district')
        else:
            LocationType.objects.create(name=location_type_name, slug=location_type_name)

location_point = Point.objects.create(latitude=0, longitude=0)


def add_location(loc_name, parent, type_id=None):
    Location.objects.create(name=loc_name, tree_parent=parent, type_id=type_id, point=location_point, code=loc_name)

insert_location_types()

while sheet.has_next_column():
    column = sheet.get_next_column()
    parent = None
    cells = column.get_unique_cells()

    type_id = None
    if column.index == reporting_level:
        type_id = 'district'

    if column.index == 0:
        parent = Location.objects.get(name=root_node_name)
        for cell in cells:
            add_location(cell.value, parent, type_id=type_id)
    else:
        for cell in cells:
            left = sheet.get_left_cell(cell)
            parent = Location.objects.get(name=left.value, level=column.index)
            add_location(cell.value, parent, type_id=type_id)

