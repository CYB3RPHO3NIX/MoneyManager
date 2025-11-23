# XML Query Specification (Final Version)

This document defines a **universal XML Query Specification format** that can be passed into a SQL Server stored procedure. The procedure will parse the XML and generate a SQL query that supports:

- Selected columns
- WHERE conditions (no grouping)
- Sorting
- Pagination (page number + page size)

The XML specifies **only the table/view name once** inside the `<root>` tag. All other tags use only column names.

---

## 1. Root Element Structure

```xml
<root queryName="Meaningful Description Here" table="[schema].[tableName]">
    <columns>
        <column>ColumnName</column>
        <column>Age</column>
        <column>Gender</column>
    </columns>

    <conditions>
        <condition column="Gender" operator="=">Male</condition>
        <condition column="Age" operator=">">18</condition>
        <condition column="Name" operator="LIKE">son|veer|raj</condition>
        <condition column="City" operator="IN">Mumbai|Delhi|Goa</condition>
        <condition column="Status" operator="NOT IN">Inactive|Banned</condition>
    </conditions>

    <sort column="Name" direction="ascending" />

    <page number="1" size="10" />
</root>
```

---

## 2. Element Definitions

### **2.1 `<root>`**
Attributes:
- `queryName` — Human readable description.
- `table` — Table or view name.

---

### **2.2 `<columns>`**
Defines columns to return.

```xml
<columns>
    <column>Name</column>
    <column>Age</column>
    <column>Gender</column>
</columns>
```

---

## 3. WHERE Condition Operators

Supported operators:
- `=`
- `!=`
- `>`
- `<`
- `>=`
- `<=`
- `LIKE` (single or multiple pipe-separated values)
- `IN` (pipe-separated values)
- `NOT IN` (pipe-separated values)

### **3.1 Equality (=)**
```xml
<condition column="Gender" operator="=">Male</condition>
```

### **3.2 Not Equal (!=)**
```xml
<condition column="Status" operator="!=">Inactive</condition>
```

### **3.3 Greater Than (>)**
```xml
<condition column="Age" operator=">">18</condition>
```

### **3.4 Less Than (<)**
```xml
<condition column="Age" operator="<">30</condition>
```

### **3.5 Greater Than or Equal (>=)**
```xml
<condition column="Marks" operator=">=">50</condition>
```

### **3.6 Less Than or Equal (<=)**
```xml
<condition column="Marks" operator="<=">100</condition>
```

### **3.7 LIKE (single or multiple values)**
Raw values provided → stored procedure auto wraps with `%value%` for each.

```xml
<condition column="Name" operator="LIKE">son|veer|raj</condition>
```
SQL becomes:
```sql
(Name LIKE '%son%' OR Name LIKE '%veer%' OR Name LIKE '%raj%')
```

### **3.8 IN (pipe-separated values)**
```xml
<condition column="Department" operator="IN">HR|Finance|IT</condition>
```
SQL becomes:
```sql
Department IN ('HR','Finance','IT')
```

### **3.9 NOT IN (pipe-separated values)**
```xml
<condition column="City" operator="NOT IN">London|Paris</condition>
```
SQL becomes:
```sql
City NOT IN ('London','Paris')
```

---

## 4. Sorting

```xml
<sort column="Name" direction="ascending" />
```
Maps to:
```sql
ORDER BY Name ASC
```

---

## 5. Pagination

```xml
<page number="4" size="10" />
```

SQL computed as:
```
OFFSET = (4 - 1) * 10 = 30
FETCH = 10
```

```sql
OFFSET 30 ROWS FETCH NEXT 10 ROWS ONLY
```

---

## 6. Full Example

```xml
<root queryName="Fetching only male students" table="[students]">
    <columns>
        <column>Name</column>
        <column>Age</column>
        <column>Gender</column>
    </columns>

    <conditions>
        <condition column="Gender" operator="=">male</condition>
        <condition column="Name" operator="LIKE">son|veer|raj</condition>
    </conditions>

    <sort column="Name" direction="ascending" />

    <page number="4" size="10" />
</root>
```

---

## 7. Output Format

Example output:
```
Name | Age | Gender
abc  | 25  | Male
xyz  | 24  | Male
```

---

## 8. Restrictions
- No GROUP BY
- No aggregation
- Only simple WHERE + ORDER BY + Pagination
- Columns should match the specified table
- SQL injection protections must be applied

---

## 9. Next Step
Stored Procedure `usp_ExecuteXmlQuery` can now be generated to:
- Parse XML
- Build SQL