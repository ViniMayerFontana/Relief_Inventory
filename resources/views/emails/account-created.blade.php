<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<p>Olá, {{ $person->full_name }}.</p>

<p>
    Uma conta foi criada para você em {{ config('app.name') }}{{ $createdBy ? ' por '.$createdBy->full_name : '' }}.
</p>

<p>
    <strong>Acesse em:</strong> <a href="{{ \App\Models\Control\Warehouse::current()->publicUrl('/login') }}">{{ \App\Models\Control\Warehouse::current()->publicUrl('/login') }}</a><br>
    <strong>E-mail:</strong> {{ $person->email }}
</p>

<p>
    Sua senha será fornecida separadamente por
    {{ $createdBy ? $createdBy->full_name : 'seu administrador' }}; ela não está incluída neste e-mail.
    @if ($person->password_change_required)
    Você deverá escolher uma senha própria no primeiro acesso.
    @endif
</p>

<p>
    Se você não receber sua senha, use
    <a href="{{ \App\Models\Control\Warehouse::current()->publicUrl('/forgot-password') }}">Esqueceu sua senha?</a> na página de acesso para criar uma.
</p>
