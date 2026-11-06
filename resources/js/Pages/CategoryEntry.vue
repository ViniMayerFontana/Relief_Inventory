<script setup>
import { ref, computed } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import TextInput from '@/Components/TextInput.vue';
import RIForm from '@/Components/RIForm.vue';
import { itemCategoryLabel } from '@/labels';

defineProps({
    breadcrumb: {
        type: Array,
    },
});

// Search box: narrows the list in place by Category Name.
const categorySearch = ref('');

function categoryMatchesSearch(record) {
	const text = categorySearch.value.trim().toLowerCase();
	if (!text) return true;
	return String(record.name ?? '').toLowerCase().includes(text) || categoryLabel(record.name).toLowerCase().includes(text);
}
const categoryLabel = itemCategoryLabel;

// Column-header sorting: clicking a header sorts by that field, clicking the
// same header again flips direction.
const sortDir = ref(1);

function setSort() {
	sortDir.value = -sortDir.value;
}

function sortArrow() {
	return sortDir.value === 1 ? ' ▲' : ' ▼';
}

const categorySort = computed(() => (a, b) => sortDir.value * String(a.name ?? '').localeCompare(String(b.name ?? ''), undefined, { numeric: true }));
</script>

<template>
  <Head title="Cadastro de categorias de itens" />
  <AuthenticatedLayout :breadcrumb="breadcrumb">
    <template #header>
    </template>

    <RIForm
      title="Gerenciamento de categorias de itens"
      datasource="/json/categories"
	  newrecordcaption="Adicionar categoria"
	  :filter="categoryMatchesSearch"
	  :sort="categorySort">
      <template #listactions>
        <input
          type="text"
          v-model="categorySearch"
          class="ri_forminput category_search"
          placeholder="Buscar por nome da categoria..."
        />
      </template>
      <template #thead>
        <th class="ri_sortable" @click="setSort()">Nome da categoria{{ sortArrow() }}</th>
      </template>
      <template #tbody="{ record, index }">
        <td>{{ categoryLabel(record.name) }}</td>
      </template>
      <template #default="{ record, editing, templates }">
        <div class="ri_formtable">
          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Nome da categoria:</div>
            <TextInput
              v-model="record.name"
              required
              autofocus
              :enabled="editing"
            /> 
          </div>
        </div>
      </template>
    </RIForm>
  </AuthenticatedLayout>
</template>

<style scoped>
.category_search {
  max-width: 20rem;
}
</style>
