<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import HelpLink from '@/Components/HelpLink.vue';
import { Head } from '@inertiajs/vue3';
import TextInput from '@/Components/TextInput.vue';
import ComboBox from '@/Components/ComboBox.vue';
import RIForm from '@/Components/RIForm.vue';
import RISubform from '@/Components/RISubform.vue';
import PrintMenu from '@/Components/PrintMenu.vue';
import { palletKindLabel, palletStatusLabel } from '@/labels';

defineProps({
    breadcrumb: {
        type: Array,
    },
});

const kindOptions = [
	{ id: 'R', name: 'Recebimento' },
	{ id: 'W', name: 'Armazém' },
	{ id: 'S', name: 'Expedição' },
	{ id: 'H', name: 'Retenção' },
	{ id: 'Q', name: 'Quarentena' },
];

// Mirrors App\Support\PalletKind::LIFECYCLES (+ 'missing'); the server still validates.
const statusesByKind = {
	R: ['received', 'sorting', 'empty'],
	W: ['sealed', 'open', 'empty'],
	S: ['building', 'ready', 'shipped'],
	H: ['filling', 'ready', 'collected'],
	Q: ['held', 'released', 'condemned'],
};
const statusOptions = (kind) =>
	[...(statusesByKind[kind] || []), 'missing'].map((s) => ({ id: s, name: palletStatusLabel(s) }));

const containerTypeOptions = [
	{ id: 'pallet', name: 'Palete' },
	{ id: 'gaylord', name: 'Caixa Gaylord' },
	{ id: 'box', name: 'Caixa' },
	{ id: 'bag', name: 'Saco' },
	{ id: 'tote', name: 'Caixa plástica' },
];
</script>

<template>
  <Head title="Gerenciamento de paletes" />
  <AuthenticatedLayout :breadcrumb="breadcrumb">
    <RIForm
      title="Gerenciamento de paletes"
      datasource="/json/pallets"
	  :precreate="false"
	  >
      <template #listactions>
        <HelpLink guide="inventory-movement">Guia de movimentação do estoque</HelpLink>
      </template>

      <template #thead>
		<th>Etiqueta</th>
        <th>Tipo</th>
        <th>Data de embalagem</th>
        <th>Local</th>
        <th>Status</th>
      </template>

      <template #tbody="{ record, index }">
		<td><span style="font-weight: bold; font-size: 14pt;"> {{ record.kind }}{{ record.id.toString().padStart(8, "0") }}</span></td>
        <td>{{ palletKindLabel(record.kind) }}</td>
        <td>{{ record.datepacked }}</td>
        <td v-if="record.location">{{ record.location.code }}</td>
        <td v-else>Desconhecido</td>
        <td>{{ palletStatusLabel(record.status) }}</td>
      </template>

      <template #default="{ record, editing, templates }">

		<div class="ri_formtable">
		  <div class="ri_fieldset" v-if="record.id">
		    <div class="ri_fieldlabel"> Etiqueta do palete </div>
		    <span style="font-weight: bold; font-size: 14pt;"> {{ record.kind }}{{ record.id.toString().padStart(8, "0") }}</span>
		  </div>
		</div>
		  <div class="ri_fieldset" v-if="record.id">
			<div class="ri_fieldlabel">  </div>
			<p>
			<PrintMenu document-key="pallet-label" :media="$page.props.printing.palletLabelMedia" label="Imprimir etiqueta do palete"
				:params="{ id: record.id }" :download-href="'/report/pallet/' + record.id" />
			</p>
		  </div>
		  <div class="ri_formtable">
		    <div class="ri_fieldset">
		      <div class="ri_fieldlabel">Tipo:</div>
			  <!-- Fixed forever once labeled (new-label-per-trip rule) -->
			  <ComboBox
			  	v-model:keyValue="record.kind"
			  	:options="kindOptions"
			  	:enabled="editing && !record.id"
			  />
		    </div>

		    <div class="ri_fieldset">
		      <div class="ri_fieldlabel">Data de embalagem:</div>
		      <TextInput
		        id="datepacked"
		        type="date"
		        v-model="record.datepacked"
		        required
		        autofocus
		        :enabled="editing"
		      />
		    </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Local:</div>
            <ComboBox
              v-model:keyValue="record.location_id"
              v-model:updates="record.location"
              optionsource="/json/locations"
              :enabled="editing"
			  display="code"
            />
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Status:</div>
            <ComboBox
              v-model:keyValue="record.status"
              :options="statusOptions(record.kind)"
              :enabled="editing"
            />
          </div>

		  <div class="ri_fieldset">
			<div class="ri_fieldlabel">Tipo de recipiente:</div>
			<ComboBox
			  v-model:keyValue="record.container_type"
			  :options="containerTypeOptions"
			  :enabled="editing"
			/>
		  </div>

		  <div class="ri_fieldset" v-if="record.kind === 'R'">
			<div class="ri_fieldlabel">Doador:</div>
			<ComboBox
			  v-model:keyValue="record.donor_person_id"
			  v-model:updates="record.donor"
			  optionsource="/json/people"
			  display="last_name"
			  :enabled="editing"
			/>
		  </div>

		  <div class="ri_fieldset" v-if="record.kind === 'H'">
			<div class="ri_fieldlabel">Destino:</div>
			<ComboBox
			  v-model:keyValue="record.destination_person_id"
			  v-model:updates="record.destination"
			  optionsource="/json/people"
			  display="last_name"
			  :enabled="editing"
			/>
		  </div>

		  <div class="ri_fieldset" v-if="record.kind === 'W'">
			<div class="ri_fieldlabel">Vencimento mais próximo:</div>
			<TextInput
			  type="date"
			  v-model="record.earliest_expiry"
			  :enabled="editing"
			/>
		  </div>

		  <div class="ri_fieldset" v-if="record.condition">
			<div class="ri_fieldlabel">Condição:</div>
			<ComboBox
			  v-model:keyValue="record.condition"
			  :options="[{ id: 'pending', name: 'Aguardando controle de qualidade' }, { id: 'good', name: 'Bom' }, { id: 'condemned', name: 'Condenado' }]"
			  :enabled="editing"
			/>
		  </div>
        </div>

        <RISubform
          title="Histórico de status do palete"
          v-model:records="record.statuses"
          :template="[]"
          :enabled="false">

          <template #thead>
            <th>Data</th>
            <th>Local</th>
            <th>Status</th>
			<th>Observações</th>
          </template>

          <template #tbody="{ subrecord, index }">
            <td>{{ subrecord.created_at }}</td>
            <td>{{ subrecord.location ? subrecord.location.code : '' }}</td>
            <td>{{ palletStatusLabel(subrecord.status) }}</td>
			<td>{{ subrecord.notes }}</td>
          </template>

          <template #default="{ subrecord, index }">
            <td>
            </td>
          </template>
        </RISubform>
      </template>
    </RIForm>
  </AuthenticatedLayout>
</template>
