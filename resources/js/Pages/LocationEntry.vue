<script setup>
import { ref, computed } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link } from '@inertiajs/vue3';
import TextInput from '@/Components/TextInput.vue';
import ComboBox from '@/Components/ComboBox.vue';
import RIForm from '@/Components/RIForm.vue';

defineProps({
    breadcrumb: {
        type: Array,
    },
});

// Field accessors, shared by search (checks every field) and per-column sort
// (checks the one field a header was clicked for).
const fieldGetters = {
	code: (r) => r.code ?? '',
	route: (r) => r.Route ?? '',
	block: (r) => r.Block ?? '',
	aisle: (r) => r.Aisle ?? '',
	lane: (r) => r.Lane ?? '',
	stack: (r) => r.Stack ?? '',
	use: (r) => r.use?.use ?? '',
	status: (r) => r.status ?? '',
};

// Search box: narrows the list in place by matching any column.
const locationSearch = ref('');

function locationMatchesSearch(record) {
	const text = locationSearch.value.trim().toLowerCase();
	if (!text) return true;
	return Object.values(fieldGetters).some((get) => String(get(record)).toLowerCase().includes(text));
}

// Column-header sorting: clicking a header sorts by that field, clicking the
// same header again flips direction.
const sortField = ref('code');
const sortDir = ref(1);

function setSort(field) {
	if (sortField.value === field) {
		sortDir.value = -sortDir.value;
	} else {
		sortField.value = field;
		sortDir.value = 1;
	}
}

function sortArrow(field) {
	if (sortField.value !== field) return '';
	return sortDir.value === 1 ? ' ▲' : ' ▼';
}

const locationSort = computed(() => (a, b) => {
	const get = fieldGetters[sortField.value];
	return sortDir.value * String(get(a)).localeCompare(String(get(b)), undefined, { numeric: true });
});
</script>

<template>
  <Head :title="$t('Commons.title.location_management')" />
  <AuthenticatedLayout :breadcrumb="breadcrumb">
    <RIForm
		:title="$t('Commons.title.manage_locations')"
		datasource="/json/locations"
		:newrecordcaption="$t('Commons.text.add_location')"
		:filter="locationMatchesSearch"
		:sort="locationSort">

      <template #titleactions>
        <Link href="/setup/locations/pick-path" class="ri_formbutton">{{ $t('Commons.link.pick_path', {}) }}</Link>
      </template>

      <template #listactions>
        <input
          type="text"
          v-model="locationSearch"
          class="ri_forminput location_search"
          :placeholder="$t('Pages.placeholder.search_all_fields')"
        />
      </template>

      <template #thead>
        <th class="ri_sortable" @click="setSort('code')">{{ $t('Commons.text.code_2') }} {{ sortArrow('code') }}</th>
        <th class="ri_sortable" @click="setSort('route')">{{ $t('Commons.text.route') }} {{ sortArrow('route') }}</th>
        <th class="ri_sortable" @click="setSort('block')">{{ $t('Commons.text.block') }} {{ sortArrow('block') }}</th>
        <th class="ri_sortable" @click="setSort('aisle')">{{ $t('Commons.text.aisle') }} {{ sortArrow('aisle') }}</th>
        <th class="ri_sortable" @click="setSort('lane')">{{ $t('Commons.text.lane') }} {{ sortArrow('lane') }}</th>
        <th class="ri_sortable" @click="setSort('stack')">{{ $t('Commons.text.stack') }} {{ sortArrow('stack') }}</th>
        <th class="ri_sortable" @click="setSort('use')">{{ $t('Commons.text.use_2') }} {{ sortArrow('use') }}</th>
        <th class="ri_sortable" @click="setSort('status')">{{ $t('Commons.button.status') }} {{ sortArrow('status') }}</th>
      </template>

      <template #tbody="{ record, index }">
        <td>{{ record.code }}</td>
        <td>{{ record.Route }}</td>
        <td>{{ record.Block }}</td>
        <td>{{ record.Aisle }}</td>
        <td>{{ record.Lane }}</td>
        <td>{{ record.Stack }}</td>
        <td>{{ record.use ? record.use.use : '' }}</td>
        <td>{{ record.status }}</td>
      </template>

      <template #default="{ record, editing }">
        <div class="ri_formtable">
          <div class="ri_fieldset">
            <div class="ri_fieldlabel">{{ $t('Commons.text.code', {}) }}</div>
            <TextInput v-model="record.code" :enabled="editing" required />
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">{{ $t('Commons.text.route_2', {}) }}</div>
            <TextInput v-model="record.Route" :enabled="editing" />
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">{{ $t('Commons.text.block_2', {}) }}</div>
            <TextInput v-model="record.Block" :enabled="editing" />
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">{{ $t('Commons.text.aisle_2', {}) }}</div>
            <TextInput v-model="record.Aisle" :enabled="editing" />
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">{{ $t('Commons.text.lane_2', {}) }}</div>
            <TextInput v-model="record.Lane" :enabled="editing" />
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">{{ $t('Commons.text.stack_2', {}) }}</div>
            <TextInput v-model="record.Stack" :enabled="editing" />
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">{{ $t('Commons.text.use', {}) }}</div>
            <ComboBox
              v-model:keyValue="record.use_id"
              v-model:updates="record.use"
              optionsource="/json/uses"
              :enabled="editing"
			  display="use"
            />
          </div>
		  
		  <div class="ri_fieldset">
		     <div class="ri_fieldlabel">{{ $t('Commons.text.pull_sequence', {}) }}</div>
		     <TextInput v-model="record.PullSequence" type="number" :enabled="editing" />
		   </div>


          <div class="ri_fieldset">
            <div class="ri_fieldlabel">{{ $t('Commons.text.status', {}) }}</div>
            <ComboBox 
              v-model="record.status"
              :options="[{ id: 'active', name: $t('Commons.text.active') }, { id: 'archived', name: $t('Commons.text.archived') }]"
              :enabled="editing"
            />
          </div>
        </div>
      </template>
    </RIForm>
  </AuthenticatedLayout>
</template>

<style scoped>
.location_search {
  max-width: 20rem;
}
</style>
