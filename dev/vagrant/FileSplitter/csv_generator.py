import os
import sys

if len(sys.argv) < 2:
    print "The django po file is missing"
    exit()

django_po_file = sys.argv[1]
clean_django_po_file = "%s/other.csv" % os.path.dirname(django_po_file)

handle = open(django_po_file, "r")
clean_handle = open(clean_django_po_file, "w")

start_grab = False
msgid = []

for line in handle.readlines():
    if line[0:5] == "msgid":
        start_grab = True

    if line[0:6] == "msgstr":
        start_grab = False
        msgid_str = "".join(msgid)
        clean_handle.write(msgid_str[6:]+',"" \n')
        msgid = []

    if start_grab:
        # remove the new line character at the end
        msgid.append(line[0:-1])




