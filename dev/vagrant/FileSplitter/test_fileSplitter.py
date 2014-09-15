import os
from unittest import TestCase
import unittest
from FileSplitter import FileSplitter


class TestFileSplitter(TestCase):

    def setUp(self):
        self.valid_phrases = ("public", "admin")
        self.django_po_file = "%s/django.po" % os.path.dirname(__file__)
        self.file_splitter = FileSplitter(self.django_po_file, self.valid_phrases)

    def test_that_we_can_get_the_first_line(self):
        first_line = self.file_splitter.get_line(0)
        self.assertEqual(first_line, "#: first public line\n")

    def test_that_first_line_is_a_comment(self):
        first_line = self.file_splitter.get_line(0)
        self.assertTrue(self.file_splitter.is_comment(first_line))

    def test_that_the_third_line_is_not_a_comment(self):
        third_line = self.file_splitter.get_line(2)
        self.assertFalse(self.file_splitter.is_comment(third_line))

    def test_that_comment_is_invalid(self):
        comment = "invalid comment"
        self.assertFalse(self.file_splitter.is_comment_valid(comment))

    def test_that_the_comment_is_valid(self):
        comment = "valid comment which contains the word public"
        self.assertTrue(self.file_splitter.is_comment_valid(comment))

    def test_that_we_can_pick_lines_below_a_given_comment(self):
        lines = self.file_splitter.get_lines_below_comment(0)
        self.assertEqual(len(lines), 5)

    def test_that_we_can_pick_lines_below_a_comment_that_contains_admin(self):
        pass

    # def test_that_the_file_contains_public_translations(self):
    #     lines = self.file_splitter.get_lines_below_comment_containing("public")
    #     self.assertEqual(len(lines), )

if __name__ == '__main__':
    unittest.main()