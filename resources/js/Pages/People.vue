<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import HelpLink from '@/Components/HelpLink.vue';
import { Head } from '@inertiajs/vue3';
import TextInput from '@/Components/TextInput.vue';
import ComboBox from '@/Components/ComboBox.vue';
import MultiSelect from '@/Components/MultiSelect.vue';
import Checkbox from '@/Components/Checkbox.vue';
import RIForm from '@/Components/RIForm.vue';
import TextArea from '@/Components/TextArea.vue';
import SearchSelect from '@/Components/SearchSelect.vue';
import AddressCorrectionCheck from '@/Components/AddressCorrectionCheck.vue';

defineProps({
    breadcrumb: {
        type: Array,
    },
    canDelete: {
        type: Boolean,
        default: false,
    },
});
</script>

<template>
  <Head title="Cadastro de pessoas" />
  <AuthenticatedLayout :breadcrumb="breadcrumb">
    <template #header>
    </template>

    <RIForm
      ref="riform"
      title="Formulário de cadastro de pessoas"
      datasource="/json/people"
      :filter="peopleFilter">

      <template #listactions>
        <input
          type="text"
          v-model="peopleSearch"
          class="ri_forminput people_search"
          placeholder="Buscar por nome ou organização..."
        />
        <HelpLink guide="people">Guia de entidades parceiras e doadores</HelpLink>
      </template>

      <template #thead>
        <th>Pessoas</th>
      </template>

      <template #tbody="{ record }">
        <td class="people_card">
          <div class="people_line1">
            <strong>{{ [record.first_name, record.last_name].filter(Boolean).join(' ') || 'N/A' }}</strong>
            <span v-if="record.organization">{{ record.organization }}</span>
            <span v-if="record.is_organization" class="people_badge">organização</span>
            <span v-if="record.category" class="people_dim">{{ record.category.name }}</span>
            <span v-if="record.parent" class="people_dim">Organização principal: {{ record.parent.full_name }}</span>
          </div>
          <div class="people_line2">
            <span>Telefone: {{ record.phone || 'N/A' }}</span>
            <span :title="record.email || ''">E-mail: {{ shortenEmail(record.email) }}</span>
            <span>Funções: {{ (record.roles || []).map((r) => r.name).join(', ') || 'Nenhuma' }}</span>
            <span>Voluntário: {{ record.is_volunteer ? 'Sim' : 'Não' }}</span>
          </div>
        </td>
      </template>

      <template #default="{ record, editing, templates }">
        <div class="ri_formtable">
          <p v-if="record.id && record.can_edit === false" class="ri_error">
            Você não tem permissão para editar este registro — a pessoa tem uma permissão que você não possui. Exibindo somente para leitura.
          </p>
          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Nome:</div>
            <TextInput
              v-model="record.first_name"
              :enabled="canEditRecord(record, editing)"
            />
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Sobrenome:</div>
            <TextInput
              v-model="record.last_name"
              :enabled="canEditRecord(record, editing)"
            />
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Organização:</div>
            <TextInput
              v-model="record.organization"
              :enabled="canEditRecord(record, editing)"
            />
          </div>
          <p class="ri_fieldhint">Informe um nome (nome e sobrenome) e/ou uma organização — pelo menos um é obrigatório.</p>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Este registro representa a própria organização:</div>
            <Checkbox
              v-model="record.is_organization"
              :enabled="canEditRecord(record, editing)"
            />
          </div>
          <p class="ri_fieldhint">
            Marque esta opção para o registro da própria organização (ex.: "Igreja Adventista do Sétimo Dia de Macedonia"),
            para vincular abaixo os contatos individuais dessa organização, sem depender de quais campos de nome foram preenchidos.
          </p>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Organização principal:</div>
            <SearchSelect
              v-model="record.parent_person_id"
              optionsource="/json/people?is_organization=1"
              display="full_name"
              placeholder="Buscar organizações..."
              :enabled="canEditRecord(record, editing)"
            />
          </div>
          <p class="ri_fieldhint">
            Defina este campo quando a pessoa for contato de uma organização já cadastrada acima (marcada como
            "Este registro representa a própria organização"), e não um doador, destinatário ou contato independente.
          </p>

          <div class="ri_fieldset" v-if="record.parent_person_id">
            <div class="ri_fieldlabel">Função do contato:</div>
            <TextInput
              v-model="record.contact_role"
              placeholder="ex.: Principal, Entrega, Cobrança"
              :enabled="canEditRecord(record, editing)"
            />
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Categoria:</div>
            <SearchSelect
              ref="categorySelect"
              v-model="record.category_id"
              optionsource="/json/person-categories"
              display="name"
              placeholder="ex.: Doador, Fornecedor, Contato do armazém..."
              :allowcreate="true"
              :enabled="canEditRecord(record, editing)"
              @create="createCategory"
            />
          </div>
          <p v-if="categoryError" class="ri_error">{{ categoryError }}</p>
          <p class="ri_fieldhint">
            Uma etiqueta livre para filtrar a lista de pessoas (doador, fornecedor, contato do armazém etc.) —
            digite uma nova para adicioná-la. Não está vinculada a permissões e não é obrigatória.
          </p>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Código do crachá:</div>
            <TextInput
              v-model="record.badge_code"
              :enabled="canEditRecord(record, editing)"
            />
          </div>
          <p class="ri_fieldhint">Leia ou digite o código do crachá físico desta pessoa, se houver — usado para desbloqueio por PIN com crachá.</p>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Telefone:</div>
            <TextInput
              v-model="record.phone"
              type="tel"
              :enabled="canEditRecord(record, editing)"
            /> 
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">E-mail:</div>
            <TextInput
              v-model="record.email"
              type="email"
              :enabled="canEditRecord(record, editing)"
            /> 
          </div>

		  <!-- ZIP first, then street address: geocod.io resolves city/state/
		       county confidently from street+zip alone, so asking ZIP (quick
		       to state on a call) before the street lets the rest fill in
		       automatically once address is entered — the partner reciting
		       their full address afterward becomes a confirmation pass over
		       already-filled fields rather than the only source of them.
		       @blur.capture (not @blur) because it needs to catch focus
		       leaving TextInput/TextArea's inner <input>/<textarea> despite
		       those components' own wrapping div sitting between here and
		       the actual field — blur doesn't bubble, but capture-phase
		       listeners on an ancestor still see it on the way down. -->
		  <div class="people_address_fields" @blur.capture="maybeAutoLookupCounty(record)">
			  <div class="ri_fieldset">
				<div class="ri_fieldlabel">CEP:</div>
				<TextInput
				  v-model="record.zip"
				  maxlength="10"
				  :enabled="canEditRecord(record, editing)"
				/>
			  </div>

			  <div class="ri_fieldset">
				<div class="ri_fieldlabel">Endereço:</div>
				<TextArea
				  v-model="record.address"
				  :enabled="canEditRecord(record, editing)"
				/>
			  </div>

			  <AddressCorrectionCheck
				:status="addressCheck.status" :casing-only="addressCheck.casingOnly"
				:entered="addressCheck.entered" :suggested="addressCheck.suggested"
				@accept="acceptAddressSuggestion" @keep="keepAddressAsEntered" />

			  <p v-if="editing && record.address && !(record.verified_address || record.address_verified_at)
				&& addressCheck.status === 'idle'" class="people_county_hint">
				<button type="button" class="ri_formbutton" :disabled="$page.props.offlineMode"
					@click="verifyAddress(record)">
					{{ $page.props.offlineMode ? "Não é possível verificar o endereço sem conexão" : 'Verificar endereço' }}
				</button>
			  </p>

			  <div class="ri_fieldset">
				<div class="ri_fieldlabel">Cidade:</div>
				<TextInput
				  v-model="record.city"
				  :enabled="editing && addressCheck.status !== 'checking'"
				/>
			  </div>

			  <div class="ri_fieldset">
				<div class="ri_fieldlabel">Estado:</div>
				<TextInput
				  v-model="record.state"
				  maxlength="2"
				  :enabled="editing && addressCheck.status !== 'checking'"
				/>
			  </div>

			  <div class="ri_fieldset">
				<div class="ri_fieldlabel">Município:</div>
				<ComboBox
					v-model:keyValue="record.county_id"
					v-model:updates="record.county_id"
					optionsource="/json/counties"
					display="county"
					secondaryDisplay="state"
					:filter="(c) => !record.state || c.state === record.state.toUpperCase()"
					:enabled="canEditRecord(record, editing)"
				/>
				<p v-if="countyLookupError" class="people_county_error">{{ countyLookupError }}</p>
				<p v-if="countyLookupHint" class="people_county_hint">{{ countyLookupHint }}</p>
			  </div>
		  </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Funções:</div>
            <MultiSelect
				v-model:records="record.people_roles"
				:template="templates.people_roles"
				optionsource="/json/roles?context=people"
                :enabled="canEditRecord(record, editing)"
				fk_field="role_id"
				display="name"
            />
          </div>
          <p class="ri_fieldhint">
            O acesso da equipe (administrador, escritório etc.) e as substituições de permissões são
            gerenciados em Configuração &rarr; Administração de usuários, não aqui.
          </p>

          <div v-if="record.id && record.roles?.some((r) => r.name === 'Partner')" class="ri_fieldset">
            <div class="ri_fieldlabel">Status da entidade parceira:</div>
            <div>
              <span v-if="record.partner_status" class="people_badge">{{ record.partner_status }}</span>
              <span v-else class="text-gray-400 text-sm">Não rastreado</span>
            </div>
          </div>
          <div v-if="record.id && record.roles?.some((r) => r.name === 'Partner')" class="ri_fieldset">
            <div class="ri_fieldlabel"></div>
            <div class="flex gap-3 text-sm">
              <button
                v-for="action in partnerStatusActions(record)"
                :key="action.to"
                type="button"
                class="text-blue-600 underline"
                @click="startPartnerStatusChange(record, action.to)"
              >
                {{ action.label }}
              </button>
            </div>
            <div v-if="composingPartnerStatus?.recordId === record.id" class="mt-2 space-y-2">
              <TextArea v-model="composingPartnerStatus.notes" placeholder="Observação opcional" />
              <div v-if="partnerStatusError" class="ri_error">{{ partnerStatusError }}</div>
              <div class="flex gap-2">
                <button type="button" class="ri_defaultbutton" @click="confirmPartnerStatusChange(record)">Confirmar</button>
                <button type="button" class="ri_formbutton" @click="composingPartnerStatus = null">Cancelar</button>
              </div>
            </div>
            <div v-if="record.partner_status_logs?.length" class="mt-2 text-xs text-gray-500 space-y-1">
              <div v-for="log in record.partner_status_logs" :key="log.id">
                {{ log.from_status || '(not tracked)' }} &rarr; {{ log.to_status }}
                por {{ log.changed_by?.full_name }} &mdash; {{ new Date(log.created_at).toLocaleString() }}
                <span v-if="log.notes">&mdash; {{ log.notes }}</span>
              </div>
            </div>
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Voluntário:</div>
            <Checkbox
              v-model="record.is_volunteer"
              :enabled="canEditRecord(record, editing)"
            />
          </div>
          <p class="ri_fieldhint">
            O fato de esta pessoa ser voluntária é independente de sua função — uma pessoa voluntária
            também pode ser gerente do escritório ou administradora. Essa informação alimenta o controle de horas voluntárias.
          </p>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">Observações:</div>
            <TextArea
              v-model="record.comments"
              :enabled="canEditRecord(record, editing)"
            />
          </div>
        </div>
      </template>

      <template #actions="{ editing, record, confirmingDelete, save, cancel, delete: doDelete, keepRecord }">
        <div class="ri_formactions" v-if="!editing || (record.id && record.can_edit === false)">
          <button @click="cancel()" class="ri_defaultbutton">Voltar à lista</button>
        </div>
        <div class="ri_formactions" v-else>
          <button @click="save()" class="ri_defaultbutton">Salvar</button>
          <button @click="cancel()" class="ri_formbutton">Cancelar alterações</button>
          <button v-if="canDelete" @click="doDelete()" class="ri_deletebutton" :class="{ ri_confirming: confirmingDelete }">
            {{ confirmingDelete ? 'Confirmar exclusão — não será possível desfazer' : 'Excluir' }}
          </button>
          <button v-if="canDelete && confirmingDelete" @click="keepRecord()" class="ri_linkbutton">Manter registro</button>
        </div>
      </template>
    </RIForm>
  </AuthenticatedLayout>
