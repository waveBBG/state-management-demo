<import as="Counter_" from="Scenario3/Ui/CounterForm" />
<template #default>
    <dynamic :expand="counters">
        <Counter_ #element :counter="#element" />
    </dynamic>
    <button @onClick="onAdd">add counter</button>
    <dynamic :visible="hasSelected">
        <button @onClick="onDelete">delete selected counters</button>
    </dynamic>
</template>