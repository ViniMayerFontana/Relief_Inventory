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
    <h2>{{ $t('Pages.heading.scan_item_qr_code', {}) }}</h2>
    <QrScanner @scanned="handleScan" />
    <p>{{ $t('Commons.text.scanned_code') }} {{ scannedCode }}</p>
  </div>
</template>