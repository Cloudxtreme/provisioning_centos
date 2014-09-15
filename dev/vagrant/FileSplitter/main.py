import sys
from FileSplitter import FileSplitter

if len(sys.argv) < 2:
    print "django.po file is missing"
    exit()

django_po_file = sys.argv[1]
valid_phrases = ("admin", "noneadmin")

ACCEPTED_PAGES = ("ureport/home.html",
                  "ureport_layout.html",
                  "ureport/partials/viz/",
                  "ureport/partials/tag_cloud/",
                  "ureport/about.html",
                  "ureport/how_to_join.html",
                  "ureport/national_pulse.html",
                  "ureport/poll_summary.html")

splitter = FileSplitter(django_po_file, ACCEPTED_PAGES)
splitter.split()


