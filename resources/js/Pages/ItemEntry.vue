<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->
	 
<!-- ItemEntry.vue 
	This is an RIForm Vue File. It's similar to a normal Vue file except that it 
	requires no script or code. Use this as a model for other RIForm Vue Files -->

<script setup>
import { ref, computed } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import HelpLink from '@/Components/HelpLink.vue';
import { Head, usePage } from '@inertiajs/vue3';
import axios from 'axios';
import Modal from '@/Components/Modal.vue';
import SearchSelect from '@/Components/SearchSelect.vue';
import TextInput from '@/Components/TextInput.vue';
import ComboBox from '@/Components/ComboBox.vue';
import RIForm from '@/Components/RIForm.vue';
import RISubform from '@/Components/RISubform.vue';
import Checkbox from '@/Components/Checkbox.vue';
import { t } from '@/i18n';

defineProps({
    breadcrumb: {
        type: Array,
    },
});

// Moving an item (one SKU row) to another ACS # - Administrators only. Everything in
// the database links to the item itself, so its stock and history move with it.
const canMove = computed(() => !!usePage().props.catalog?.canMoveItems);
const move = ref({ open: false, item: null, impact: null, itemtype_id: null, busy: false, error: '' });

async function openMove(item) {
	move.value = { open: true, item, impact: null, itemtype_id: null, busy: false, error: '' };
	try {
		move.value.impact = (await axios.get(`/json/items/${item.id}/move-impact`)).data;
	} catch (e) {
		move.value.error = e.response?.data?.message || t('Pages.text.could_not_load_what');
	}
}

async function confirmMove() {
	const m = move.value;
	if (!m.itemtype_id) { m.error = t('Pages.text.choose_the_acs_to'); return; }
	m.busy = true;
	m.error = '';
	try {
		await axios.post(`/json/items/${m.item.id}/move`, { itemtype_id: m.itemtype_id });
		window.location.reload(); // the open Item Type record is stale now
	} catch (e) {
		m.error = e.response?.data?.message || e.response?.data?.errors?.itemtype_id?.[0] || t('Pages.text.the_move_failed');
		m.busy = false;
	}
}

// Search box: narrows the list in place by ACS Item# or Item Type name (same
// pattern as People.vue's name/organization search).
const itemSearch = ref('');

function itemMatchesSearch(record) {
	const text = itemSearch.value.trim().toLowerCase();
	if (!text) return true;
	return (
		String(record.display_number ?? '').toLowerCase().includes(text) ||
		String(record.name ?? '').toLowerCase().includes(text)
	);
}

// Column-header sorting: clicking a header sorts by that field, clicking the
// same header again flips direction.
const sortField = ref('category');
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

const sortKeys = {
	category: (r) => r.category?.name ?? '',
	number: (r) => r.display_number ?? '',
	name: (r) => r.name ?? '',
	unit: (r) => r.unit?.abbreviation ?? '',
	active: (r) => (r.active ? 1 : 0),
};

const itemSort = computed(() => (a, b) => {
	const key = sortKeys[sortField.value];
	const av = key(a);
	const bv = key(b);
	const cmp = typeof av === 'number' ? av - bv : String(av).localeCompare(String(bv), undefined, { numeric: true });
	return sortDir.value * cmp;
});


