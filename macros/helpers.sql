{#-
    This helper macro allows a one-liner to create join conditions.

    ARGUMENTS

    leftTableAlias: String for the left table alias.
    rightTableAlias: String for the right table alias.
    leftTableColumns: List of columns from the left table to be used in the join condition.
    rightTableColumns: Default none. Pass a list of columns from the right table to be used
        in the join condition, if different from the left table.
    functionToApply: Default none. Pass a string here if each line needs
        to be wrapped in this function (e.g. EQUAL_NULL).
    lineSeparator: Default '\nAND '. Will be applied between every set
        of column clauses.

    EXAMPLES

    Where colList = ['colA', 'colB', 'colC'] and colList2 = ['colD', 'colE', 'colF']:

    join_condition('s', 't', colList)
    ->
    s.colA = t.colA
    AND s.colB = t.colB
    AND s.colC = t.colC

    join_condition('s', 't', colList, rightTableColumns = colList2)
    ->
    s.colA = t.colD
    AND s.colB = t.colE
    AND s.colC = t.colF

    join_condition('s', 't', colList, functionToApply = 'EQUAL_NULL')
    ->
    EQUAL_NULL(s.colA, t.colA)
    AND EQUAL_NULL(s.colB, t.colB)
    AND EQUAL_NULL(s.colC, t.colC)

    join_condition('s', 't', colList, lineSeparator = ',\n')
    ->
    s.colA = t.colA,
    s.colB = t.colB,
    s.colC = t.colC
#}
{%- macro join_condition(leftTableAlias, rightTableAlias, leftTableColumns, rightTableColumns = none, functionToApply = none, lineSeparator = '\nAND ') %}

    {%- set rightTableColumns = leftTableColumns if rightTableColumns is none else rightTableColumns %}

    {%- if leftTableColumns | length != rightTableColumns | length %}
        {{ exceptions.raise_compiler_error("Left and right column lists must be the same length.") }}
    {%- endif %}

    {%- set columnCount = leftTableColumns | length %}
    {%- set leftColumnsPrefixed = zip([leftTableAlias] * columnCount, leftTableColumns) | map('join', '.') %}
    {%- set rightColumnsPrefixed = zip([rightTableAlias] * columnCount, rightTableColumns) | map('join', '.') %}
    {%- if functionToApply is not none %}
        {#- Apply the passed function on every line with the elements as inputs #}
        {%- set lines =
            zip(
                zip([functionToApply ~ '('] * columnCount, leftColumnsPrefixed) | map('join'),
                zip(rightColumnsPrefixed, [')'] * columnCount) | map('join')
            ) | map('join', ', ')
        %}
    {%- else %}
        {#- No function to apply, normal equality join #}
        {%- set lines = zip(leftColumnsPrefixed, rightColumnsPrefixed) | map('join', ' = ') %}
    {%- endif %}
    {{ return(lines | join(lineSeparator)) }}

{%- endmacro %}
