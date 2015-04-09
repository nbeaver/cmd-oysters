all: validate_json test_python_script lint_database pseudo_schema sort_database check_temp_json
.PHONY : validate_json test_python_script lint_database pseudo_schema sort_database check_temp_json

validate_json : command-database.json Makefile
	json_verify < command-database.json

test_python_script : find-command.py Makefile
	python find-command.py --substring 'ping -i' > /dev/null
	python find-command.py --commands ping espeak sed > /dev/null
	python find-command.py --tokens '|' sed localhost ping > /dev/null
	python find-command.py --description 'audible voice' > /dev/null
	python find-command.py --substring 'ping -i' --commands ping espeak sed --tokens '|' sed localhost ping --description 'audible voice' > /dev/null

lint_database : command-database.json lint-database.py Makefile
	python lint-database.py command-database.json

sort_database : command-database.json sort-json.py Makefile
	python sort-json.py
	diff --ignore-all-space --ignore-blank-lines command-database.json sorted.json

pseudo_schema : pseudo-schema check-pseudoschema.py Makefile
	tree --noreport pseudo-schema/ > pseudo-schema-tree.txt
	python check-pseudoschema.py command-database.json

check_full_template : full-command-template.json pseudoschema check-full-template.py check-pseudoschema.py
	python check-pseudoschema.py full-command-template.json
	python check-full-template.py full-command-template.json pseudo-schema/

check_temp_json : temp.json lint-database.py
	json_verify < temp.json
	python lint-database.py temp.json
	python check-pseudoschema.py temp.json
