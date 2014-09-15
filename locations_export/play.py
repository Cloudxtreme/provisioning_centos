import csv
from Spreadsheet import Spreadsheet, Row, Cell


def get_keys(row):
    return list(row.keys())


def extract_unique_entries(entries):
    return list(set(entries))


def read_csv(file_name):
    file = open(file_name, 'rU')
    reader = csv.DictReader(file)

    rows = []
    for row in reader:
        rows.append(row)

    column_names = get_keys(rows[0])

    return rows, column_names


def get_entries_in_column(column, rows):
    entries = []
    for row in rows:
        entries.append(row[column])

    return entries


def make_spreadsheet(rows):
    sheet = Spreadsheet()
    for row in rows:
        sheet_row = Row()
        sheet.add_row(sheet_row)
        for entry in row:
            sheet_row.append(Cell(entry))
    return sheet


def get_rows_as_list(rows, ordered_columns):
    ordered_rows = []
    for row in rows:
        ordered_row = []
        for column in ordered_columns:
            ordered_row.append(row[column])
        ordered_rows.append(ordered_row)
    return ordered_rows

rows, columns = read_csv('sudan_locations.csv')
list_of_rows = get_rows_as_list(rows, columns)

sheet = make_spreadsheet(list_of_rows)

while sheet.has_next_column():
    column = sheet.get_next_column()
    cells = column.get_unique_cells()
    print(len(cells))