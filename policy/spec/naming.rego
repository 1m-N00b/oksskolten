package main

import rego.v1

filename := object.get(input, ["metadata", "filename"], "")

# Rule 6: Filename must match {NN}_{snake_case}.md or {NN}_{snake_case}.ja.md
deny contains msg if {
	filename != ""
	not regex.match(`^\d{2}_[a-z][a-z0-9_]*\.md$`, filename)
	not regex.match(`^\d{2}_[a-z][a-z0-9_]*\.ja\.md$`, filename)
	msg := sprintf("Filename must match {NN}_{snake_case}.md or .ja.md, got: '%s'", [filename])
}

# Rule 7: .ja.md must have a corresponding .md (English version required)
deny contains msg if {
	filename != ""
	endswith(filename, ".ja.md")
	all_filenames := object.get(input, ["metadata", "all_filenames"], [])
	en_name := replace(filename, ".ja.md", ".md")
	not en_name in {f | some f in all_filenames}
	msg := sprintf("Japanese spec '%s' has no corresponding English version '%s'", [filename, en_name])
}

# Rule 8: Number prefix category must match content type
# 0x = overview/architecture, 1x-5x = core specs, 8x = feature, 9x = perf
valid_prefix_categories := {
	"8": "_feature_",
	"9": "_perf_",
}

deny contains msg if {
	filename != ""
	not endswith(filename, ".ja.md")
	prefix_digit := substring(filename, 0, 1)
	expected_infix := valid_prefix_categories[prefix_digit]
	not contains(filename, expected_infix)
	msg := sprintf("Filename with %sx prefix must contain '%s', got: '%s'", [prefix_digit, expected_infix, filename])
}

deny contains msg if {
	filename != ""
	not endswith(filename, ".ja.md")
	contains(filename, "_feature_")
	not startswith(filename, "8")
	msg := sprintf("Feature spec must use 8x prefix, got: '%s'", [filename])
}

deny contains msg if {
	filename != ""
	not endswith(filename, ".ja.md")
	contains(filename, "_perf_")
	not startswith(filename, "9")
	msg := sprintf("Perf spec must use 9x prefix, got: '%s'", [filename])
}
