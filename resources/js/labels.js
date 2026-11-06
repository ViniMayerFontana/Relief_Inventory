const transactionStatusLabels = {
	'Shopping Cart': 'Carrinho de compras',
	Logged: 'Registrado',
	'New Order': 'Novo pedido',
	'Picking In Progress': 'Separação em andamento',
	'Ready to Fill': 'Pronto para separação',
	Filling: 'Em separação',
	Filled: 'Separado',
	'Ready to Ship': 'Pronto para envio',
	Shipped: 'Enviado',
	Delivered: 'Entregue',
	'Delivered - Waiting on BOL': 'Entregue — aguardando nova BOL',
	Completed: 'Concluído',
	'Closed - Unfulfilled': 'Encerrado — não atendido',
	Received: 'Recebido',
	Sorting: 'Em triagem',
	Complete: 'Concluído',
};

const palletStatusLabels = {
	received: 'Recebido',
	sorting: 'Em triagem',
	empty: 'Vazio',
	sealed: 'Lacrado',
	open: 'Aberto',
	building: 'Em montagem',
	ready: 'Pronto',
	shipped: 'Enviado',
	filling: 'Em separação',
	collected: 'Coletado',
	held: 'Retido',
	released: 'Liberado',
	condemned: 'Condenado',
	missing: 'Desaparecido',
};

const palletKindLabels = {
	R: 'Recebimento',
	W: 'Armazém',
	S: 'Expedição',
	H: 'Retenção',
	Q: 'Quarentena',
};

const categoryLabels = {
	'Animal products & durable medical': 'Produtos de origem animal e equipamentos médicos duráveis',
	'Food & water': 'Alimentos e água',
	'Personal care, pharmacy & safety': 'Cuidados pessoais, farmácia e segurança',
	'Paper & disposables': 'Papel e descartáveis',
	'Baby & child': 'Bebês e crianças',
	'Bedding & linens': 'Cama e banho',
	'Kitchen & dining': 'Cozinha e utensílios',
	'Cleaning & household': 'Limpeza e utilidades domésticas',
	'Clothing & accessories': 'Roupas e acessórios',
	'Outdoor, emergency & tools': 'Área externa, emergência e ferramentas',
	'Appliances, large (team-lift)': 'Eletrodomésticos grandes (transporte em equipe)',
	'Appliances, small (countertop)': 'Eletrodomésticos pequenos (de bancada)',
	'Building supplies': 'Materiais de construção',
	Furniture: 'Móveis',
	'Holy Bible': 'Bíblia Sagrada',
};

const roleLabels = {
	Administrator: 'Administrador',
	'Sorting and Inventory': 'Triagem e estoque',
	Office: 'Escritório',
	Partner: 'Parceiro',
	Donor: 'Doador',
	Volunteer: 'Voluntário',
	'Trainee': 'Aprendiz',
	'Team Leader': 'Líder de equipe',
};

const partnerStatusLabels = {
	pending: 'Pendente',
	approved: 'Aprovado',
	denied: 'Recusado',
	blocked: 'Bloqueado',
};

const backupProgressLabels = {
	queued: 'Na fila',
	running: 'Em andamento',
	'Waiting for another backup to finish': 'Aguardando a conclusão de outro backup',
	Starting: 'Iniciando',
	'Dumping the database': 'Exportando o banco de dados',
	'Listing uploaded files': 'Listando arquivos enviados',
	Compressing: 'Compactando',
	'Waiting for the provisioner': 'Aguardando o provisionador',
	'Making the backup': 'Criando o backup',
};

export function transactionStatusLabel(status) {
	return transactionStatusLabels[status] || status || '';
}

export function palletStatusLabel(status) {
	return palletStatusLabels[String(status || '').toLowerCase()] || status || '';
}

export function palletKindLabel(kind) {
	return palletKindLabels[kind] || kind || '';
}

export function itemStatusLabel(status) {
	return {
		orderable: 'Disponível para pedidos',
		sort_hold: 'Retido na triagem',
	}[status] || status || '';
}

export function receivingCategoryLabel(category) {
	return {
		donation: 'Doação',
		equipment: 'Equipamentos',
		supplies: 'Suprimentos',
		other: 'Outro',
	}[category] || category || '';
}

export function locationStatusLabel(status) {
	return {
		active: 'Ativo',
		archived: 'Arquivado',
	}[status] || status || '';
}

export function itemCategoryLabel(category) {
	return categoryLabels[category] || category || '';
}

export function roleLabel(role) {
	return roleLabels[role] || role || '';
}

export function partnerStatusLabel(status) {
	return partnerStatusLabels[status] || status || '';
}

export function backupProgressLabel(progress) {
	if (!progress) return '';
	const checksum = String(progress).match(/^Checksumming files \((\d+) of (\d+)\)$/);
	if (checksum) return `Verificando integridade dos arquivos (${checksum[1]} de ${checksum[2]})`;
	return backupProgressLabels[progress] || progress;
}