</template>

<script>
import axios from 'axios';
import { invalidateOptions } from '@/Components/SearchSelect.vue';

function normalizeAddr(s) {
  return (s || '').toString().trim().toLowerCase().replace(/\s+/g, ' ');
}
const IDLE_ADDRESS_CHECK = { status: 'idle', casingOnly: false, entered: {}, suggested: {} };

export default {
  data() {
    return {
      peopleSearch: '',
      categoryError: null,
      countyLookupError: null,
      countyLookupHint: null,
      // Drives AddressCorrectionCheck inline (see maybeAutoLookupCounty).
      addressCheck: { status: 'idle', casingOnly: false, entered: {}, suggested: {} },
      composingPartnerStatus: null, // { recordId, to, notes }
      partnerStatusError: null,
    };
  },
  computed: {
    peopleFilter() {
      const query = this.peopleSearch.trim().toLowerCase();
      return (record) => {
        if (!query) return true;
        const haystack = [record.first_name, record.last_name, record.organization]
          .filter(Boolean)
          .join(' ')
          .toLowerCase();
        return haystack.includes(query);
      };
    },
  },
  methods: {
    // Long addresses are cut in the middle of the local part so the domain stays readable.
    shortenEmail(email, max = 28) {
      if (!email) return 'Não disponível';
      if (email.length <= max) return email;
      const at = email.lastIndexOf('@');
      const domain = at >= 0 ? email.slice(at) : '';
      const local = at >= 0 ? email.slice(0, at) : email;
      const room = Math.max(max - domain.length - 1, 4);
      const head = Math.ceil(room / 2);
      const tail = Math.floor(room / 2);
      return local.slice(0, head) + '…' + local.slice(local.length - tail) + domain;
    },
    // Server-computed (PeopleController::index) mirror of assertNoEscalation:
    // false only once the record has an id and the acting user lacks a
    // permission this person currently holds. A brand-new record has no
    // can_edit yet (undefined), so it's editable as soon as the page itself
    // let you in — this only ever locks down an existing person you can't
    // touch, never a record you're creating.
    canEditRecord(record, editing) {
      return editing && record.can_edit !== false;
    },
    // Category is a small open-ended tag list (Donor/Supplier/Warehouse
    // Contact/...) — quick-added inline via SearchSelect's allowcreate,
    // same idiom Receiving.vue uses for donors, but simpler (one field).
    async createCategory(name) {
      this.categoryError = null;
      const trimmed = (name || '').trim();
      if (!trimmed) return;
      try {
        const response = await axios.post('/json/person-categories', { name: trimmed });
        invalidateOptions('/json/person-categories');
        await this.$refs.categorySelect?.refresh(response.data.record.id);
      } catch (error) {
        this.categoryError = error.response?.data?.message || 'Não foi possível salvar a categoria.';
      }
    },
    // Looks up county/city/state/zip once there's enough to geocode —
    // fires on blur of any address field (see @blur.capture above), but
    // only actually calls out once address is non-blank and at least one
    // of zip/state is present (geocod.io resolves confidently from
    // street+zip alone even with city/state blank — tested at `rooftop`
    // accuracy). While the request is in flight, City/State are disabled
    // in the template (bound to `addressCheck.status === 'checking'`) —
    // editing a field mid-flight is exactly what caused the cursor-jump
    // race Mark found, since the response landing while still typing
    // collided with v-model. Only the ADDRESS text itself gets a review
    // step (AddressCorrectionCheck, rendered inline — no modal, no native
    // <dialog>), and only when geocod.io's version actually differs;
    // city/state/zip are simple enough to just fill in directly once
    // blank. County is applied directly too, since it's a separate,
    // already-editable picker widget.
    // `force` bypasses the dedup key — used by the manual "Verify Address"
    // button so it always re-checks even if this exact input was already
    // tried (e.g. tried once while offline and failed, or the record was
    // just loaded and nothing's been retyped).
    async maybeAutoLookupCounty(record, force = false) {
      if (this.$page.props.offlineMode) return; // no internet — don't even attempt it
      const address = (record.address || '').trim();
      const zip = (record.zip || '').trim();
      const state = (record.state || '').trim();
      if (!address || (!zip && !state)) return;

      const key = `${address}|${state}|${zip}`;
      if (!force && record.__geocodeKey === key) return; // already tried this exact input
      if (record.__geocodeKey !== key) record.verified_address = false; // input changed since any prior verification
      record.__geocodeKey = key;

      this.countyLookupError = null;
      this.countyLookupHint = null;
      this.addressCheck = { ...IDLE_ADDRESS_CHECK, status: 'checking' };
      try {
        const response = await axios.post('/json/geocode/county', {
          address: record.address, city: record.city, state: record.state, zip: record.zip,
        });
        const entered = { address: record.address, city: record.city, state: record.state, zip: record.zip };
        const suggested = {
          address: response.data.address, city: response.data.city,
          state: response.data.state, zip: response.data.zip,
        };
        if (!suggested.address || entered.address === suggested.address) {
          this.applyAddressFields(record, suggested);
          record.verified_address = true;
          this.addressCheck = { ...IDLE_ADDRESS_CHECK };
        } else {
          this.addressCheck = {
            status: 'ready',
            casingOnly: normalizeAddr(entered.address) === normalizeAddr(suggested.address),
            entered, suggested,
          };
        }
        this._addressCheckRecord = record;
        if (!record.county_id && response.data.county_id) {
          record.county_id = response.data.county_id;
        } else if (!record.county_id && response.data.county) {
          this.countyLookupHint = `O Geocodio sugere "${response.data.county}, ${response.data.state}" `
            + '— esse município ainda não está na lista acima.';
        }
      } catch (error) {
        this.addressCheck = { ...IDLE_ADDRESS_CHECK };
        // 422: geocod.io just couldn't resolve this address — not worth an
        // alarming error. 503: lookup is unavailable (offline mode, or no
        // API key configured) — also expected, not a fault; address entry
        // works fine without it either way.
        if (![422, 503].includes(error.response?.status)) {
          this.countyLookupError = error.response?.data?.message || 'Não foi possível consultar esse endereço.';
        }
      }
    },
    // Fills city/state/zip from a suggestion, but only where blank — never
    // overwrites something already typed.
    applyAddressFields(record, suggested) {
      if (!record.city) record.city = suggested.city || record.city;
      if (!record.state) record.state = suggested.state || record.state;
      if (!record.zip) record.zip = suggested.zip || record.zip;
    },
    acceptAddressSuggestion() {
      const record = this._addressCheckRecord;
      const suggested = this.addressCheck.suggested;
      if (record) {
        record.address = suggested.address;
        this.applyAddressFields(record, suggested);
        record.verified_address = true;
      }
      this.addressCheck = { ...IDLE_ADDRESS_CHECK };
    },
    keepAddressAsEntered() {
      const record = this._addressCheckRecord;
      const suggested = this.addressCheck.suggested;
      if (record) {
        this.applyAddressFields(record, suggested);
        // Geocod.io was still consulted and a human looked at both options
        // — that counts as "checked," even though the as-typed version won.
        record.verified_address = true;
      }
      this.addressCheck = { ...IDLE_ADDRESS_CHECK };
    },
    // Manual fallback for when the automatic blur-triggered lookup never
    // ran (offline mode was on at entry time, or this record predates the
    // whole feature) — same underlying check, just user-initiated and
    // forced past the dedup guard. Deliberately per-record and opt-in
    // rather than a batch job: geocod.io's free tier is a shared daily
    // quota, and there's no reason to spend it re-checking addresses
    // nobody's actively working with.
    verifyAddress(record) {
      this.maybeAutoLookupCounty(record, true);
    },
    // Mirrors Person::PARTNER_STATUS_TRANSITIONS server-side — this is
    // purely which buttons to show; the server still enforces the legal
    // move regardless of what the UI offers.
    partnerStatusActions(record) {
      const options = {
        '': [
          { to: 'approved', label: 'Aprovar' },
          { to: 'denied', label: 'Negar' },
        ],
        pending: [
          { to: 'approved', label: 'Aprovar' },
          { to: 'denied', label: 'Negar' },
        ],
        approved: [
          { to: 'blocked', label: 'Bloquear' },
          { to: 'denied', label: 'Negar' },
        ],
        denied: [
          { to: 'pending', label: 'Reconsiderar' },
          { to: 'approved', label: 'Aprovar' },
        ],
        blocked: [
          { to: 'approved', label: 'Desbloquear (aprovar)' },
          { to: 'denied', label: 'Negar' },
        ],
      };
      return options[record.partner_status || ''] || [];
    },
    startPartnerStatusChange(record, to) {
      this.composingPartnerStatus = { recordId: record.id, to, notes: '' };
      this.partnerStatusError = null;
    },
    async confirmPartnerStatusChange(record) {
      this.partnerStatusError = null;
      try {
        const response = await axios.post(`/json/people/${record.id}/partner-status`, {
          to_status: this.composingPartnerStatus.to,
          notes: this.composingPartnerStatus.notes.trim() || null,
        });
        record.partner_status = response.data.record.partner_status;
        record.partner_status_logs = response.data.record.partner_status_logs;
        this.composingPartnerStatus = null;
      } catch (error) {
        this.partnerStatusError = error.response?.data?.message || 'Não foi possível atualizar o status da entidade parceira.';
      }
    },
  },
};
</script>

<style scoped>

td.comma-separated span:not(:last-child)::after {
  content: ', ';
}

.people_card { max-width: 0; width: 100%; }
.people_line1, .people_line2 { display: flex; flex-wrap: wrap; gap: 0.2em 1.2em; }
.people_line2 { font-size: 0.85em; color: #4b5563; margin-top: 0.15em; }
.people_dim { color: #6b7280; }

.people_badge {
  margin-left: 0.4em;
  font-size: 0.75em;
  color: #4338ca;
  border: 1px solid #c7d2fe;
  border-radius: 4px;
  padding: 0.05em 0.4em;
}

.people_search {
  max-width: 20rem;
}

.people_county_error {
  color: #b91c1c;
  font-size: 0.85em;
  margin-top: 0.3em;
}

.people_county_hint {
  color: #4338ca;
  font-size: 0.85em;
  margin-top: 0.3em;
}
</style>