</script>
<template>
  <Head :title="$t('Pages.title.master_item_catalog')" />
  <AuthenticatedLayout :breadcrumb="breadcrumb">
	<template #header>
	</template>
	
	<!-- Include the the RIForm Component. This component will attach to the JSON
	     API URL specified in the datasource="" attribute for loading and saving data.
	  -->
	<RIForm
	  :title="$t('Pages.title.master_item_list')"
	  datasource="/json/itemtypes"
	  :newrecordcaption="$t('Pages.text.add_new_item')"
	  :filter="itemMatchesSearch"
	  :sort="itemSort">

	  <template #listactions>
		<input
		  type="text"
		  v-model="itemSearch"
		  class="ri_forminput item_search"
		  :placeholder="$t('Pages.placeholder.search_by_acs_item')"
		/>
	    <HelpLink guide="items">{{ $t('Pages.text.master_item_list_guide', {}) }}</HelpLink>
	  </template>

	    <template #thead>
			<th class="ri_sortable" @click="setSort('category')">{{ $t('Commons.text.category_2') }} {{ sortArrow('category') }}</th>
			<th class="ri_sortable" @click="setSort('number')">{{ $t('Commons.text.acs_item') }} {{ sortArrow('number') }}</th>
			<th class="ri_sortable" @click="setSort('name')">{{ $t('Commons.text.item_type') }} {{ sortArrow('name') }}</th>
			<th class="ri_sortable" @click="setSort('unit')">{{ $t('Commons.text.unit') }} {{ sortArrow('unit') }}</th>
		    <th class="ri_sortable" style="text-align:center;" @click="setSort('active')">{{ $t('Commons.text.active') }} {{ sortArrow('active') }}</th>
		</template>
		<template #tbody="{ record, index }">
			<td> {{ record.category.name }} </td>
			<td> {{ record.display_number }} </td>
			<td> {{ record.name }} </td>
			<td> {{ record.unit.abbreviation }} </td>
			<td style="text-align: center;"> <span v-if="record.active"> &check; </span> </td>
		</template>
		<template #default="{ record, editing, templates }">
		<div class="ri_formtable">
		  <div class="ri_fieldset">
			  <div class="ri_fieldlabel">{{ $t('Commons.text.category_2', {}) }}</div>
			  <ComboBox
			  		v-model:keyValue="record.category_id"
			  					v-model:updates="record.category"
			  					optionsource="/json/categories"
			  				  	:enabled="editing"
			    /> 
		  </div>	
		  <div class="ri_fieldset">
		  		<div class="ri_fieldlabel">{{ $t('Commons.text.family', {}) }}</div>
		  		<TextInput
		  			    v-model="record.family"
		  			    :placeholder="$t('Pages.placeholder.e_g_318')"
		  			    autofocus
		  				:enabled="editing"
		  		  />
		  	  </div>
		  <div class="ri_fieldset">
		  		<div class="ri_fieldlabel">{{ $t('Commons.text.variant_optional', {}) }}</div>
		  		<TextInput
		  			    v-model="record.variant"
		  			    :placeholder="$t('Pages.placeholder.e_g_90')"
		  				:enabled="editing"
		  		  />
		  	  </div>
		  <div class="ri_fieldset">
			<div class="ri_fieldlabel">{{ $t('Pages.text.item_type_desc', {}) }}</div>
			<TextInput
				    v-model="record.name"
				    required
					:enabled="editing"
			  /> 
		  </div>
		  <div class="ri_fieldset">
		    <div class="ri_fieldlabel">{{ $t('Pages.text.default_ordering_unit', {}) }}</div>
		    <ComboBox
		  		v-model:keyValue="record.unit_id"
		  					v-model:updates="record.unit"
		  					optionsource="/json/units"
		  				  	:enabled="editing"
		    /> 
		  </div>	
		  <div class="ri_fieldset">
			  <div class="ri_fieldlabel">{{ $t('Commons.text.active', {}) }}</div>
			  <Checkbox
			  		v-model="record.active"
			  				  	:enabled="editing"
			    /> 
		  </div>	 
			<RISubform 
					:title="$t('Commons.title.items')"  
								v-model:records="record.items"
								:template="templates.items" 
								:enabled="editing">
				<template #thead>
					<th> {{ $t('Commons.placeholder.plus_code', {}) }} </th>
					<th>{{ $t('Commons.text.item_description', {}) }}</th>
					<th colspan="3">{{ $t('Commons.text.package', {}) }}</th>
					<th>{{ $t('Commons.text.total') }} {{ record.unit.abbreviation }}</th>
					<th>{{ $t('Commons.placeholder.upc', {}) }}</th>
					<th v-if="canMove"></th>
				</template>
				<template #tbody="{ subrecord, index }">
					<td>{{ subrecord.pluscode }}</td>
					<td>{{ subrecord.description }}</td>
				     <td colspan="3">{{ subrecord.packagetype.singular }} 
						 <span v-if="subrecord.case_qty"> of {{ subrecord.case_qty }} ( {{ subrecord.size * 1.0 }} {{ record.unit.abbreviation }} )</span></td>
					 <td><span v-if="subrecord.case_qty"> {{ subrecord.case_qty * subrecord.size }}</span>
					     <span v-else>{{ subrecord.size * 1.0 }}</span></td>	 
					 <td> {{ subrecord.upc }}</td>
					 <td v-if="canMove"><button v-if="subrecord.id" type="button" class="ri_formbutton" @click="openMove(subrecord)">{{ $t('Pages.button.move_to_acs', {}) }}</button></td>
				</template>
				<template #default="{ subrecord, index }">
				  <td>
					<TextInput
						    v-model="subrecord.pluscode"
							:placeholder="$t('Commons.placeholder.plus_code')"
							:enabled="true"
					  /> 
				  </td>
				  <td>
	  				<TextInput
	  					    v-model="subrecord.description"
	  						:placeholder="$t('Commons.placeholder.description')"
	  						:enabled="true"
	  				  /> 
				   </td>
				  <td>
					<ComboBox 
					    v-model:keyValue="subrecord.packagetypes_id"
						v-model:updates="subrecord.packagetype"
						optionsource="/json/packagetypes"
						display="singular"
						:placeholder="$t('Commons.placeholder.pk_unit')"
						:enabled="true" />
				  </td>
				  <td>
				  <TextInput
				   		v-model="subrecord.size" 
						type="number"
						:placeholder="'Size in ' + record.unit.abbreviation"
						:enabled="true"
				        />
				  </td>
				  <td>
				  <TextInput
				   		v-model="subrecord.case_qty" 
					  	type="number"
						:placeholder="$t('Commons.placeholder.case_qty')"
					  	:enabled="true"
				   />
				  </td>
				  <td><span v-if="subrecord.case_qty"> {{ subrecord.case_qty * subrecord.size }}</span>
					<span v-else>{{ subrecord.size * 1.0 }}</span></td>
				  <td>
				  <TextInput
				  	    v-model="subrecord.upc"
						:placeholder="$t('Commons.placeholder.upc')"
				  		:enabled="true"
				    /> 
				  </td>
				  <td v-if="canMove"><button v-if="subrecord.id" type="button" class="ri_formbutton" @click="openMove(subrecord)">{{ $t('Pages.button.move_to_acs', {}) }}</button></td>
				</template>
			</RISubform>  
	  </div>
	  </template>
	</RIForm>

	<Modal :show="move.open" max-width="lg" @close="move.open = false">
		<div class="item_move">
			<h3>{{ $t('Pages.heading.move_item_to_a', {}) }}</h3>
			<p v-if="move.item"><strong>{{ move.item.description || $t('Commons.text.no_description') }}</strong><span v-if="move.impact"> {{ $t('Pages.text.now_under') }} {{ move.impact.item.acs }} {{ move.impact.item.itemtype }}</span></p>
			<label>{{ $t('Pages.label.new_acs_item_type', {}) }}</label>
			<SearchSelect
				v-model="move.itemtype_id"
				optionsource="/json/itemtypes/noitems"
				display="name"
				:searchfields="['name', 'display_number']"
				:placeholder="$t('Pages.placeholder.search_item_types')"
			/>
			<div v-if="move.impact" class="item_move_warn">
				<strong>{{ $t('Pages.text.this_changes_history_not', {}) }}</strong>
				{{ $t('Pages.text.everything_recorded_against_this') }}
				{{ move.impact.ledger_rows }} sorting/fill ledger row(s) (so stock on hand and the inventory and flow reports change),
				{{ move.impact.pallet_assignments }} pallet stock entr{{ move.impact.pallet_assignments === 1 ? 'y' : 'ies' }}
				{{ $t('Pages.text.and_any_carton_barcodes') }}
				<span v-if="move.impact.order_fills">
					{{ move.impact.order_fills }} {{ $t('Pages.text.of_its_ledger_rows') }}
				</span>
				{{ $t('Pages.text.already_printed_inventory_labels', {}) }}
			</div>
			<p v-if="move.error" class="item_move_error">{{ move.error }}</p>
			<div class="item_move_actions">
				<button type="button" class="ri_defaultbutton" :disabled="move.busy || !move.impact" @click="confirmMove">{{ move.busy ? $t('Pages.button.moving') : $t('Commons.button.move_item') }}</button>
				<button type="button" class="ri_formbutton" @click="move.open = false">{{ $t('Commons.button.cancel', {}) }}</button>
			</div>
		</div>
	</Modal>
	</AuthenticatedLayout>
</template>

<style scoped>
.item_move { padding: 1.25rem; display: grid; gap: 0.75rem; }
.item_move_warn { background: #fef3c7; border: 1px solid #d97706; border-radius: 6px; padding: 0.75rem; font-size: 0.9rem; }
.item_move_error { color: #b00020; }
.item_move_actions { display: flex; gap: 0.5rem; }
.item_search {
  max-width: 20rem;
}
</style>






