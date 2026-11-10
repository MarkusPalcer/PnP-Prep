testsuite "Class pnpprep Unit-Tests" do 
    test "Basic" do 
        file "01-basic.tex"
    end

    test "Fields" do 
        file "02-fields.tex"
        user_assert "Name: Alice is displayed."
        user_assert "Age: 42 is displayed for Alice."
        user_assert "Name: Bob is displayed."
    end

    test "Child Environments" do 
        file "03-child-environment.tex"
        user_assert "Parent 1 is displayed."
        user_assert "Child 1 is displayed."
    end

    test "Nested Child Environments" do 
        file "04-nested-child-environment.tex"
    end

    test "Child State Isolation" do 
        file "05-child-state-isolation.tex"
        user_assert "The first parent is displayed as P1."
        user_assert "The first child is displayed as C1."
        user_assert "The second parent is displayed as P2."
        user_assert "The second child is displayed as C2."
    end

    test "Multiple Child Types" do 
        file "06-multiple-child-types.tex"
    end

    test "IfPresent and IfMissing" do 
        file "07-ifpresent-ifmissing.tex"
        user_assert "Object A is displayed."
        user_assert "Object A shows 'Present: VALUE'."
        user_assert "Object B is displayed."
        user_assert "Object B shows 'Missing: DEFAULT'."
        user_assert "\\ifpresent only renders content for existing fields."
        user_assert "\\ifmissing only renders content for missing fields."
        user_assert "Missing optional fields do not cause an error."
    end

    test "Child Environment Conflicts" do 
        file "08-child-environment-conflict-warning.tex"
        user_assert "Enemy: Goblin is displayed."
        user_assert "CHILD - Leather is displayed."
        user_assert "A child alias may shadow an existing environment."
        user_assert "The child alias is used inside the parent blueprint."
        user_assert "The original global environment is not used inside the parent blueprint."
        user_assert "A warning is emitted exactly once."
        user_assert "The warning says child environment 'ruestung' overwrites an existing environment."
    end

    test "Child Environment Name Conflicts With A Field" do 
        file "09-field-child-field-conflict-failure.tex"
        expect_compilation_failure
        requires_log "Package pnp-blueprint Error: Child environment 'ruestung' conflicts with an"
        requires_log "existing field name."
    end

    test "Child Environment Name Conflicts With A Command" do 
        file "10-child-command-conflict-failure.tex"
        expect_compilation_failure
        requires_log "Package pnp-blueprint Error: Child environment 'textbf' conflicts with an"
        requires_log "existing command."
    end

    test "Child Environment Does Not Leak" do 
        file "11-child-environment-no-leak.tex"
        user_assert "GLOBAL - Outside before is displayed."
        user_assert "CHILD - Inside is displayed."
        user_assert "GLOBAL - Outside after is displayed."
        user_assert "A child alias may shadow an existing environment inside the parent blueprint."
        user_assert "The original global environment remains available outside the parent blueprint."
        user_assert "The shadowing does not leak outside the parent blueprint instance."
        user_assert "A warning is emitted exactly once."
        user_assert "The warning says child environment 'ruestung' overwrites an existing environment."
    end

    test "Load From Library" do 
        file "12-load-from-library.tex"
    end

    test "Child Blocks" do 
        file "13-child-blocks.tex"
        user_assert "Parent 1 is displayed."
        user_assert "Parent 1 contains Child 1."
        user_assert "Parent 1 contains Child 2."
        user_assert "Parent 1 contains Child 3."
        user_assert "Parent 1 contains Child 4."
        user_assert "Parent 2 is displayed."
        user_assert "Parent 2 contains Child 1."
        user_assert "Parent 2 contains Child 2."
        user_assert "Parent 2 contains Child 3."
        user_assert "Parent 2 contains Child 4."
    end

end

