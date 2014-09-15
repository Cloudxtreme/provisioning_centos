import os


class FileSplitter():

    def __init__(self, source_file, valid_phrases):
        self.handle = open(source_file, "r")
        self.lines = self.handle.readlines()
        self.valid_phrases = valid_phrases
        self.public_file_handle = self.get_file_handle("public.po")
        self.other_file_handle = self.get_file_handle("other.po")
        self.split_line_pointer = 0

    def get_line(self, index):
        return self.lines[index]

    def is_comment(self, line):
        return line[0:3] == "#: "

    def is_comment_valid(self, comment):
        return filter(comment.__contains__, self.valid_phrases)

    def get_lines_below_comment(self, start_index):
        output = []
        none_comment_found = False

        for index in range(start_index, len(self.lines)):
            line = self.get_line(index)
            # print line
            # exit()
            if not self.is_comment(line):
                none_comment_found = True

            if none_comment_found and self.is_comment(line):
                break
            else:
                self.split_line_pointer = index
                output.append(line)

        return output

    def split(self):
        for index,line in enumerate(self.lines):

            if index < self.split_line_pointer:
                continue

            self.split_line_pointer = index

            if self.is_comment(line) and self.is_comment_valid(line):
                lines = self.get_lines_below_comment(index)
                self.public_file_handle.write("".join(lines))
                index = self.split_line_pointer
            else:
                self.other_file_handle.write(line)

    def get_file_handle(self, filename):
        absolute_filename = "%s/%s" % (os.path.dirname(__file__), filename)
        return open(absolute_filename, "w")