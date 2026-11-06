<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<p>Olá,</p>

<p>
    {{ $invitedBy ?: 'Um administrador' }} convidou você para participar do <strong>{{ $warehouse->display_name }}</strong> no {{ config('app.name') }}
    usando seu acesso atual ({{ $email }}).
</p>

<p>
    Nada será alterado até você aceitar. Para aceitar, abra o link abaixo e informe sua senha:<br>
    <a href="{{ $url }}">{{ $url }}</a>
</p>

<p>
    O link é válido até {{ $expiresAt->toFormattedDateString() }}. Se você não estava esperando este convite, ignore este e-mail: seu acesso não
    será vinculado ao {{ $warehouse->display_name }} até que você o aceite.
</p>
