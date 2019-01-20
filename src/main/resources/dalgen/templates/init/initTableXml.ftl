<@pp.dropOutputFile />
<#import "../lib/lib.ftl" as lib/>
<#list dalgen.tables as table>
<@pp.changeOutputFile name = "/${dalgen.tablesPath}/${table.sqlName}.xml" />
<!DOCTYPE table SYSTEM "../config/table-config-1.0.dtd">
<table sqlname="${table.sqlName}" physicalName="${table.physicalName}"<#if table.remark??> remark="${table.remark!}"</#if>>
    <operation name="insert" paramtype="object" remark="insert:${table.sqlName}">
        <#if dalgen.dbType=="MySQL">
        <selectKey resultType="java.lang.Long" keyProperty="id" order="AFTER">
            select last_insert_id()
        </selectKey>
        </#if>
        insert into ${table.sqlName} (
        <#list table.columnList as column>
            <#if column_index gt 0>,</#if>${column.sqlName}
        </#list>
        ) values (
        <#list table.columnList as column>
            <#if column_index gt 0>,</#if> ${lib.insertVal(column)}
        </#list>
        )
    </operation>

<#if table.primaryKeys??>
    <operation name="update" paramtype="object" remark="update table:${table.sqlName}">
        update ${table.sqlName}
        set
        <#assign c_idx = 0>
        <#list table.columnList as column>
            <#if lib.updateIncludeColumn(column,table.primaryKeys.columnList)><#assign c_idx = c_idx+1>
            <#if c_idx gt 1>,</#if>${column.sqlName}${lib.space(column.sqlName)} = ${lib.updateVal(column)}
            </#if>
        </#list>
        where
        <#list table.primaryKeys.columnList as column>
            <#if column_index gt 0>and </#if>${column.sqlName}${lib.space(column.sqlName)} = ${"#"}{${column.javaName},jdbcType=${column.sqlType}}
        </#list>
    </operation>

    <operation name="deleteBy${table.primaryKeys.pkName}" multiplicity="one" remark="delete:${table.sqlName}">
        delete from
            ${table.sqlName}
        where
        <#list table.primaryKeys.columnList as column>
            <#if column_index gt 0>and </#if>${column.sqlName} = ${"#"}{${column.javaName},jdbcType=${column.sqlType}}
        </#list>
    </operation>

    <operation name="getBy${table.primaryKeys.pkName}" multiplicity="one" remark="get:${table.sqlName}">
        select *
        from ${table.sqlName}
        where
        <#list table.primaryKeys.columnList as column>
            <#if column_index gt 0>and </#if>${column.sqlName} = ${"#"}{${column.javaName},jdbcType=${column.sqlType}}
        </#list>
    </operation>
</#if>
</table>
</#list>