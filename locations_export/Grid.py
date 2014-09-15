class Spreadsheet:

    def __init__(self):
        self.rows = []

    def add_row(self, row):
        self.rows.append(row)
        row.index = len(self.rows) - 1

    def left(self):
        pass


class Row:
    def __init__(self):
        self.cells = []
        self.index = 0

    def append(self, cell):
        self.cells.append(cell)
        cell.x = self.index
        cell.y = len(self.cells) - 1

    def get_parent_cell(self, cell):
        return self.cells[cell.y - 1]


class Cell:
    def __init__(self, value):
        self.value = value
        self.x = 0
        self.y = 0



sheet = Spreadsheet()
row = Row()
sheet.add_row(row)
row.append(Cell(1))
row.append(Cell(2))
row.append(Cell(3))

row = Row()
sheet.add_row(row)
row.append(Cell(4))
row.append(Cell(5))
row.append(Cell(6))

print(sheet.rows[1].cells[2].value)
cell = sheet.rows[0].cells[2]
print(sheet.rows[0].get_parent_cell(cell).value)

