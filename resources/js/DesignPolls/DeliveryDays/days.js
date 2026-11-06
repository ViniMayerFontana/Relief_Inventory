// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// Shared by the delivery-days demos (App\Support\DesignPolls 'delivery-days'). Every demo keeps the same state —
// day => 'no' | 'ok' | 'pref' — so the summary line reads the same whichever design is being tried.

import { reactive } from 'vue';

export const WEEK_DAYS = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

export function blankDays() {
	return reactive(Object.fromEntries(WEEK_DAYS.map((day) => [day, 'no'])));
}

export function resetDays(days) {
	for (const day of WEEK_DAYS) days[day] = 'no';
}

/** Summarizes accepted and preferred days for the demo. */
export function summarize(days) {
	const accepted = WEEK_DAYS.filter((day) => days[day] !== 'no');
	if (!accepted.length) return 'Nenhum dia selecionado';
	const canAccept = accepted.length === 7 ? 'Qualquer dia' : accepted.join(', ');
	const pref = WEEK_DAYS.filter((day) => days[day] === 'pref');
	return 'Pode receber: ' + canAccept + (pref.length ? ' · Preferencial: ' + pref.join(', ') : '');
}
