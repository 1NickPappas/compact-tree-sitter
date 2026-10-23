package tree_sitter_compact_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_compact "github.com/1NickPappas/compact-tree-sitter/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_compact.Language())
	if language == nil {
		t.Errorf("Error loading Compact grammar")
	}
}
