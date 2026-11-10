testsuite "Blueprint Integration Tests" do
    test "Children in Panel" do 
        file "01-children-in-panel.tex"
        user_assert "The panel title is 'P'."
        user_assert "The panel shows 'Parent: P'."
        user_assert "The panel shows 'Child: C'."
        user_assert "The child content appears inside the panel content area."
        user_assert "The child is not rendered outside the panel."
    end

    test "Multiple Children in Panel" do
        file "02-multiple-children-in-panel.tex"
        user_assert "The panel title is 'P'."
        user_assert "The panel shows 'Parent: P'."
        user_assert "The panel shows 'Child A: A'."
        user_assert "The panel shows 'Child B: B'."
        user_assert "All children are rendered inside the panel content area."
        user_assert "Children appear in registration order."
        user_assert "No child content appears outside the panel."
    end

    test "Multiple Child Types" do 
        file "03-multiple-child-types.tex"
        user_assert "The panel title is 'Parent'."
        user_assert "The panel shows 'Parent: Goblin'."
        user_assert "The panel shows 'Weapon: Sword'."
        user_assert "The panel shows 'AT: 12'."
        user_assert "The panel shows 'PA: 8'."
        user_assert "The panel shows 'TP: 1W+2'."
        user_assert "The panel shows 'INI: 8'."
        user_assert "The panel shows 'Armor: Leather Armor'."
        user_assert "The panel shows 'RS: 2'."
        user_assert "The parent content appears inside the panel."
        user_assert "Both child types appear inside the panel."
        user_assert "Child order is preserved."
        user_assert "Field values of each child do not overwrite each other."
    end

    test "Multiple Child Instances" do 
        file "04-multiple-child-instances.tex"
        user_assert "The panel title is 'Parent'."
        user_assert "The panel shows 'Parent: Character'."
        user_assert "The panel shows 'Weapon: Sword'."
        user_assert "The panel shows 'AT: 12' for the sword."
        user_assert "The panel shows 'Weapon: Axe'."
        user_assert "The panel shows 'AT: 10' for the axe."
        user_assert "The panel shows 'Armor: Leather Armor'."
        user_assert "The panel shows 'RS: 2'."
        user_assert "All child instances appear inside the panel."
        user_assert "Child instances appear in creation order."
        user_assert "Each child instance keeps its own field values."
        user_assert "The second weapon does not reuse values from the first weapon."
    end

    test "Multiple Parent Instances" do
        file "05-multiple-parent-instances.tex"
        user_assert "The first panel title is 'Parent A'."
        user_assert "The first panel shows 'Parent: A'."
        user_assert "The first panel shows 'Weapon: Sword'."
        user_assert "The first panel shows 'AT: 12'."
        user_assert "The second panel title is 'Parent B'."
        user_assert "The second panel shows 'Parent: B'."
        user_assert "The second panel shows 'Weapon: Axe'."
        user_assert "The second panel shows 'AT: 10'."
        user_assert "The first panel contains only data from Parent A."
        user_assert "The second panel contains only data from Parent B."
        user_assert "Children do not leak between parent instances."
        user_assert "Field values do not leak between parent instances."
    end

    test "Complex Blueprint Rendering" do 
        file "06-complex-blueprint-rendering.tex"
        user_assert "The panel title is 'Goblin'."
        user_assert "The panel shows 'Name: Goblin'."
        user_assert "The panel shows 'Courage: 8'."
        user_assert "The panel shows 'Weapon: Club'."
        user_assert "The panel shows 'Damage: 1W+2'."
        user_assert "The panel shows 'Modifier: 0'."
        user_assert "The panel shows 'Armor: Hide'."
        user_assert "The panel shows 'Protection: 1'."
        user_assert "The panel title matches the parent name."
        user_assert "Parent fields are rendered correctly."
        user_assert "Child fields do not overwrite parent fields."
        user_assert "Optional fields are handled correctly."
        user_assert "\\ifpresent only shows existing optional values."
        user_assert "\\ifmissing shows fallback values."
        user_assert "Children remain inside the parent panel."
    end

    test "Real World Blueprint Example" do
        file "07-real-world-blueprint-example.tex"
        user_assert "Two panels are rendered."
        user_assert "The first panel title is 'Soldat 1'."
        user_assert "The first panel shows 'Schwert1 : AT: 12 PA: 8 TP: 1W+2 INI: 8'."
        user_assert "The first panel shows 'Rüstung1 : RS: 4'."
        user_assert "The second panel title is 'Soldat'."
        user_assert "The second panel shows 'KK: 12'."
        user_assert "The second panel shows 'Schwert : AT: 12 PA: 4 TP: 1W+1 INI: 15'."
        user_assert "Each blueprint instance creates its own panel."
        user_assert "Each panel title contains its blueprint instance name."
        user_assert "Child instances are rendered inside their parent panel."
        user_assert "Child order is preserved."
        user_assert "Child values do not leak between parent instances."
        user_assert "Fields with the same name in different blueprints remain independent."
        user_assert "Optional fields are rendered only when present."
        user_assert "Missing optional values do not cause a compilation error."
    end
end