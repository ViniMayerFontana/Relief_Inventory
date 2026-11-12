<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<p>{{ __('mail.hello') }}</p>

<p>
    {{ __('mail.invitation_join', ['invitedBy' => $invitedBy ?: __('mail.administrator_fallback')]) }}
    <strong>{{ $warehouse->display_name }}</strong>
    {{ __('mail.invitation_join_tail', ['app' => config('app.name'), 'email' => $email]) }}
</p>

<p>
    {{ __('mail.invitation_accept') }}<br>
    <a href="{{ $url }}">{{ $url }}</a>
</p>

<p>
    {{ __('mail.invitation_expires', ['date' => $expiresAt->translatedFormat(app()->getLocale() === 'pt_BR' ? 'd/m/Y' : 'M j, Y')]) }}
    <strong>{{ $warehouse->display_name }}</strong>
    {{ __('mail.invitation_unless_accepted') }}
</p>
