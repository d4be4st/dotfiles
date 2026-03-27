; extends
; @rspec_example
(
 (call method: (identifier) @method_name )
 (#any-of? @method_name "it" "describe" "context")
 (call method: (identifier) block: (do_block body: (body_statement) @rspec_example.inner) )
) @rspec_example.outer

; @array
(array (_) @array.inner ) @array.outer

; @hash
(hash (_) @hash.inner) @hash.outer

