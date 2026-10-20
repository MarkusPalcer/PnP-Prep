testsuite "Blueprint Integration Tests" do
    test "Children in Panel" do 
        file "01-children-in-panel.tex"
    end

    test "Multiple Children in Panel" do
        file "02-multiple-children-in-panel.tex"
    end

    test "Multiple Child Types" do 
        file "03-multiple-child-types.tex"
    end

    test "Multiple Child Instances" do 
        file "04-multiple-child-instances.tex"
    end

    test "Multiple Parent Instances" do
        file "05-multiple-parent-instances.tex"
    end

    test "Complex Blueprint Rendering" do 
        file "06-complex-blueprint-rendering.tex"
    end

    test "Real World Blueprint Example" do
        file "07-real-world-blueprint-example.tex"
    end
end