testsuite "Class pnpprep Unit-Tests" do 
    test "Basic" do 
        file "01-basic.tex"
    end

    test "Fields" do 
        file "02-fields.tex"
    end

    test "Child Environments" do 
        file "03-child-environment.tex"
    end

    test "Nested Child Environments" do 
        file "04-nested-child-environment.tex"
    end

    test "Child State Isolation" do 
        file "05-child-state-isolation.tex"
    end

    test "Multiple Child Types" do 
        file "06-multiple-child-types.tex"
    end

    test "IfPresent and IfMissing" do 
        file "07-ifpresent-ifmissing.tex"
    end

    test "Child Environment Conflicts" do 
        file "08-child-environment-conflict-warning.tex"
    end

    test "Child Environment Name Conflicts With A Field" do 
        file "09-field-child-field-conflict-failure.tex"
        expect_failure
        requires_log "Package pnp-blueprint Error: Child environment 'ruestung' conflicts with an"
        requires_log "existing field name."
    end

    test "Child Environment Name Conflicts With A Command" do 
        file "10-child-command-conflict-failure.tex"
        expect_failure
        requires_log "Package pnp-blueprint Error: Child environment 'textbf' conflicts with an"
        requires_log "existing command."
    end

    test "Child Environment Does Not Leak" do 
        file "11-child-environment-no-leak.tex"
    end

    test "Load From Library" do 
        file "12-load-from-library.tex"
    end

    test "Child Blocks" do 
        file "13-child-blocks.tex"
    end

end

