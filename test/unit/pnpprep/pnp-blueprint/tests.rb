    fixture "Basic" do
        file "01-basic.tex"
        test "Compiles successfully" do
        end
    end

    fixture "Fields" do
        file "02-fields.tex"
        manual_test "Name: Alice is displayed."
        manual_test "Age: 42 is displayed for Alice."
        manual_test "Name: Bob is displayed."
    end

    fixture "Child Environments" do
        file "03-child-environment.tex"
        manual_test "Parent 1 is displayed."
        manual_test "Child 1 is displayed."
    end

    fixture "Nested Child Environments" do
        file "04-nested-child-environment.tex"
        test "Compiles successfully" do
        end
    end

    fixture "Child State Isolation" do
        file "05-child-state-isolation.tex"
        manual_test "The first parent is displayed as P1."
        manual_test "The first child is displayed as C1."
        manual_test "The second parent is displayed as P2."
        manual_test "The second child is displayed as C2."
    end

    fixture "Unit: Multiple Child Types" do
        file "06-multiple-child-types.tex"
        test "Compiles successfully" do
        end
    end

    fixture "IfPresent and IfMissing" do
        file "07-ifpresent-ifmissing.tex"
        manual_test "Object A is displayed."
        manual_test "Object A shows 'Present: VALUE'."
        manual_test "Object B is displayed."
        manual_test "Object B shows 'Missing: DEFAULT'."
        manual_test "\\ifpresent only renders content for existing fields."
        manual_test "\\ifmissing only renders content for missing fields."
        manual_test "Missing optional fields do not cause an error."
    end

    fixture "Child Environment Conflicts" do
        file "08-child-environment-conflict-warning.tex"
        manual_test "Enemy: Goblin is displayed."
        manual_test "CHILD - Leather is displayed."
        manual_test "A child alias may shadow an existing environment."
        manual_test "The child alias is used inside the parent blueprint."
        manual_test "The original global environment is not used inside the parent blueprint."
        manual_test "A warning is emitted exactly once."
        manual_test "The warning says child environment 'ruestung' overwrites an existing environment."
    end

    fixture "Child Environment Name Conflicts With A Field" do
        file "09-field-child-field-conflict-failure.tex"
        expect_compilation_failure
        requires_log "Package pnp-blueprint Error: Child environment 'ruestung' conflicts with an"
        requires_log "existing field name."
    end

    fixture "Child Environment Name Conflicts With A Command" do
        file "10-child-command-conflict-failure.tex"
        expect_compilation_failure
        requires_log "Package pnp-blueprint Error: Child environment 'textbf' conflicts with an"
        requires_log "existing command."
    end

    fixture "Child Environment Does Not Leak" do
        file "11-child-environment-no-leak.tex"
        manual_test "GLOBAL - Outside before is displayed."
        manual_test "CHILD - Inside is displayed."
        manual_test "GLOBAL - Outside after is displayed."
        manual_test "A child alias may shadow an existing environment inside the parent blueprint."
        manual_test "The original global environment remains available outside the parent blueprint."
        manual_test "The shadowing does not leak outside the parent blueprint instance."
        manual_test "A warning is emitted exactly once."
        manual_test "The warning says child environment 'ruestung' overwrites an existing environment."
    end

    fixture "Load From Library" do
        file "12-load-from-library.tex"
        test "Compiles successfully" do
        end
    end

    fixture "Child Blocks" do
        file "13-child-blocks.tex"
        manual_test "Parent 1 is displayed."
        manual_test "Parent 1 contains Child 1."
        manual_test "Parent 1 contains Child 2."
        manual_test "Parent 1 contains Child 3."
        manual_test "Parent 1 contains Child 4."
        manual_test "Parent 2 is displayed."
        manual_test "Parent 2 contains Child 1."
        manual_test "Parent 2 contains Child 2."
        manual_test "Parent 2 contains Child 3."
        manual_test "Parent 2 contains Child 4."
    end

