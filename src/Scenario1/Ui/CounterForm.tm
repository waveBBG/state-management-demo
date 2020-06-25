<template #default>
    Name: <Input :value="&name" />
    <div>
        <button @onClick="onMinus">-</button>{{ value }}<button @onClick="onPlus">+</button>
    </div>
    <div>
        Square: {{ square }}
    </div>
    <button @onClick="onSave">Save</button>
</template>