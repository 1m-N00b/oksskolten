package main

import rego.v1

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

h(depth, text) := {"type": "heading", "depth": depth, "children": [{"type": "text", "value": text}]}

named_doc(filename, children) := {"type": "root", "children": children, "metadata": {"filename": filename, "all_filenames": []}}

named_doc_with_all(filename, all, children) := {"type": "root", "children": children, "metadata": {"filename": filename, "all_filenames": all}}

# ---------------------------------------------------------------------------
# Rule 6: Filename format
# ---------------------------------------------------------------------------

test_filename_valid_en if {
	count(deny) == 0 with input as named_doc("80_feature_clip.md", [h(1, "Oksskolten Spec — Clip")])
}

test_filename_valid_ja if {
	count(deny) == 0 with input as named_doc_with_all(
		"80_feature_clip.ja.md",
		["80_feature_clip.md", "80_feature_clip.ja.md"],
		[h(1, "Oksskolten 実装仕様書 — クリップ")],
	)
}

test_filename_valid_core if {
	count(deny) == 0 with input as named_doc("10_schema.md", [h(1, "Oksskolten Spec — Schema")])
}

test_filename_invalid_no_prefix if {
	"Filename must match {NN}_{snake_case}.md or .ja.md, got: 'overview.md'" in deny with input as named_doc("overview.md", [h(1, "Oksskolten Spec — Overview")])
}

test_filename_invalid_uppercase if {
	"Filename must match {NN}_{snake_case}.md or .ja.md, got: '80_Feature_Clip.md'" in deny with input as named_doc("80_Feature_Clip.md", [h(1, "Oksskolten Spec — Clip")])
}

test_filename_invalid_hyphen if {
	"Filename must match {NN}_{snake_case}.md or .ja.md, got: '80_feature-clip.md'" in deny with input as named_doc("80_feature-clip.md", [h(1, "Oksskolten Spec — Clip")])
}

# ---------------------------------------------------------------------------
# Rule 7: .ja.md must have corresponding .md
# ---------------------------------------------------------------------------

test_ja_with_en_pair if {
	count(deny) == 0 with input as named_doc_with_all(
		"80_feature_clip.ja.md",
		["80_feature_clip.md", "80_feature_clip.ja.md"],
		[h(1, "Oksskolten 実装仕様書 — クリップ")],
	)
}

test_ja_without_en_pair if {
	"Japanese spec '99_orphan.ja.md' has no corresponding English version '99_orphan.md'" in deny with input as named_doc_with_all(
		"99_orphan.ja.md",
		["99_orphan.ja.md"],
		[h(1, "Oksskolten 実装仕様書 — Orphan")],
	)
}

test_en_only_is_ok if {
	count(deny) == 0 with input as named_doc_with_all(
		"84_feature_keyboard_navigation.md",
		["84_feature_keyboard_navigation.md"],
		[h(1, "Oksskolten Spec — Keyboard Navigation")],
	)
}

# ---------------------------------------------------------------------------
# Rule 8: Number prefix category
# ---------------------------------------------------------------------------

test_8x_feature_valid if {
	count(deny) == 0 with input as named_doc("81_feature_images.md", [h(1, "Oksskolten Spec — Images")])
}

test_9x_perf_valid if {
	count(deny) == 0 with input as named_doc("90_perf_retry_backoff.md", [h(1, "Oksskolten Spec — Retry Backoff")])
}

test_8x_without_feature_infix if {
	"Filename with 8x prefix must contain '_feature_', got: '80_clip.md'" in deny with input as named_doc("80_clip.md", [h(1, "Oksskolten Spec — Clip")])
}

test_9x_without_perf_infix if {
	"Filename with 9x prefix must contain '_perf_', got: '90_retry_backoff.md'" in deny with input as named_doc("90_retry_backoff.md", [h(1, "Oksskolten Spec — Retry Backoff")])
}

test_feature_infix_wrong_prefix if {
	"Feature spec must use 8x prefix, got: '50_feature_something.md'" in deny with input as named_doc("50_feature_something.md", [h(1, "Oksskolten Spec — Something")])
}

test_perf_infix_wrong_prefix if {
	"Perf spec must use 9x prefix, got: '50_perf_something.md'" in deny with input as named_doc("50_perf_something.md", [h(1, "Oksskolten Spec — Something")])
}

test_core_spec_no_category_constraint if {
	count(deny) == 0 with input as named_doc("20_api.md", [h(1, "Oksskolten Spec — API")])
}
