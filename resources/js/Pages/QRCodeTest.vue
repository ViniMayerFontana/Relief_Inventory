<script setup>
import { ref } from 'vue';
import QrScanner from '@/Components/QrScanner.vue';

const scannedCode = ref('');

const handleScan = (code) => {
  scannedCode.value = code;
};
</script>

<template>
  <div>
    <h2>Ler código QR do item</h2>
    <QrScanner @scanned="handleScan" />
    <p>Código lido: {{ scannedCode }}</p>
  </div>
</template>